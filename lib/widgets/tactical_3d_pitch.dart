import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;
import '../services/pdf_exporter_service.dart';
import '../services/tracking_player_engine.dart';
import '../services/supabase_service.dart';
import 'timeline_scrubber_widget.dart';
import 'tactical_3d_interactivity.dart';
import 'tactical_pov_camera_controller.dart';
import 'tactical_pov_bar.dart';
import 'tactical_3d_heatmap.dart';
import 'passing_risk_corridor.dart';

// 1. تعريف التشكيلات التكتيكية الجاهزة (إحداثيات X و Z لكل لاعب)
final Map<String, List<three.Vector3>> formations3D = {
  "4-3-3": [
    three.Vector3(-45, 1.25, 0),   // GK
    three.Vector3(-25, 1.25, -25), // LB
    three.Vector3(-30, 1.25, -8),  // LCB
    three.Vector3(-30, 1.25, 8),   // RCB
    three.Vector3(-25, 1.25, 25),  // RB
    three.Vector3(-10, 1.25, 0),   // CDM
    three.Vector3(  5, 1.25, -15), // LCM
    three.Vector3(  5, 1.25, 15),  // RCM
    three.Vector3( 30, 1.25, -22), // LW
    three.Vector3( 35, 1.25, 0),   // ST
    three.Vector3( 30, 1.25, 22),  // RW
  ],
  "5-3-2": [
    three.Vector3(-45, 1.25, 0),   // GK
    three.Vector3(-25, 1.25, -25), // LWB
    three.Vector3(-30, 1.25, -14), // LCB
    three.Vector3(-32, 1.25, 0),   // CCB
    three.Vector3(-30, 1.25, 14),  // RCB
    three.Vector3(-25, 1.25, 25),  // RWB
    three.Vector3(-10, 1.25, -12), // LCM
    three.Vector3(-8,  1.25, 0),   // CM
    three.Vector3(-10, 1.25, 12),  // RCM
    three.Vector3( 20, 1.25, -8),  // ST 1
    three.Vector3( 20, 1.25, 8),   // ST 2
  ],
};

enum TacticalTool { select, passArc, playerRun, zoneDraw, eraser }

class Tactical3DPitchWidget extends StatefulWidget {
  final ValueChanged<TrackingPlaybackEngine>? onEngineReady;

  const Tactical3DPitchWidget({
    super.key,
    this.onEngineReady,
  });

  @override
  State<Tactical3DPitchWidget> createState() => _Tactical3DPitchWidgetState();
}

class _Tactical3DPitchWidgetState extends State<Tactical3DPitchWidget> {
  late three.ThreeJS threeJs;
  late three.OrbitControls controls;

  // حالة الأدوات والألوان النشطة
  TacticalTool currentTool = TacticalTool.select;
  Color currentColor = const Color(0xFFFACC15); // الأصفر للتمريرات

  // حقول لتسجيل نقاط أدوات الرسم
  three.Object3D? firstSelectedPlayerForPass;
  three.Object3D? firstSelectedPlayerForRun;
  List<three.Vector2> zoneDrawPoints = [];

  // مجموعات المشهد
  three.Group pitchGroup = three.Group();
  three.Group playersGroup = three.Group();
  three.Group drawingsGroup = three.Group(); // مجموعة منفصلة للرسوم لسهولة المسح

  // الكرة والفيزياء والكاميرا
  late three.Mesh ballMesh;
  three.Vector3 ballVelocity = three.Vector3(0, 0, 0);
  final double gravity = 18.0;
  final double ballRadius = 0.5;
  bool isBallInMotion = false;
  bool isCameraTrackingBall = false;

  final three.Vector3 cameraFollowOffset = three.Vector3(0, 18, 30);
  three.Vector3 cameraCurrentTarget = three.Vector3(0, 0, 0);

  // السحب والتحديد
  three.Raycaster raycaster = three.Raycaster();
  three.Vector2 mousePosition = three.Vector2();
  three.Object3D? selectedPlayer;
  three.Plane pitchPlane = three.Plane(three.Vector3(0, 1, 0), 0);
  Tactical3DInteractivity? interactivity;
  late TacticalPovCameraController povController;
  late Tactical3DHeatmap heatmap;
  late PassingRiskCorridor riskCorridor;

  // الأنيميشن
  bool isAnimatingFormation = false;
  double animationProgress = 0.0;
  List<three.Vector3> startPositions = [];
  List<three.Vector3> targetPositions = [];
  final double animationDurationSeconds = 1.5;
  final GlobalKey pitchCanvasKey = GlobalKey();
  bool isRecordingOrPlaying = false;
  late TrackingPlaybackEngine playbackEngine;

  void onVideoAnalysisResultReceived(String trackingJsonData) {
    setState(() {
      playbackEngine.loadTrackingJson(trackingJsonData);
      playbackEngine.play();
    });
  }

  // دالة التقاط الـ 3D Canvas واستخراجها كـ Uint8List (PNG Bytes)
  Future<Uint8List?> capture3DPitchImage() async {
    try {
      final boundary = pitchCanvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          return byteData.buffer.asUint8List();
        }
      }
    } catch (e) {
      debugPrint("خطأ أثناء التقاط صورة الملعب: $e");
    }
    return null;
  }

  Future<void> _exportPdfReport() async {
    final imageBytes = await capture3DPitchImage();
    if (imageBytes != null) {
      await TacticalPdfExporter.generateAndShareTacticalReport(
        pitchImageBytes: imageBytes,
        matchTitle: "تحليل مباراة الكلاسيكو - ضغط عالي",
        coachName: "الكابتن أحمد",
        formationName: "4-3-3",
        tacticalNotes: [
          "تطبيق الضغط العالي المتقدم ابتداءً من الدقيقة 15 على حامل الكرة.",
          "إغلاق مسارات التمرير على لاعب الارتكاز وتوجيه اللعب نحو الأطراف.",
          "استغلال مساحة المساحات الخالية خلف الظهير الأيمن أثناء التمرير السريع.",
        ],
      );
    }
  }

  Future<void> _save3DStateToCloud() async {
    try {
      final Map<String, dynamic> current3DState = {
        'players': playersGroup.children.map((p) => {
          'x': p.position.x,
          'z': p.position.z,
        }).toList(),
        'camera_position': {
          'x': threeJs.camera.position.x,
          'y': threeJs.camera.position.y,
          'z': threeJs.camera.position.z,
        },
      };

      await SupabaseService().save3DTacticalBoard(
        title: "تحليل مباراة الشرطة - خطة الضغط 3D",
        formation: "4-3-3",
        board3DStateJson: current3DState,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حفظ التكتيك بنجاح في حسابك سحابياً!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تنبيه الحفظ: $e"),
            backgroundColor: Colors.amber[800],
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    threeJs = three.ThreeJS(
      setup: setupScene,
      onSetupComplete: () {
        widget.onEngineReady?.call(playbackEngine);
      },
    );
  }

  @override
  void dispose() {
    controls.dispose();
    threeJs.dispose();
    super.dispose();
  }

  Future<void> setupScene() async {
    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(0x0f172a);

    threeJs.camera = three.PerspectiveCamera(
      45,
      threeJs.width / threeJs.height,
      0.1,
      1000,
    );
    _setBroadcastCameraView();

    controls = three.OrbitControls(threeJs.camera, threeJs.globalKey);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.maxPolarAngle = math.pi / 2 - 0.05;

    threeJs.scene.add(three.AmbientLight(0xffffff, 0.7));
    final dirLight = three.DirectionalLight(0xffffff, 0.8);
    dirLight.position.setValues(30, 50, 20);
    dirLight.castShadow = true;
    threeJs.scene.add(dirLight);

    threeJs.scene.add(pitchGroup);
    threeJs.scene.add(playersGroup);
    threeJs.scene.add(drawingsGroup);

    _buildPitch();
    _spawnPlayers();
    _spawnBall();

    heatmap = Tactical3DHeatmap();
    pitchGroup.add(heatmap.heatmapMesh);

    riskCorridor = PassingRiskCorridor();
    pitchGroup.add(riskCorridor.corridorMesh);

    playbackEngine = TrackingPlaybackEngine(
      playersGroup: playersGroup,
      ballMesh: ballMesh,
    );

    interactivity = Tactical3DInteractivity(
      camera: threeJs.camera,
      scene: threeJs.scene,
      canvasKey: pitchCanvasKey,
      interactiveObjects: [...playersGroup.children, ballMesh],
    );

    povController = TacticalPovCameraController(
      camera: threeJs.camera as three.PerspectiveCamera,
      pitchCenterTarget: pitchGroup,
    );

    threeJs.postProcessor = ([double? dt]) {
      controls.update();
      if (dt != null) {
        _updateFormationAnimation(dt);
        _updatePhysicsAndCamera(dt);
        playbackEngine.update(dt);
        povController.update(dt);
      }
    };
  }

  void _spawnBall() {
    final ballGeo = three.SphereGeometry(ballRadius, 32, 32);
    final ballMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0xffffff)
      ..roughness = 0.2
      ..metalness = 0.1;

    ballMesh = three.Mesh(ballGeo, ballMat);
    ballMesh.position.setValues(0, ballRadius, 0);
    ballMesh.castShadow = true;

    pitchGroup.add(ballMesh);
  }

  void passBallTo({
    required three.Vector3 targetPosition,
    double arcHeight = 10.0,
    double speedFactor = 1.2,
  }) {
    final startPos = ballMesh.position.clone();
    final distance = startPos.distanceTo(targetPosition);
    final timeToReach = (distance / (15.0 * speedFactor)).clamp(0.8, 3.0);

    final vx = (targetPosition.x - startPos.x) / timeToReach;
    final vz = (targetPosition.z - startPos.z) / timeToReach;
    final vy = (targetPosition.y - startPos.y + 0.5 * gravity * math.pow(timeToReach, 2)) / timeToReach;

    ballVelocity.setValues(vx, vy, vz);
    isBallInMotion = true;
    isCameraTrackingBall = true;
  }

  void _updatePhysicsAndCamera(double deltaTime) {
    if (isBallInMotion) {
      ballVelocity.y -= gravity * deltaTime;

      ballMesh.position.x += ballVelocity.x * deltaTime;
      ballMesh.position.y += ballVelocity.y * deltaTime;
      ballMesh.position.z += ballVelocity.z * deltaTime;

      ballMesh.rotation.x += ballVelocity.z * deltaTime * 0.1;
      ballMesh.rotation.z -= ballVelocity.x * deltaTime * 0.1;

      if (ballMesh.position.y <= ballRadius) {
        ballMesh.position.y = ballRadius;
        ballVelocity.y = -ballVelocity.y * 0.55;
        ballVelocity.x *= 0.85;
        ballVelocity.z *= 0.85;

        if (ballVelocity.length < 0.5) {
          ballVelocity.setValues(0, 0, 0);
          isBallInMotion = false;
        }
      }
    }

    if (isCameraTrackingBall) {
      final ballPos = ballMesh.position;

      final targetCamPos = three.Vector3(
        ballPos.x + cameraFollowOffset.x,
        cameraFollowOffset.y,
        ballPos.z + cameraFollowOffset.z,
      );

      threeJs.camera.position.x += (targetCamPos.x - threeJs.camera.position.x) * 0.05;
      threeJs.camera.position.y += (targetCamPos.y - threeJs.camera.position.y) * 0.05;
      threeJs.camera.position.z += (targetCamPos.z - threeJs.camera.position.z) * 0.05;

      cameraCurrentTarget.x += (ballPos.x - cameraCurrentTarget.x) * 0.08;
      cameraCurrentTarget.y += (ballPos.y - cameraCurrentTarget.y) * 0.08;
      cameraCurrentTarget.z += (ballPos.z - cameraCurrentTarget.z) * 0.08;

      threeJs.camera.lookAt(cameraCurrentTarget);
      controls.target.setValues(cameraCurrentTarget.x, cameraCurrentTarget.y, cameraCurrentTarget.z);
    }
  }

  void _buildPitch() {
    final pitchWidth = 105.0;
    final pitchHeight = 68.0;

    final planeGeo = three.PlaneGeometry(pitchWidth, pitchHeight);
    final pitchMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x1e3a1e)
      ..roughness = 0.8;

    final pitchMesh = three.Mesh(planeGeo, pitchMat);
    pitchMesh.rotation.x = -math.pi / 2;
    pitchMesh.receiveShadow = true;
    pitchGroup.add(pitchMesh);

    final lineMat = three.LineBasicMaterial()
      ..color = three.Color.fromHex32(0xffffff)
      ..linewidth = 2.0;

    final outerBoundaryGeo = three.BufferGeometry();
    final halfW = pitchWidth / 2;
    final halfH = pitchHeight / 2;

    List<double> vertices = [
      -halfW, 0.05, -halfH,
       halfW, 0.05, -halfH,
       halfW, 0.05,  halfH,
      -halfW, 0.05,  halfH,
      -halfW, 0.05, -halfH,
       0.0,   0.05, -halfH,
       0.0,   0.05,  halfH,
    ];

    outerBoundaryGeo.setAttribute(
      three.Attribute.position,
      three.Float32BufferAttribute(Float32List.fromList(vertices), 3),
    );

    final lineSegments = three.LineSegments(outerBoundaryGeo, lineMat);
    pitchGroup.add(lineSegments);
  }

  void _spawnPlayers() {
    final homeColor = 0xef4444;
    final initialFormation = formations3D["4-3-3"]!;

    for (int i = 0; i < initialFormation.length; i++) {
      final pos = initialFormation[i];
      _addPlayerNode(pos.x, pos.z, homeColor, "${i + 1}");
    }

    final leftBack = three.Vector3(-25, 0.5, -25);
    final striker = three.Vector3(35, 0.5, 0);
    _draw3DPassArcBetween(leftBack, striker, colorHex: 0x22c55e);

    final List<three.Vector2> pressingPoints = [
      three.Vector2(-10, -20),
      three.Vector2( 15, -15),
      three.Vector2( 20,  15),
      three.Vector2(-5,   25),
    ];

    _draw3DTacticalZoneMesh(polygonPoints: pressingPoints, colorHex: 0x3b82f6);
  }

  void _addPlayerNode(double x, double z, int colorHex, String number) {
    final cylinderGeo = three.CylinderGeometry(1.2, 1.2, 2.5, 16);
    final material = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(colorHex)
      ..metalness = 0.2
      ..roughness = 0.3;

    final playerMesh = three.Mesh(cylinderGeo, material);
    playerMesh.position.setValues(x, 1.25, z);
    playerMesh.castShadow = true;

    playersGroup.add(playerMesh);
  }

  void animateToFormation(String formationKey) {
    if (!formations3D.containsKey(formationKey) || isAnimatingFormation) return;

    final targets = formations3D[formationKey]!;
    final players = playersGroup.children;

    if (players.length != targets.length) return;

    startPositions = players.map((p) => p.position.clone()).toList();
    targetPositions = targets;

    animationProgress = 0.0;
    isAnimatingFormation = true;
  }

  void _updateFormationAnimation(double deltaTime) {
    if (!isAnimatingFormation) return;

    animationProgress += deltaTime / animationDurationSeconds;

    if (animationProgress >= 1.0) {
      animationProgress = 1.0;
      isAnimatingFormation = false;
    }

    double easedProgress = _easeInOutCubic(animationProgress);

    final players = playersGroup.children;
    for (int i = 0; i < players.length && i < targetPositions.length; i++) {
      final start = startPositions[i];
      final target = targetPositions[i];

      players[i].position.x = start.x + (target.x - start.x) * easedProgress;
      players[i].position.z = start.z + (target.z - start.z) * easedProgress;

      players[i].position.y = 1.25 + (math.sin(easedProgress * math.pi) * 1.5);
    }
  }

  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  void _handlePointerDown(PointerDownEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;

    mousePosition.x = (event.localPosition.dx / size.width) * 2 - 1;
    mousePosition.y = -(event.localPosition.dy / size.height) * 2 + 1;

    raycaster.setFromCamera(mousePosition, threeJs.camera);

    if (currentTool == TacticalTool.select) {
      final locked = interactivity?.onPointerDown(event.position) ?? false;
      if (locked) {
        controls.enabled = false;
      }
    } else if (currentTool == TacticalTool.passArc) {
      final intersects = raycaster.intersectObjects(playersGroup.children, true);
      if (intersects.isNotEmpty) {
        final clickedPlayer = intersects.first.object;
        if (clickedPlayer != null) {
          if (firstSelectedPlayerForPass == null) {
            firstSelectedPlayerForPass = clickedPlayer;
          } else if (firstSelectedPlayerForPass != clickedPlayer) {
            _draw3DPassArcBetween(
              firstSelectedPlayerForPass!.position,
              clickedPlayer.position,
              colorHex: _colorToHex(currentColor),
            );
            firstSelectedPlayerForPass = null;
          }
        }
      }
    } else if (currentTool == TacticalTool.playerRun) {
      final intersects = raycaster.intersectObjects(playersGroup.children, true);
      if (intersects.isNotEmpty) {
        firstSelectedPlayerForRun = intersects.first.object;
      } else if (firstSelectedPlayerForRun != null) {
        three.Vector3 targetPoint = three.Vector3();
        if (raycaster.ray.intersectPlane(pitchPlane, targetPoint) != null) {
          _drawPlayerRunPath(
            firstSelectedPlayerForRun!.position,
            targetPoint,
            colorHex: _colorToHex(currentColor),
          );
          firstSelectedPlayerForRun = null;
        }
      }
    } else if (currentTool == TacticalTool.zoneDraw) {
      three.Vector3 targetPoint = three.Vector3();
      if (raycaster.ray.intersectPlane(pitchPlane, targetPoint) != null) {
        zoneDrawPoints.add(three.Vector2(targetPoint.x, targetPoint.z));

        if (zoneDrawPoints.length == 4) {
          _draw3DTacticalZoneMesh(
            polygonPoints: List.from(zoneDrawPoints),
            colorHex: _colorToHex(currentColor),
          );
          zoneDrawPoints.clear();
        }
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (povController.mode == CameraMode.firstPersonPov) {
      povController.handleLookRotation(event.delta);
      return;
    }

    if (currentTool == TacticalTool.select && interactivity?.isDragging == true) {
      interactivity?.onPointerMove(event.position);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (interactivity?.isDragging == true) {
      interactivity?.onPointerUp();
      controls.enabled = true;
    }
  }

  void _clearAllDrawings() {
    setState(() {
      drawingsGroup.clear();
      firstSelectedPlayerForPass = null;
      firstSelectedPlayerForRun = null;
      zoneDrawPoints.clear();
    });
  }

  int _colorToHex(Color color) {
    return color.toARGB32() & 0xFFFFFF;
  }

  void _draw3DPassArcBetween(three.Vector3 start, three.Vector3 end, {required int colorHex}) {
    final arcHeight = 12.0;
    final controlPoint = three.Vector3(
      (start.x + end.x) / 2,
      arcHeight,
      (start.z + end.z) / 2,
    );

    final curve = three.QuadraticBezierCurve3(start, controlPoint, end);
    final points = curve.getPoints(50);
    final geometry = three.BufferGeometry().setFromPoints(points);

    final lineMaterial = three.LineBasicMaterial()
      ..color = three.Color.fromHex32(colorHex)
      ..linewidth = 4.0;

    final arcLine = three.Line(geometry, lineMaterial);
    drawingsGroup.add(arcLine);

    final coneGeo = three.ConeGeometry(1.2, 3.0, 16);
    final coneMat = three.MeshBasicMaterial()
      ..color = three.Color.fromHex32(colorHex);
    final coneMesh = three.Mesh(coneGeo, coneMat);

    coneMesh.position.setValues(end.x, end.y, end.z);
    coneMesh.lookAt(end);
    coneMesh.rotation.x += 1.57;

    drawingsGroup.add(coneMesh);

    final shadowPoints = [
      three.Vector3(start.x, 0.02, start.z),
      three.Vector3(end.x, 0.02, end.z),
    ];
    final shadowGeo = three.BufferGeometry().setFromPoints(shadowPoints);
    final shadowMat = three.LineDashedMaterial()
      ..color = three.Color.fromHex32(0x000000)
      ..dashSize = 1.0
      ..gapSize = 0.5
      ..opacity = 0.4
      ..transparent = true;

    final shadowLine = three.Line(shadowGeo, shadowMat);
    drawingsGroup.add(shadowLine);
  }

  void _drawPlayerRunPath(three.Vector3 start, three.Vector3 target, {required int colorHex}) {
    final points = [
      three.Vector3(start.x, 0.2, start.z),
      three.Vector3(target.x, 0.2, target.z),
    ];
    final geometry = three.BufferGeometry().setFromPoints(points);
    final material = three.LineBasicMaterial()
      ..color = three.Color.fromHex32(colorHex)
      ..linewidth = 3.0;

    final line = three.Line(geometry, material);
    drawingsGroup.add(line);
  }

  void _draw3DTacticalZoneMesh({required List<three.Vector2> polygonPoints, required int colorHex}) {
    if (polygonPoints.length < 3) return;

    final shape = three.Shape();
    shape.moveTo(polygonPoints[0].x, polygonPoints[0].y);
    for (int i = 1; i < polygonPoints.length; i++) {
      shape.lineTo(polygonPoints[i].x, polygonPoints[i].y);
    }
    shape.closePath();

    final extrudeSettings = three.ExtrudeGeometryOptions(
      steps: 1,
      depth: 4.0,
      bevelEnabled: true,
      bevelThickness: 0.2,
      bevelSize: 0.2,
      bevelSegments: 3,
    );

    final geometry = three.ExtrudeGeometry([shape], extrudeSettings);
    final material = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(colorHex)
      ..transparent = true
      ..opacity = 0.35
      ..roughness = 0.3
      ..metalness = 0.1
      ..side = three.DoubleSide;

    final zoneMesh = three.Mesh(geometry, material);
    zoneMesh.rotation.x = math.pi / 2;
    zoneMesh.position.y = 4.0;

    drawingsGroup.add(zoneMesh);
  }

  void _setBroadcastCameraView() {
    isCameraTrackingBall = false;
    threeJs.camera.position.setValues(0, 45, 65);
    threeJs.camera.lookAt(three.Vector3(0, 0, 0));
    controls.target.setValues(0, 0, 0);
  }

  void _setTacticalTopDownView() {
    isCameraTrackingBall = false;
    threeJs.camera.position.setValues(0, 90, 0.1);
    threeJs.camera.lookAt(three.Vector3(0, 0, 0));
    controls.target.setValues(0, 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // A. طبقة الـ 3D Canvas
          Listener(
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            child: RepaintBoundary(
              key: pitchCanvasKey,
              child: threeJs.build(),
            ),
          ),

          // أزرار التحكم بالزوايا
          Positioned(
            top: 110,
            right: 20,
            child: Column(
              children: [
                _buildCameraButton(
                  icon: Icons.video_camera_back,
                  tooltip: "Broadcast View",
                  onPressed: () => setState(_setBroadcastCameraView),
                ),
                const SizedBox(height: 10),
                _buildCameraButton(
                  icon: Icons.center_focus_strong,
                  tooltip: "Top-Down Tactical",
                  onPressed: () => setState(_setTacticalTopDownView),
                ),
              ],
            ),
          ),

          // POV Control Bar Overlay
          buildPovControlBar(
            povController: povController,
            onStateChanged: () => setState(() {}),
          ),

          // قائمة أزرار التبديل السريع وتجربة الكرة
          Positioned(
            bottom: 105,
            left: 20,
            child: Row(
              children: [
                _buildFormationChip("4-3-3", () => animateToFormation("4-3-3")),
                const SizedBox(width: 10),
                _buildFormationChip("5-3-2", () => animateToFormation("5-3-2")),
                const SizedBox(width: 15),
                _buildPassTestButton(),
              ],
            ),
          ),

          // B. طبقة شريط الأدوات Dark Mode Overlay (ربط الأداة واللون والـ PDF)
          TacticalControlOverlay(
            isPlaying: isRecordingOrPlaying,
            onToolSelected: (tool) {
              setState(() {
                currentTool = tool;
                firstSelectedPlayerForPass = null;
                firstSelectedPlayerForRun = null;
              });
            },
            onColorSelected: (color) {
              setState(() {
                currentColor = color;
              });
            },
            onClearCanvas: _clearAllDrawings,
            onToggleAnimation: () {
              setState(() => isRecordingOrPlaying = !isRecordingOrPlaying);
              if (isRecordingOrPlaying) {
                animateToFormation("5-3-2");
              }
            },
            onExportPdf: _exportPdfReport,
            onSaveToCloud: _save3DStateToCloud,
          ),

          if (playbackEngine.frames.isNotEmpty)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: TimelineScrubberWidget(
                totalFrames: playbackEngine.frames.length,
                currentFrame: playbackEngine.currentFrameIndex,
                fps: playbackEngine.fps,
                isPlaying: playbackEngine.isPlaying,
                playbackSpeed: playbackEngine.playbackSpeed,
                onSeekToFrame: (frame) {
                  setState(() {
                    playbackEngine.seekToFrame(frame);
                  });
                },
                onTogglePlayPause: () {
                  setState(() {
                    if (playbackEngine.isPlaying) {
                      playbackEngine.pause();
                    } else {
                      playbackEngine.play();
                    }
                  });
                },
                onSpeedChanged: (speed) {
                  setState(() {
                    playbackEngine.setSpeed(speed);
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPassTestButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.sports_soccer, color: Colors.white),
      label: const Text("تمريرة للمهاجم 3D"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        final strikerPos = three.Vector3(35, 1.25, 0);
        passBallTo(targetPosition: strikerPos, arcHeight: 8.0);
      },
    );
  }

  Widget _buildCameraButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFormationChip(String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class TacticalControlOverlay extends StatefulWidget {
  final ValueChanged<TacticalTool> onToolSelected;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onClearCanvas;
  final VoidCallback onToggleAnimation;
  final VoidCallback onExportPdf;
  final VoidCallback? onSaveToCloud;
  final bool isPlaying;

  const TacticalControlOverlay({
    super.key,
    required this.onToolSelected,
    required this.onColorSelected,
    required this.onClearCanvas,
    required this.onToggleAnimation,
    required this.onExportPdf,
    this.onSaveToCloud,
    required this.isPlaying,
  });

  @override
  State<TacticalControlOverlay> createState() => _TacticalControlOverlayState();
}

class _TacticalControlOverlayState extends State<TacticalControlOverlay> {
  TacticalTool selectedTool = TacticalTool.select;
  Color selectedColor = const Color(0xFFFACC15);

  final List<Color> colorPalette = [
    const Color(0xFFFACC15),
    const Color(0xFFEF4444),
    const Color(0xFF3B82F6),
    const Color(0xFF22C55E),
    const Color(0xFFFFFFFF),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 45,
          left: 20,
          right: 20,
          child: _buildGlassPanel(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.sports_soccer, color: Color(0xFF38BDF8)),
                    SizedBox(width: 8),
                    Text(
                      "CAPTAIN 3D",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (widget.onSaveToCloud != null) ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_upload, color: Colors.white, size: 18),
                        label: const Text("حفظ التكتيك في السحابة"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: widget.onSaveToCloud,
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                      label: const Text("تصدير التقرير PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: widget.onExportPdf,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        widget.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        color: const Color(0xFF38BDF8),
                        size: 32,
                      ),
                      onPressed: widget.onToggleAnimation,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 12),
                          SizedBox(width: 4),
                          Text(
                            "REC",
                            style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Row(
            children: [
              Expanded(
                child: _buildGlassPanel(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildToolButton(
                        icon: Icons.near_me,
                        label: "تحديد",
                        tool: TacticalTool.select,
                      ),
                      _buildToolButton(
                        icon: Icons.gesture,
                        label: "تمريرة 3D",
                        tool: TacticalTool.passArc,
                      ),
                      _buildToolButton(
                        icon: Icons.alt_route,
                        label: "مسار جري",
                        tool: TacticalTool.playerRun,
                      ),
                      _buildToolButton(
                        icon: Icons.polyline,
                        label: "منطقة ضغط",
                        tool: TacticalTool.zoneDraw,
                      ),
                      const VerticalDivider(color: Colors.white24, indent: 8, endIndent: 8),
                      IconButton(
                        icon: const Icon(Icons.cleaning_services_outlined, color: Colors.redAccent),
                        tooltip: "مسح الكل",
                        onPressed: widget.onClearCanvas,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildGlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: colorPalette.map((color) => _buildColorDot(color)).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassPanel({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required TacticalTool tool,
  }) {
    final isSelected = selectedTool == tool;
    return InkWell(
      onTap: () {
        setState(() => selectedTool = tool);
        widget.onToolSelected(tool);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: const Color(0xFF38BDF8)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF38BDF8) : Colors.white70,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() => selectedColor = color);
        widget.onColorSelected(color);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
              : null,
        ),
      ),
    );
  }
}
