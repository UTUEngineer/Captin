import React, { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';
import { Video, Sparkles, AlertCircle, CheckCircle2, Loader2, ArrowLeft } from 'lucide-react';
import PitchHomographyCalibration from './PitchHomographyCalibration';
import AIScoutingReport from './AIScoutingReport';

// Initialize Supabase Client
const supabase = createClient(
  process.env.REACT_APP_SUPABASE_URL || 'https://your-supabase-id.supabase.co',
  process.env.REACT_APP_SUPABASE_ANON_KEY || 'your-anon-key'
);

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8000';

export default function AppWithAuth({ matchId = '00000000-0000-0000-0000-000000000000' }) {
  // Application Modes: 'idle' | 'calibrating' | 'uploading' | 'processing' | 'completed' | 'error'
  const [pipelineState, setPipelineState] = useState('idle');
  const [selectedFile, setSelectedFile] = useState(null);
  const [videoPreviewUrl, setVideoPreviewUrl] = useState(null);
  const [activeJobId, setActiveJobId] = useState(null);
  
  // Progress & Status Indicators
  const [uploadProgress, setUploadProgress] = useState(0);
  const [inferenceProgress, setInferenceProgress] = useState(0);
  const [statusMessage, setStatusMessage] = useState('');
  const [errorMessage, setErrorMessage] = useState(null);

  // 1. Handle File Selection
  const handleFileChange = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('video/')) {
      setErrorMessage('Please select a valid MP4 or MOV video file.');
      return;
    }

    setSelectedFile(file);
    setVideoPreviewUrl(URL.createObjectURL(file));
    setPipelineState('calibrating');
    setErrorMessage(null);
  };

  // 2. Realtime Subscription to Supabase `video_analysis_jobs`
  useEffect(() => {
    if (!activeJobId) return;

    const channel = supabase
      .channel(`job-status-${activeJobId}`)
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'video_analysis_jobs',
          filter: `id=eq.${activeJobId}`,
        },
        (payload) => {
          const { status, progress, error_message } = payload.new;

          if (status === 'processing') {
            setPipelineState('processing');
            setInferenceProgress(progress || 0);
            setStatusMessage(`Analyzing frames & running ByteTrack (${progress || 0}%)...`);
          } else if (status === 'completed') {
            setPipelineState('completed');
            setInferenceProgress(100);
            setStatusMessage('Tactical tracking data ready!');
          } else if (status === 'failed') {
            setPipelineState('error');
            setErrorMessage(error_message || 'Inference failed on GPU worker.');
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [activeJobId]);

  // 3. Initiate Upload + Trigger Processing
  const handleCalibrationComplete = async ({ calibrationPoints, sourceDimensions }) => {
    if (!selectedFile) return;

    try {
      setPipelineState('uploading');
      setStatusMessage('Requesting secure upload authorization...');
      setErrorMessage(null);

      const fileExtension = selectedFile.name.split('.').pop() || 'mp4';

      // Step A: Request Presigned URL from FastAPI Gateway
      const initResponse = await fetch(`${API_BASE_URL}/api/v1/vision/initiate-analysis`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          match_id: matchId,
          file_extension: fileExtension,
          calibration_points: calibrationPoints,
        }),
      });

      if (!initResponse.ok) {
        throw new Error(`Failed to initiate job: ${await initResponse.text()}`);
      }

      const { job_id, upload_url } = await initResponse.json();
      setActiveJobId(job_id);

      // Step B: Direct Binary Upload to Cloudflare R2 / S3 via XHR (for progress tracking)
      setStatusMessage('Uploading match video to cloud storage...');
      await uploadToStorage(upload_url, selectedFile, (percent) => {
        setUploadProgress(percent);
      });

      // Step C: Trigger Backend Inference Queue
      setStatusMessage('Video received. Enqueueing GPU inference worker...');
      const triggerResponse = await fetch(`${API_BASE_URL}/api/v1/vision/process/${job_id}`, {
        method: 'POST',
      });

      if (!triggerResponse.ok) {
        throw new Error(`Failed to trigger worker: ${await triggerResponse.text()}`);
      }

      setPipelineState('processing');
      setStatusMessage('GPU worker assigned. Starting YOLO player tracking...');
    } catch (err) {
      console.error('Pipeline error:', err);
      setPipelineState('error');
      setErrorMessage(err.message || 'An unexpected error occurred during processing.');
    }
  };

  // Helper for Presigned PUT with Progress Tracking
  const uploadToStorage = (url, file, onProgress) => {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('PUT', url, true);
      xhr.setRequestHeader('Content-Type', file.type);

      xhr.upload.onprogress = (e) => {
        if (e.lengthComputable) {
          const percent = Math.round((e.loaded / e.total) * 100);
          onProgress(percent);
        }
      };

      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          resolve();
        } else {
          reject(new Error(`Storage upload failed with HTTP status ${xhr.status}`));
        }
      };

      xhr.onerror = () => reject(new Error('Network error during storage upload.'));
      xhr.send(file);
    });
  };

  const handleReset = () => {
    if (videoPreviewUrl) URL.revokeObjectURL(videoPreviewUrl);
    setSelectedFile(null);
    setVideoPreviewUrl(null);
    setActiveJobId(null);
    setPipelineState('idle');
    setUploadProgress(0);
    setInferenceProgress(0);
    setErrorMessage(null);
  };

  return (
    <div className="min-h-screen w-full bg-slate-950 text-slate-100 flex flex-col items-center p-6">
      {/* Top Header */}
      <header className="w-full max-w-6xl flex items-center justify-between pb-6 mb-6 border-b border-slate-800">
        <div className="flex items-center space-x-3">
          <div className="p-2.5 bg-emerald-500/10 rounded-xl border border-emerald-500/20 text-emerald-400">
            <Sparkles className="w-6 h-6" />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-tight text-white">Captain AI Video Hub</h1>
            <p className="text-xs text-slate-400 font-mono">Match ID: {matchId}</p>
          </div>
        </div>

        {pipelineState !== 'idle' && (
          <button
            onClick={handleReset}
            className="flex items-center space-x-2 px-3 py-1.5 text-xs font-medium text-slate-400 hover:text-slate-200 bg-slate-900 border border-slate-800 hover:bg-slate-800 rounded-lg transition"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Upload New Clip</span>
          </button>
        )}
      </header>

      {/* Main Container */}
      <main className="w-full max-w-6xl flex-1 flex flex-col items-center justify-center">
        {/* Error Notification */}
        {errorMessage && (
          <div className="w-full mb-6 p-4 bg-red-950/40 border border-red-800/60 rounded-xl flex items-center space-x-3 text-red-300 text-sm">
            <AlertCircle className="w-5 h-5 flex-shrink-0 text-red-400" />
            <span>{errorMessage}</span>
          </div>
        )}

        {/* 1. IDLE STATE: File Dropzone */}
        {pipelineState === 'idle' && (
          <div className="w-full max-w-xl p-10 border-2 border-dashed border-slate-800 hover:border-emerald-500/50 rounded-2xl bg-slate-900/40 hover:bg-slate-900/80 transition-all flex flex-col items-center text-center group cursor-pointer relative">
            <input
              type="file"
              accept="video/mp4,video/quicktime"
              onChange={handleFileChange}
              className="absolute inset-0 opacity-0 cursor-pointer"
            />
            <div className="p-4 bg-slate-800 group-hover:bg-emerald-500/20 text-slate-400 group-hover:text-emerald-400 rounded-2xl transition-colors mb-4">
              <Video className="w-8 h-8" />
            </div>
            <h3 className="text-base font-semibold text-white mb-1">Select Tactical Match Clip</h3>
            <p className="text-xs text-slate-400 mb-4 max-w-sm">
              Upload match footage (MP4, MOV). You will calibrate 4 pitch corners before AI inference begins.
            </p>
            <span className="px-4 py-2 bg-slate-800 text-slate-300 rounded-lg text-xs font-medium group-hover:bg-emerald-600 group-hover:text-white transition">
              Browse Files
            </span>
          </div>
        )}

        {/* 2. CALIBRATION STATE: Homography Overlay */}
        {pipelineState === 'calibrating' && videoPreviewUrl && (
          <div className="w-full h-[650px]">
            <PitchHomographyCalibration
              videoSrc={videoPreviewUrl}
              onCalibrationComplete={handleCalibrationComplete}
              onCancel={handleReset}
            />
          </div>
        )}

        {/* 3. UPLOADING & GPU PROCESSING STATE */}
        {(pipelineState === 'uploading' || pipelineState === 'processing') && (
          <div className="w-full max-w-md p-8 bg-slate-900/60 border border-slate-800 rounded-2xl flex flex-col items-center text-center">
            <Loader2 className="w-10 h-10 text-emerald-400 animate-spin mb-4" />
            <h3 className="text-base font-semibold text-white mb-2">
              {pipelineState === 'uploading' ? 'Uploading Match Video' : 'Running GPU Computer Vision'}
            </h3>
            <p className="text-xs text-slate-400 mb-6 font-mono">{statusMessage}</p>

            {/* Upload or Inference Progress Bar */}
            <div className="w-full bg-slate-800 h-2 rounded-full overflow-hidden mb-2">
              <div
                className="bg-emerald-500 h-full transition-all duration-300 ease-out"
                style={{
                  width: `${pipelineState === 'uploading' ? uploadProgress : inferenceProgress}%`,
                }}
              />
            </div>
            <span className="text-[11px] font-mono text-slate-500">
              {pipelineState === 'uploading' ? `${uploadProgress}% Uploaded` : `${inferenceProgress}% Analyzed`}
            </span>
          </div>
        )}

        {/* 4. COMPLETED STATE */}
        {pipelineState === 'completed' && (
          <div className="w-full max-w-4xl flex flex-col space-y-6">
            <div className="p-8 bg-slate-900/60 border border-emerald-500/30 rounded-2xl flex flex-col items-center text-center">
              <div className="p-3 bg-emerald-500/10 text-emerald-400 rounded-full mb-4">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <h3 className="text-lg font-semibold text-white mb-1">Analysis Complete</h3>
              <p className="text-xs text-slate-400 mb-6">
                Player tracking coordinates and transformed 2D pitch telemetry have been written to Supabase.
              </p>
              <div className="flex space-x-3 w-full max-w-md">
                <button
                  onClick={handleReset}
                  className="flex-1 py-2.5 px-4 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg text-xs font-semibold transition"
                >
                  Analyze Another
                </button>
                <button
                  onClick={() => {
                    window.location.href = `/board?matchId=${matchId}&jobId=${activeJobId}`;
                  }}
                  className="flex-1 py-2.5 px-4 bg-emerald-600 hover:bg-emerald-500 text-white rounded-lg text-xs font-semibold shadow-lg shadow-emerald-900/30 transition"
                >
                  View on Tactical Board
                </button>
              </div>
            </div>

            {/* Claude AI Scouting Report Card & One-Click Tactical Board Injection */}
            {activeJobId && (
              <AIScoutingReport
                jobId={activeJobId}
                matchId={matchId}
                onApplyTactics={(nodes) => {
                  console.log('Applied AI tactical nodes to whiteboard:', nodes);
                }}
              />
            )}
          </div>
        )}
      </main>
    </div>
  );
}
