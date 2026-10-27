# Captain — changes to apply (Captin-new → Captin-main)

Source of truth: `C:\Users\ayoan\Downloads\Captin-new` (verified: `flutter analyze` 0 issues, `flutter test` 77/77).
Target: `C:\Users\ayoan\Downloads\Captin-main` (original: 0 issues, 62/62 tests).

## Fastest way
Copy these from Captin-new into Captin-main, overwriting:
`lib/`, `test/`, `assets/`, `vision_backend/`, `pubspec.yaml`
Then run:
```
flutter pub get
flutter analyze
flutter test
```
Expect 0 issues and 77 passing tests. (No need to run build_runner — the regenerated
`*.freezed.dart` / `*.g.dart` files are already in Captin-new.)
Do NOT copy: `build/`, `.dart_tool/`, `_claude_backup/`, `_to_delete/`.

## What changed (by feature)
1. **Tactical board** — drag & drop rewritten (pan gestures, no long-press; the old
   DragTarget sat under the pitch layer so drops never landed). Live shape simulation for
   both teams. Arrow tools: pass, run, dribble, shot, press, curve, line (animated).
   Zones: rectangle, free-hand polygon, circle. Box-select, group move, Ctrl+A / Delete / Esc.
   Ball object. Teams placed in their own halves. Horizontal pitch now draws goals left/right.
2. **Presentation mode** — stage spotlight + player info card, ←/→ stepping, auto tour, playback.
3. **Detection backend** (`vision_backend/`) — YOLOv8 + ByteTrack, players + ball, team colours,
   homography (calibration now in metres), distance / speed / sprints / heatmaps / possession.
   App shows ball + team totals. See `vision_backend/README.md`.
4. **Animation** — phase-based tactic playback (`tactic_playback.dart`) with scrubber, speed, loop.
5. **Leagues** — overview, full table (GD, form, zones), fixtures by round, top scorers/assists,
   team sheet with squad; offline sample season for Iraq Stars League (labelled "sample data").
6. **3D players** — `assets/models/footballer.glb` (idle/run/sprint/kick) rendered with three_js
   in `board_3d_view.dart`; opened from the board (cube icon) and the 3D hub.
7. **Theme** — `AppColors` is now palette-driven (light / dark / black / auto) via
   `CaptainPalette` + `PaletteScope`; hardcoded colours in ~70 screens replaced by tokens.
8. **Toolkit** — floating, draggable, dockable, collapsible panel (`board_toolkit.dart`).
9. **Simulation fix** — see 1; plus "opponents react" toggle and "Reset shape".
10. **Intro video** — `assets/video/intro.mp4`, `intro_video_screen.dart`, initial route `/intro`.

## Files
### New files (copy as-is)
```
assets/models/footballer.glb
assets/video/intro.mp4
lib/core/theme/palette_scope.dart
lib/features/home/presentation/intro_video_screen.dart
lib/features/leagues/domain/sample_season.dart
lib/features/leagues/presentation/widgets/league_widgets.dart
lib/features/leagues/presentation/widgets/overview_tab.dart
lib/features/leagues/presentation/widgets/scorers_tab.dart
lib/features/leagues/presentation/widgets/team_detail_sheet.dart
lib/features/tactical_board/application/tactic_playback.dart
lib/features/tactical_board/domain/board_ball.dart
lib/features/tactical_board/presentation/board_3d_screen.dart
lib/features/tactical_board/presentation/widgets/ball_token.dart
lib/features/tactical_board/presentation/widgets/board_3d_view.dart
lib/features/tactical_board/presentation/widgets/board_toolkit.dart
lib/features/tactical_board/presentation/widgets/playback_bar.dart
vision_backend/README.md
vision_backend/captain_vision/__init__.py
vision_backend/captain_vision/analytics.py
vision_backend/captain_vision/pipeline.py
vision_backend/tests/test_analytics.py
```

### New tests
```
test/features/leagues/sample_season_test.dart
test/features/video_analysis/analysis_ball_test.dart
test/tactical_board_playback_test.dart
```

### Modified files (overwrite with the Captin-new version)
```
lib/core/api/football_api_client.dart
lib/core/router/app_router.dart
lib/core/theme/app_colors.dart
lib/core/theme/app_theme.dart
lib/features/collaboration/presentation/collaboration_bar.dart
lib/features/collaboration/presentation/widgets/remote_cursors_layer.dart
lib/features/formations/application/tactic_library_providers.dart
lib/features/formations/domain/tactic_board_template.dart
lib/features/formations/presentation/formation_library_screen.dart
lib/features/home/presentation/home_screen.dart
lib/features/leagues/application/leagues_providers.dart
lib/features/leagues/data/leagues_repository.dart
lib/features/leagues/domain/match_fixture.dart
lib/features/leagues/domain/player.dart
lib/features/leagues/domain/preset_leagues_data.dart
lib/features/leagues/domain/standing.dart
lib/features/leagues/presentation/league_detail_screen.dart
lib/features/leagues/presentation/leagues_screen.dart
lib/features/leagues/presentation/widgets/fixtures_tab.dart
lib/features/leagues/presentation/widgets/league_tile.dart
lib/features/leagues/presentation/widgets/standings_tab.dart
lib/features/leagues/presentation/widgets/teams_tab.dart
lib/features/onboarding/presentation/onboarding_screen.dart
lib/features/onboarding/presentation/widgets/features_onboarding_page.dart
lib/features/onboarding/presentation/widgets/onboarding_pitch_animation.dart
lib/features/onboarding/presentation/widgets/welcome_onboarding_page.dart
lib/features/presentation_mode/presentation/presentation_pitch_view.dart
lib/features/scouting/dynamic_player_profile_screen.dart
lib/features/scouting/player_profile_screen.dart
lib/features/scouting/presentation/scouting_report_screen.dart
lib/features/scouting/presentation/widgets/key_findings_section.dart
lib/features/scouting/presentation/widgets/player_ratings_chart.dart
lib/features/scouting/presentation/widgets/report_type_selector.dart
lib/features/scouting/presentation/widgets/tactical_board_spinner.dart
lib/features/settings/domain/app_theme_variant.dart
lib/features/settings/presentation/privacy_settings_view.dart
lib/features/settings/presentation/settings_screen.dart
lib/features/settings/presentation/widgets/data_practices_summary.dart
lib/features/shape_simulation/application/shape_simulation_controller.dart
lib/features/shape_simulation/application/shape_simulation_notifier.dart
lib/features/shape_simulation/presentation/simulation_mode_panel.dart
lib/features/shape_simulation/presentation/widgets/ghost_trail_layer.dart
lib/features/tactical_board/application/tactical_board_notifier.dart
lib/features/tactical_board/domain/arrow.dart
lib/features/tactical_board/domain/board_snapshot.dart
lib/features/tactical_board/domain/board_tool.dart
lib/features/tactical_board/domain/zone.dart
lib/features/tactical_board/presentation/tactical_board_screen.dart
lib/features/tactical_board/presentation/tactical_screen.dart
lib/features/tactical_board/presentation/widgets/annotations_painter.dart
lib/features/tactical_board/presentation/widgets/drawing_toolbar.dart
lib/features/tactical_board/presentation/widgets/exportable_pitch_view.dart
lib/features/tactical_board/presentation/widgets/formation_picker_sheet.dart
lib/features/tactical_board/presentation/widgets/localized_pitch_canvas.dart
lib/features/tactical_board/presentation/widgets/pitch_canvas.dart
lib/features/tactical_board/presentation/widgets/pitch_painter.dart
lib/features/tactical_board/presentation/widgets/player_token.dart
lib/features/tactics/tactical_3d_pitch_board.dart
lib/features/timeline/presentation/tactical_board_player.dart
lib/features/timeline/presentation/timeline_widget.dart
lib/features/timeline/presentation/widgets/collapsible_timeline_panel.dart
lib/features/training/application/training_notifier.dart
lib/features/training/presentation/training_toolbar.dart
lib/features/training/presentation/widgets/training_mode_bar.dart
lib/features/video_analysis/domain/analysis_result.dart
lib/features/video_analysis/domain/analysis_result_mapper.dart
lib/features/video_analysis/domain/standard_penalty_box_calibration.dart
lib/features/video_analysis/presentation/analyze_video_screen.dart
lib/features/video_analysis/presentation/video_analysis_result_screen.dart
lib/features/video_analysis/presentation/video_calibration_screen.dart
lib/features/video_analysis/presentation/video_processing_screen.dart
lib/features/video_analysis/presentation/widgets/analysis_pitch_view.dart
lib/features/video_analysis/presentation/widgets/calibration_frame_view.dart
lib/features/video_analysis/presentation/widgets/penalty_box_reference_diagram.dart
lib/features/video_analysis/presentation/widgets/pending_analysis_banner.dart
lib/features/video_analysis/presentation/widgets/player_stats_panel.dart
lib/features/video_analysis/presentation/widgets/recent_analyses_section.dart
lib/main.dart
lib/screens/auth_screen.dart
lib/screens/captain_hub_screen.dart
lib/screens/captain_main_dashboard.dart
lib/screens/captain_stadium_login_screen.dart
lib/screens/league_scouting_screen.dart
lib/screens/leagues_scouting_hub_screen.dart
lib/screens/live_match_dashboard_screen.dart
lib/screens/match_scouting_dashboard.dart
lib/screens/play_sequence_screen.dart
lib/screens/playground_3d_hub_screen.dart
lib/screens/post_match_report_screen.dart
lib/screens/squad_leaderboard_screen.dart
lib/screens/synced_match_analysis_screen.dart
lib/screens/tactical_3d_pitch_screen.dart
lib/screens/tactical_viewer_screen.dart
lib/screens/tactics_hub_screen.dart
lib/screens/video_match_analysis_screen.dart
lib/screens/virtual_playground_screen.dart
lib/shared/widgets/home_action_button.dart
lib/widgets/ai_scouting_modal.dart
lib/widgets/captain_pin_pad_widget.dart
lib/widgets/debug_diagnostics_drawer.dart
lib/widgets/player_profile_modal.dart
lib/widgets/save_tactic_dialog.dart
lib/widgets/system_health_check_dialog.dart
lib/widgets/tactical_3d_pitch.dart
lib/widgets/tactical_arrows_painter.dart
lib/widgets/tactical_keyframe_bar.dart
lib/widgets/tactical_lineup_manager_widget.dart
lib/widgets/tactical_pov_bar.dart
lib/widgets/timeline_scrubber_widget.dart
pubspec.yaml
test/widget_test.dart
vision_backend/main.py
vision_backend/requirements.txt
lib/features/tactical_board/domain/arrow.freezed.dart
lib/features/tactical_board/domain/arrow.g.dart
lib/features/tactical_board/domain/zone.freezed.dart
lib/features/tactical_board/domain/zone.g.dart
lib/features/formations/domain/tactic_board_template.freezed.dart
lib/features/formations/domain/tactic_board_template.g.dart
lib/features/video_analysis/domain/analysis_result.freezed.dart
lib/features/video_analysis/domain/analysis_result.g.dart
```
