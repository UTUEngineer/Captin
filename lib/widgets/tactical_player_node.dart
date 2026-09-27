import 'package:three_js/three_js.dart' as three;

class TacticalPlayerNode {
  late three.Group rootNode;
  three.AnimationMixer? mixer;
  Map<String, three.AnimationClip> animations = {};
  three.AnimationAction? currentAction;

  final String playerId;
  final int shirtNumber;
  final three.Color teamColor;

  TacticalPlayerNode({
    required this.playerId,
    required this.shirtNumber,
    required this.teamColor,
  }) {
    rootNode = three.Group();
    rootNode.name = "player_$playerId";
  }

  Future<void> loadModel(String assetPath) async {
    try {
      final loader = three.GLTFLoader();
      final gltf = await loader.fromAsset(assetPath);

      if (gltf != null) {
        final model = gltf.scene;
        model.scale.setValues(0.8, 0.8, 0.8);
        rootNode.add(model);

        // Setup Animations (Idle, Run, Pass, Sprint)
        mixer = three.AnimationMixer(model);
        if (gltf.animations != null) {
          for (final clip in gltf.animations!) {
            animations[clip.name] = clip;
          }
        }

        // Play default Idle animation
        playAnimation('idle');

        // Customize Kit Materials & Floating Tag
        _applyTeamColor(model);
      }
    } catch (e) {
      // Fallback: create default cylinder mesh if model loading is unavailable
      final cylinderGeo = three.CylinderGeometry(1.2, 1.2, 2.5, 16);
      final material = three.MeshStandardMaterial()
        ..color = teamColor
        ..metalness = 0.2
        ..roughness = 0.3;
      final cylinderMesh = three.Mesh(cylinderGeo, material);
      cylinderMesh.position.setValues(0, 1.25, 0);
      rootNode.add(cylinderMesh);
    }

    _attachJerseyTag();
  }

  void _applyTeamColor(three.Object3D model) {
    model.traverse((child) {
      if (child is three.Mesh && child.name.contains("Kit_Jersey")) {
        child.material = three.MeshStandardMaterial()
          ..color = teamColor
          ..roughness = 0.4
          ..metalness = 0.1;
      }
    });
  }

  void _attachJerseyTag() {
    // 3D Billboard Tag for Player Number
    final spriteMat = three.SpriteMaterial()
      ..color = three.Color.fromHex32(0xffffff)
      ..depthTest = false;
    final sprite = three.Sprite(spriteMat);
    sprite.position.setValues(0, 2.2, 0); // Position above head
    sprite.scale.setValues(1.0, 0.5, 1.0);
    rootNode.add(sprite);
  }

  void playAnimation(String name) {
    if (mixer == null || !animations.containsKey(name)) return;

    final clip = animations[name]!;
    final newAction = mixer!.clipAction(clip);

    if (newAction != null) {
      if (currentAction != null && currentAction != newAction) {
        currentAction!.fadeOut(0.2);
      }

      newAction
        ..reset()
        ..fadeIn(0.2)
        ..play();

      currentAction = newAction;
    }
  }

  void update(double delta) {
    mixer?.update(delta);
  }
}
