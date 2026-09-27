import React, { useState, useRef, useEffect, useCallback } from 'react';
import { Upload, Check, RotateCcw, Crosshair, Play, Pause, ZoomIn } from 'lucide-react';

const CORNER_LABELS = [
  { id: 'TL', name: 'Top-Left (Corner Flag)', color: '#EF4444' },     // Red
  { id: 'TR', name: 'Top-Right (Corner Flag)', color: '#3B82F6' },    // Blue
  { id: 'BR', name: 'Bottom-Right (Corner Flag)', color: '#10B981' }, // Green
  { id: 'BL', name: 'Bottom-Left (Corner Flag)', color: '#F59E0B' }   // Amber
];

const HANDLE_RADIUS = 8;
const HIT_SLOP = 18;

export default function PitchHomographyCalibration({ 
  videoSrc, 
  onCalibrationComplete, 
  onCancel 
}) {
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const containerRef = useRef(null);

  const [points, setPoints] = useState([]); // [{x, y}] in native video pixel space
  const [activeDragIndex, setActiveDragIndex] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [videoDimensions, setVideoDimensions] = useState({ width: 0, height: 0 });
  const [canvasScale, setCanvasScale] = useState({ x: 1, y: 1 });
  const [magnifier, setMagnifier] = useState({ visible: false, x: 0, y: 0, canvasX: 0, canvasY: 0 });

  // Update canvas sizing and scaling relative to intrinsic video size
  const updateLayout = useCallback(() => {
    if (!videoRef.current || !canvasRef.current) return;
    const video = videoRef.current;
    const canvas = canvasRef.current;

    const displayWidth = video.clientWidth;
    const displayHeight = video.clientHeight;

    canvas.width = displayWidth;
    canvas.height = displayHeight;

    if (video.videoWidth > 0 && video.videoHeight > 0) {
      setVideoDimensions({ width: video.videoWidth, height: video.videoHeight });
      setCanvasScale({
        x: displayWidth / video.videoWidth,
        y: displayHeight / video.videoHeight
      });
    }
  }, []);

  useEffect(() => {
    window.addEventListener('resize', updateLayout);
    return () => window.removeEventListener('resize', updateLayout);
  }, [updateLayout]);

  const handleLoadedMetadata = () => {
    updateLayout();
    if (videoRef.current) {
      videoRef.current.currentTime = 0.5; // Seek past initial black frame
    }
  };

  // Convert Screen/Canvas coords to Native Video Pixels
  const canvasToVideoCoords = useCallback((cx, cy) => {
    return {
      x: Math.round(cx / canvasScale.x),
      y: Math.round(cy / canvasScale.y)
    };
  }, [canvasScale]);

  // Convert Native Video Pixels to Canvas display coords
  const videoToCanvasCoords = useCallback((vx, vy) => {
    return {
      x: vx * canvasScale.x,
      y: vy * canvasScale.y
    };
  }, [canvasScale]);

  // Draw homography boundary polygon, handles, and active step cues
  const renderCanvas = useCallback(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    if (points.length === 0) return;

    const canvasPts = points.map(pt => videoToCanvasCoords(pt.x, pt.y));

    // 1. Draw connecting polygon/lines
    if (canvasPts.length > 1) {
      ctx.beginPath();
      ctx.moveTo(canvasPts[0].x, canvasPts[0].y);
      for (let i = 1; i < canvasPts.length; i++) {
        ctx.lineTo(canvasPts[i].x, canvasPts[i].y);
      }
      if (canvasPts.length === 4) {
        ctx.closePath();
        ctx.fillStyle = 'rgba(16, 185, 129, 0.15)'; // Semi-transparent pitch zone
        ctx.fill();
      }
      ctx.strokeStyle = '#10B981';
      ctx.lineWidth = 2;
      ctx.setLineDash([6, 4]);
      ctx.stroke();
      ctx.setLineDash([]);
    }

    // 2. Draw interactive corner points & crosshairs
    canvasPts.forEach((pt, index) => {
      const config = CORNER_LABELS[index];
      
      // Outer ring
      ctx.beginPath();
      ctx.arc(pt.x, pt.y, HANDLE_RADIUS, 0, Math.PI * 2);
      ctx.fillStyle = config.color;
      ctx.fill();
      ctx.strokeStyle = '#FFFFFF';
      ctx.lineWidth = 2;
      ctx.stroke();

      // Crosshair lines inside node
      ctx.beginPath();
      ctx.moveTo(pt.x - 12, pt.y);
      ctx.lineTo(pt.x + 12, pt.y);
      ctx.moveTo(pt.x, pt.y - 12);
      ctx.lineTo(pt.x, pt.y + 12);
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.8)';
      ctx.lineWidth = 1.5;
      ctx.stroke();

      // Label badge
      ctx.font = 'bold 11px Inter, sans-serif';
      ctx.fillStyle = '#FFFFFF';
      ctx.shadowColor = 'rgba(0,0,0,0.8)';
      ctx.shadowBlur = 4;
      ctx.fillText(`${config.id}`, pt.x + 12, pt.y - 8);
      ctx.shadowBlur = 0;
    });
  }, [points, videoToCanvasCoords]);

  useEffect(() => {
    renderCanvas();
  }, [renderCanvas]);

  // Pointer Interactions for placement and dragging
  const getCanvasOffset = (e) => {
    const rect = canvasRef.current.getBoundingClientRect();
    return {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top
    };
  };

  const handlePointerDown = (e) => {
    const { x, y } = getCanvasOffset(e);

    // Check if dragging an existing point
    const clickedIndex = points.findIndex(pt => {
      const cpt = videoToCanvasCoords(pt.x, pt.y);
      const distance = Math.hypot(cpt.x - x, cpt.y - y);
      return distance <= HIT_SLOP;
    });

    if (clickedIndex !== -1) {
      setActiveDragIndex(clickedIndex);
      setMagnifier({ visible: true, x: points[clickedIndex].x, y: points[clickedIndex].y, canvasX: x, canvasY: y });
      return;
    }

    // Otherwise place next sequential point up to 4
    if (points.length < 4) {
      const videoPt = canvasToVideoCoords(x, y);
      const updated = [...points, videoPt];
      setPoints(updated);
      setMagnifier({ visible: true, x: videoPt.x, y: videoPt.y, canvasX: x, canvasY: y });
    }
  };

  const handlePointerMove = (e) => {
    if (activeDragIndex === null) return;
    const { x, y } = getCanvasOffset(e);
    const videoPt = canvasToVideoCoords(x, y);

    // Clamp coordinates inside intrinsic video bounds
    const clampedPt = {
      x: Math.max(0, Math.min(videoDimensions.width, videoPt.x)),
      y: Math.max(0, Math.min(videoDimensions.height, videoPt.y))
    };

    setPoints(prev => {
      const next = [...prev];
      next[activeDragIndex] = clampedPt;
      return next;
    });

    setMagnifier({ visible: true, x: clampedPt.x, y: clampedPt.y, canvasX: x, canvasY: y });
  };

  const handlePointerUp = () => {
    setActiveDragIndex(null);
    setMagnifier(prev => ({ ...prev, visible: false }));
  };

  const togglePlayback = () => {
    if (!videoRef.current) return;
    if (isPlaying) {
      videoRef.current.pause();
    } else {
      videoRef.current.play();
    }
    setIsPlaying(!isPlaying);
  };

  const handleReset = () => {
    setPoints([]);
    renderCanvas();
  };

  const handleSave = () => {
    if (points.length !== 4) return;
    // Format points in standard matrix order: [TL, TR, BR, BL]
    const homographyPoints = points.map(p => [p.x, p.y]);
    onCalibrationComplete({
      calibrationPoints: homographyPoints,
      sourceDimensions: videoDimensions
    });
  };

  return (
    <div className="flex flex-col h-full w-full bg-slate-950 text-slate-100 rounded-xl overflow-hidden border border-slate-800">
      {/* Top Header & Instructions */}
      <div className="flex items-center justify-between px-6 py-4 border-b border-slate-800 bg-slate-900/60">
        <div className="flex items-center space-x-3">
          <div className="p-2 bg-emerald-500/10 text-emerald-400 rounded-lg">
            <Crosshair className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-sm font-semibold tracking-wide uppercase text-slate-200">
              Pitch Homography Calibration
            </h2>
            <p className="text-xs text-slate-400">
              {points.length < 4 
                ? `Click corner: ${CORNER_LABELS[points.length].name}`
                : "Drag corner handles to align with the touchlines"}
            </p>
          </div>
        </div>

        {/* Step Progression Pills */}
        <div className="flex items-center space-x-2">
          {CORNER_LABELS.map((corner, i) => (
            <div 
              key={corner.id}
              className={`flex items-center space-x-1.5 px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
                points[i] 
                  ? 'bg-slate-800 border-slate-700 text-slate-200' 
                  : i === points.length 
                    ? 'bg-emerald-500/10 border-emerald-500/40 text-emerald-400 animate-pulse' 
                    : 'bg-slate-900/40 border-slate-800 text-slate-500'
              }`}
            >
              <span className="w-2 h-2 rounded-full" style={{ backgroundColor: corner.color }} />
              <span>{corner.id}</span>
              {points[i] && <Check className="w-3 h-3 text-emerald-400 ml-1" />}
            </div>
          ))}
        </div>
      </div>

      {/* Video Viewport & Calibration Canvas */}
      <div 
        ref={containerRef} 
        className="relative flex-1 flex items-center justify-center bg-black/95 overflow-hidden select-none"
      >
        <video
          ref={videoRef}
          src={videoSrc}
          className="max-h-full max-w-full object-contain pointer-events-none"
          onLoadedMetadata={handleLoadedMetadata}
          playsInline
          muted
        />

        <canvas
          ref={canvasRef}
          className="absolute inset-0 m-auto max-h-full max-w-full cursor-crosshair touch-none"
          onPointerDown={handlePointerDown}
          onPointerMove={handlePointerMove}
          onPointerUp={handlePointerUp}
          onPointerLeave={handlePointerUp}
        />

        {/* Precision Magnifier Loupe */}
        {magnifier.visible && (
          <div 
            className="absolute pointer-events-none border-2 border-white rounded-full shadow-2xl overflow-hidden bg-black z-30"
            style={{
              width: 130,
              height: 130,
              left: Math.max(10, Math.min(magnifier.canvasX - 65, (canvasRef.current?.width || 200) - 140)),
              top: Math.max(10, magnifier.canvasY - 150),
            }}
          >
            <div 
              className="absolute w-[800%] h-[800%]"
              style={{
                backgroundImage: `url(${videoSrc})`,
                transform: `translate(-${(magnifier.x / videoDimensions.width) * 100}%, -${(magnifier.y / videoDimensions.height) * 100}%)`,
                transformOrigin: 'top left'
              }}
            />
            {/* Loupe Reticle */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="w-4 h-0.5 bg-emerald-400 opacity-80" />
              <div className="h-4 w-0.5 bg-emerald-400 opacity-80 absolute" />
              <div className="w-2 h-2 border border-emerald-400 rounded-full absolute" />
            </div>
            <div className="absolute bottom-1.5 inset-x-0 text-[10px] text-center font-mono text-slate-300 bg-black/60 py-0.5">
              {magnifier.x}, {magnifier.y} px
            </div>
          </div>
        )}
      </div>

      {/* Playback Scrubbing & Execution Controls */}
      <div className="flex items-center justify-between px-6 py-3 border-t border-slate-800 bg-slate-900/80">
        <div className="flex items-center space-x-3">
          <button
            onClick={togglePlayback}
            className="p-2 bg-slate-800 hover:bg-slate-700 active:scale-95 text-slate-200 rounded-lg transition"
            title={isPlaying ? "Pause Video" : "Play Video"}
          >
            {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4" />}
          </button>
          <span className="text-xs text-slate-400 font-mono">
            {videoDimensions.width > 0 ? `${videoDimensions.width} × ${videoDimensions.height} px` : 'Loading video...'}
          </span>
        </div>

        <div className="flex items-center space-x-3">
          <button
            onClick={handleReset}
            disabled={points.length === 0}
            className="flex items-center space-x-1.5 px-3 py-2 text-xs font-medium text-slate-400 hover:text-slate-200 bg-slate-800/60 hover:bg-slate-800 rounded-lg transition disabled:opacity-40 disabled:pointer-events-none"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            <span>Reset Points</span>
          </button>

          {onCancel && (
            <button
              onClick={onCancel}
              className="px-4 py-2 text-xs font-medium text-slate-400 hover:text-slate-200 transition"
            >
              Cancel
            </button>
          )}

          <button
            onClick={handleSave}
            disabled={points.length !== 4}
            className="flex items-center space-x-2 px-5 py-2 text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-500 active:scale-95 rounded-lg shadow-lg shadow-emerald-900/30 transition disabled:opacity-40 disabled:pointer-events-none"
          >
            <Check className="w-4 h-4" />
            <span>Confirm & Start Inference</span>
          </button>
        </div>
      </div>
    </div>
  );
}
