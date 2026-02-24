# ===========================================
# AUDIT_TRAIL - repo-auditor v2.0.0
# ===========================================

audit_version: <X.Y.Z>
audit_date: <YYYY-MM-DD>
audit_agent: <AGENT_NAME> (<MODEL_ID>)
audit_session: <SESSION_ID or N/A>
audit_mode: <AUDIT_AND_FIX | AUDIT_ONLY | DRY_RUN>

target_repo: <name>
target_branch: <branch>
target_version: <vX.Y.Z>
git_status_clean: <YES/NO>
git_sync_status: <SYNCED/DIVERGED/N/A>

total_files_tracked: <N>
critical_files_count: <N>
files_fingerprinted: <N>

audit_result: <PASS | PASS_WITH_WARNINGS | FAIL>
critical_errors_found: <N>
critical_errors_resolved: <N>
critical_errors_open: <N>
warnings_found: <N>
files_corrected: <N>
files_orphaned: <N>
links_broken: <N>

skill_count_validation: <PASS/FAIL>
skill_count_real: <N>
skill_count_declared: <N>
version_crosscheck: <PASS/FAIL>
version_crosscheck_failures: <N>
architecture_completeness: <PASS/FAIL>
reference_accuracy: <PASS/FAIL>
changelog_completeness: <PASS/FAIL>

spot_check_sample_size: <N>
spot_check_passed: <N>
spot_check_warnings: <N>
spot_check_failures: <N>

release_published: <YES/NO/SKIPPED>
release_url: <URL or N/A>
release_tag: <vX.Y.Z or N/A>
release_tag_verified: <YES/NO/N/A>

phase_0_status: <PASS/FAIL/BLOCKED>
phase_1_status: <PASS/FAIL/PASS_WITH_WARNINGS/BLOCKED>
phase_1_2_status: <PASS/FAIL/PASS_WITH_WARNINGS/BLOCKED>
phase_1_5_status: <PASS/FAIL/PASS_WITH_WARNINGS/BLOCKED>
phase_2_status: <PASS/FAIL/PASS_WITH_WARNINGS/BLOCKED>
phase_3_status: <PASS/FAIL/PASS_WITH_WARNINGS/BLOCKED>
phase_3_6_status: <PASS/FAIL/SKIPPED/BLOCKED>

audit_start: <YYYY-MM-DD HH:MM>
audit_end: <YYYY-MM-DD HH:MM>

fingerprints:
  - file: <PATH>
    total_lines: <N>
    first_line: "<TEXT>"
    last_line: "<TEXT>"
    content_hash: <SHA>

warnings:
  - phase: <N>
    description: "<TEXT>"
    file: "<PATH>"
    recommended_action: "<TEXT>"

corrections:
  - file: <PATH>
    description: "<TEXT>"
    status: <RECOVERED/REVERTED>
    hash_before: <SHA>
    hash_after: <SHA>

out_of_scope:
  - description: "<TEXT>"
    file: "<PATH>"
