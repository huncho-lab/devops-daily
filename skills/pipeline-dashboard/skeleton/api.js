// MOVE TO: skills/pipeline-dashboard/app/src/api.js   (C3, criterion 10)

// TODO: export async function loadRuns(search = window.location.search)
//   - read `repo` from the query string (owner/name); validate the format, error if malformed
//   - repo given  -> Axios GET https://api.github.com/repos/<owner>/<name>/actions/runs?per_page=100
//                    with header Accept: application/vnd.github+json  (NO token, ever)
//   - no repo     -> GET /runs.json (the fixture copied into app/public/)
//   - return { source, runs } where runs is the workflow_runs array
//   - turn Axios errors into Error objects with readable messages:
//       404                                   -> "... not found ..."
//       403/429 and x-ratelimit-remaining "0" -> "... rate limit ... resets at HH:MM" (x-ratelimit-reset is Unix seconds)
//       no response (offline)                 -> network message

// TODO: src/api.test.js with vi.mock("axios"): success path + at least one error path
