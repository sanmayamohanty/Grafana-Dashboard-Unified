# Grafana Multi-Tenant Deployment Controller

You are managing a phased deployment of a multi-tenant Grafana dashboard system. Follow these instructions precisely.

## State Management

**State File**: `.claude/state.json`
- Always read state file at the start of any command
- Update state file after every action
- Never lose progress - always save before any potentially failing operation

## Command Recognition

Recognize these commands (case-insensitive, fuzzy match):

### Phase Commands
| User Says | Action |
|-----------|--------|
| `start phase 1`, `deploy grafana`, `railway setup` | Begin Phase 1 |
| `start phase 2`, `setup orgs`, `create organizations` | Begin Phase 2 |
| `start phase 3`, `setup datasources`, `configure databases` | Begin Phase 3 |
| `start phase 4`, `create dashboards`, `setup dashboards` | Begin Phase 4 |
| `start phase 5`, `setup routing`, `configure subdomains` | Begin Phase 5 |
| `start phase 6`, `validate`, `test deployment` | Begin Phase 6 |

### Control Commands
| User Says | Action |
|-----------|--------|
| `pause`, `stop`, `save progress` | Save state and pause |
| `resume`, `continue`, `pick up` | Load state and continue |
| `status`, `where am i`, `progress` | Show current phase/step |
| `rollback`, `undo`, `revert` | Undo last action |
| `skip`, `next step`, `skip this` | Skip current step (confirm first) |
| `help`, `commands`, `what can i do` | Show available commands |

### Info Commands
| User Says | Action |
|-----------|--------|
| `show credentials`, `creds` | Display saved credentials |
| `show errors`, `what went wrong` | Show error history |
| `show lessons`, `learnings` | Show learned preferences |

## Phase Execution Protocol

When starting or resuming a phase:

1. **Read State**: Load `.claude/state.json`
2. **Check Prerequisites**: Ensure previous phases are complete
3. **Show Progress**: Display current phase and completed steps
4. **Execute Step**: Run the current step
5. **Handle Errors**: If error occurs:
   - Log to `errors` array with timestamp and context
   - Add to `lessons` if it's a learnable mistake
   - Offer rollback or retry
6. **Save State**: Update state file immediately
7. **Confirm**: Ask user before proceeding to next step (unless they said "auto")

## Error Learning System

When an error occurs:
1. Log it to `state.json` errors array:
```json
{
  "timestamp": "ISO-8601",
  "phase": 1,
  "step": "1.2",
  "error": "Error message",
  "context": "What was being attempted",
  "resolution": "How it was fixed"
}
```

2. Extract lesson and add to lessons array:
```json
{
  "timestamp": "ISO-8601",
  "category": "railway|grafana|postgresql|general",
  "lesson": "What was learned",
  "applies_to": ["phase 1", "step 1.2"]
}
```

3. Before executing similar steps in future, check lessons array and warn/prevent repeating mistakes.

## User Preference Learning

Track preferences in `userPreferences` object:
- When user corrects you, update preference
- When user shows a pattern (3+ times), add as preference
- Apply preferences proactively

Examples:
- User prefers confirmations before destructive actions
- User likes detailed output vs. minimal
- User prefers certain naming conventions

## Output Format

### Starting a Phase
```
═══════════════════════════════════════════════════
  PHASE {N}: {Phase Name}
═══════════════════════════════════════════════════

📋 Steps:
  [ ] {Step 1}
  [ ] {Step 2}
  ...

🔄 Starting Step {N}.1: {Step Name}
───────────────────────────────────────────────────
```

### Step Completion
```
✅ Step {N}.{M} Complete: {Step Name}
   Output: {relevant output}

➡️  Next: Step {N}.{M+1}: {Next Step Name}
   Continue? (yes/skip/pause)
```

### Error Occurred
```
❌ Error in Step {N}.{M}: {Step Name}

   Error: {error message}

   Options:
   1. retry - Try again
   2. rollback - Undo and go back
   3. skip - Skip this step
   4. pause - Save and pause

   💡 Lesson learned: {extracted lesson}
```

### Status Display
```
═══════════════════════════════════════════════════
  DEPLOYMENT STATUS
═══════════════════════════════════════════════════

Current Phase: {N} - {Phase Name}
Current Step:  {N}.{M} - {Step Name}
Overall:       {completed phases}/6 phases complete

Phase Progress:
  ✅ Phase 1: Railway Deployment
  ✅ Phase 2: Organization Setup
  🔄 Phase 3: Data Source Configuration (Step 2/4)
  ⏳ Phase 4: Dashboard Creation
  ⏳ Phase 5: Subdomain Routing
  ⏳ Phase 6: Testing & Validation

Saved Credentials:
  Grafana URL: {url or 'not set'}
  Org IDs: A={id}, B={id}, C={id}
```

## Credential Collection

When credentials are needed, ask clearly:
```
🔐 Credentials Required for {Step Name}

Please provide:
  1. {credential_1}:
  2. {credential_2}:

(These will be saved securely in state for resume capability)
```

Save to `credentials` object in state file.

## Phase-Specific Instructions

### Phase 1: Railway Deployment
- Guide user through Railway CLI or UI
- Collect Grafana URL after deployment
- Verify health endpoint before marking complete

### Phase 2: Organization Setup
- Can use API or guide through UI
- Collect and save all Org IDs
- Collect and save user credentials

### Phase 3: Data Source Configuration
- Need database credentials for each project
- Test connections before marking complete
- Save data source UIDs

### Phase 4: Dashboard Creation
- Use template JSONs from provisioning folder
- Customize queries based on actual table names
- Save dashboard UIDs

### Phase 5: Subdomain Routing
- Deploy redirect service if user wants subdomains
- Help configure DNS if needed
- Test all redirect URLs

### Phase 6: Testing & Validation
- Systematic testing of all functionality
- Document any issues found
- Mark deployment complete only if all tests pass
