import React, { useState, useEffect } from 'react';
import { Sparkles, ShieldAlert, Cpu, ArrowUpRight, Check, Layers } from 'lucide-react';

export default function AIScoutingReport({ jobId, matchId, onApplyTactics }) {
  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(true);
  const [applied, setApplied] = useState(false);

  useEffect(() => {
    async function fetchReport() {
      try {
        setLoading(true);
        const res = await fetch(`/api/v1/vision/scouting-report/${jobId}`);
        const data = await res.json();
        setReport(data);
      } catch (err) {
        console.error('Failed to load scouting report', err);
      } finally {
        setLoading(false);
      }
    }
    if (jobId) fetchReport();
  }, [jobId]);

  if (loading) {
    return (
      <div className="p-8 bg-slate-900/60 border border-slate-800 rounded-2xl flex flex-col items-center justify-center text-center">
        <Sparkles className="w-8 h-8 text-emerald-400 animate-pulse mb-3" />
        <h4 className="text-sm font-semibold text-white">Synthesizing Claude AI Scouting Report...</h4>
        <p className="text-xs text-slate-400">Evaluating spatial compactness, press triggers, and transitions.</p>
      </div>
    );
  }

  if (!report) return null;

  return (
    <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 flex flex-col space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between border-b border-slate-800 pb-4">
        <div className="flex items-center space-x-3">
          <div className="p-2 bg-emerald-500/10 text-emerald-400 rounded-lg">
            <Cpu className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-base font-bold text-white">AI Tactical Intelligence & Scouting</h3>
            <p className="text-xs text-slate-400">Formation Suggested: {report.counter_formation}</p>
          </div>
        </div>

        <button
          onClick={() => {
            if (onApplyTactics) {
              onApplyTactics(report.tactical_nodes);
            }
            setApplied(true);
          }}
          disabled={applied}
          className="flex items-center space-x-2 px-4 py-2 bg-emerald-600 hover:bg-emerald-500 active:scale-95 text-white rounded-lg text-xs font-semibold shadow-lg shadow-emerald-900/20 transition disabled:opacity-50"
        >
          {applied ? <Check className="w-4 h-4" /> : <Layers className="w-4 h-4" />}
          <span>{applied ? 'Applied to Whiteboard' : 'Apply to Board'}</span>
        </button>
      </div>

      {/* Overview & Pressing Vulnerability */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="p-4 bg-slate-950/60 rounded-xl border border-slate-800/80">
          <div className="flex items-center space-x-2 text-emerald-400 text-xs font-semibold uppercase mb-2">
            <Sparkles className="w-4 h-4" />
            <span>Executive Assessment</span>
          </div>
          <p className="text-xs text-slate-300 leading-relaxed">{report.summary}</p>
        </div>

        <div className="p-4 bg-slate-950/60 rounded-xl border border-slate-800/80">
          <div className="flex items-center space-x-2 text-amber-400 text-xs font-semibold uppercase mb-2">
            <ShieldAlert className="w-4 h-4" />
            <span>Identified Vulnerability</span>
          </div>
          <p className="text-xs text-slate-300 leading-relaxed">{report.pressing_vulnerability}</p>
        </div>
      </div>

      {/* Recommended Tactical Response */}
      <div className="p-4 bg-emerald-950/20 border border-emerald-800/30 rounded-xl">
        <h4 className="text-xs font-semibold text-emerald-300 uppercase tracking-wide mb-1">
          Counter-Strategy Blueprint
        </h4>
        <p className="text-xs text-slate-300 leading-relaxed">{report.recommended_strategy}</p>
      </div>
    </div>
  );
}
