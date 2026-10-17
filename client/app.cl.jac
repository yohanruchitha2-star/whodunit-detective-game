"""Whodunit - client shell (owner: Sithil).

Holds the client state and calls the backend in game/api.jac:
new_case, question (also used for "Show clue"), hint, accuse.
The server is the source of truth for clues, cracks and score; the screens
live in client/components/.
"""

import from .components.StartScreen { StartScreen }
import from .components.CaseFile { CaseFile }
import from .components.SuspectList { SuspectList }
import from .components.ChatPanel { ChatPanel }
import from .components.Notebook { Notebook }
import from .components.AccuseDialog { AccuseDialog }
import from .components.ResultScreen { ResultScreen }

sv import from game.api { new_case, question, hint, accuse }
sv import from game.types { PublicCase, PublicSuspect, PublicClue, QuestionOut, HintOut, AccuseOut }

def:pub ClientApp() -> JsxElement {
    # screen: "start" | "loading" | "play" | "result"
    has screen: str = "start",
        loadingMsg: str = "Generating your case...",
        startError: str = "",
        caseNow: PublicCase | None = None,
        suspects: list[PublicSuspect] = [],
        score: int = 1000,
        selectedId: str = "",
        chats: dict[str, list[dict[str, str]]] = {},
        clues: list[PublicClue] = [],
        selectedClue: str = "",
        cracked: list[str] = [],
        hints: list[str] = [],
        draft: str = "",
        busy: bool = False,
        notice: str = "",
        showAccuse: bool = False,
        accuseId: str = "",
        accuseReason: str = "",
        accuseError: str = "",
        lastChance: bool = False,
        flash: str = "",
        flashBad: bool = False,
        difficulty: str = "normal",
        hintCost: int = 100,
        hintsLeft: int = -1,
        chancesLeft: int = 2,
        multiplier: float = 1.0,
        outcome: AccuseOut | None = None;

    # ---------- helpers ----------
    def case_id_now -> str {
        if caseNow is not None {
            return caseNow.case_id;
        }
        return "";
    }

    def clue_text(cid: str) -> str {
        for c in clues {
            if c.id == cid {
                return c.text;
            }
        }
        return "";
    }

    # Copy-then-assign: a `{**chats, sid: x}` literal would use "sid" as the
    # key in the compiled JS, not the variable's value.
    def chats_with(sid: str, lines: list[dict[str, str]]) -> dict[str, list[dict[str, str]]] {
        nxt = {**chats} as dict[str, list[dict[str, str]]];
        nxt[sid] = lines;
        return nxt;
    }

    def pop_flash(text: str, bad: bool) {
        flash = text;
        flashBad = bad;
        setTimeout(lambda { flash = ""; }, 1600);
    }

    def reset_game {
        caseNow = None;
        suspects = [];
        score = 1000;
        selectedId = "";
        chats = {};
        clues = [];
        selectedClue = "";
        cracked = [];
        hints = [];
        draft = "";
        notice = "";
        showAccuse = False;
        accuseId = "";
        accuseReason = "";
        accuseError = "";
        lastChance = False;
        flash = "";
        outcome = None;
        startError = "";
        hintsLeft = -1;
    }

    # ---------- new_case ----------
    async def fetch_case(level: str) -> PublicCase | None {
        try {
            pc = await new_case(level);
            if pc and pc.case_id {
                return pc;
            }
        } except Exception {
            return None;
        }
        return None;
    }

    async def start_case(level: str) {
        reset_game();
        difficulty = level;
        loadingMsg = "Generating your case...";
        screen = "loading";
        pc = await fetch_case(level);
        if pc is None {
            # The backend falls back to the classic case if generation fails.
            loadingMsg = "Loading a classic case...";
            pc = await fetch_case(level);
        }
        if pc is None {
            startError = "Could not start a case. Is the backend running? Try again.";
            screen = "start";
            return;
        }
        caseNow = pc;
        suspects = pc.suspects;
        clues = [];
        score = pc.score;
        hintCost = pc.hint_cost;
        hintsLeft = pc.hints_left;
        chancesLeft = pc.chances_left;
        multiplier = pc.multiplier;
        if len(pc.suspects) > 0 {
            selectedId = pc.suspects[0].id;
        }
        screen = "play";
    }

    # ---------- question / show clue ----------
    async def talk(text: str, clue_id: str | None) {
        case_id = case_id_now();
        suspect_id = selectedId;
        old: list[dict[str, str]] = chats[suspect_id] if suspect_id in chats else [];
        shown = ("(shows: " + clue_text(clue_id) + ") ") if clue_id else "";
        lines: list[dict[str, str]] = old + [
            {"who": "you", "text": shown + text, "kind": "show" if clue_id else "normal"}
        ];
        chats = chats_with(suspect_id, lines);
        draft = "";
        notice = "";
        busy = True;
        try {
            # Positional call: local names must match the server parameter names.
            turn = await question(case_id, suspect_id, text, clue_id);
            if turn.error != "" {
                lines = lines + [{"who": "system", "text": "Could not get an answer (" + turn.error + "). Try again.", "kind": "error"}];
            } else {
                kind = "crack" if turn.cracked else ("shrug" if clue_id else "normal");
                lines = lines + [{"who": "suspect", "text": turn.reply, "kind": kind}];
                known: list[str] = [c.id for c in clues];
                fresh: list[PublicClue] = [c for c in turn.new_clues if c.id not in known];
                for c in fresh {
                    lines = lines + [{"who": "system", "text": "New clue in your notebook: " + c.text, "kind": "clue"}];
                }
                clues = clues + fresh;
                if turn.cracked {
                    if suspect_id not in cracked {
                        cracked = cracked + [suspect_id];
                    }
                    selectedClue = "";
                    pop_flash("CRACKED! +150", True);
                } elif len(fresh) > 0 {
                    pop_flash("New clue!", False);
                }
                score = turn.score;
            }
        } except Exception {
            lines = lines + [{"who": "system", "text": "No answer came back. Try again.", "kind": "error"}];
        }
        chats = chats_with(suspect_id, lines);
        busy = False;
    }

    async def send_question {
        text = draft.strip();
        if busy or not selectedId or not text {
            return;
        }
        await talk(text, None);
    }

    async def ask_starter(text: str) {
        if busy or not selectedId {
            return;
        }
        await talk(text, None);
    }

    async def show_clue {
        if busy or not selectedId or not selectedClue {
            return;
        }
        said = draft.strip();
        if not said {
            said = "Explain this.";
        }
        await talk(said, selectedClue);
    }

    # ---------- hint ----------
    async def get_hint {
        if busy {
            return;
        }
        case_id = case_id_now();
        busy = True;
        notice = "";
        try {
            res = await hint(case_id);
            if res.error == "hint_limit" {
                notice = "No hints left on this difficulty.";
                hintsLeft = 0;
            } elif res.error != "" {
                notice = "Could not get a hint (" + res.error + "). Try again.";
            } else {
                hints = hints + [res.hint];
                hintsLeft = res.hints_left;
                score = res.score;
                pop_flash("-" + str(hintCost), False);
            }
        } except Exception {
            notice = "Could not get a hint. Try again.";
        }
        busy = False;
    }

    # ---------- accuse ----------
    def open_accuse {
        accuseId = "";
        accuseReason = "";
        accuseError = "";
        showAccuse = True;
    }

    def close_accuse {
        showAccuse = False;
    }

    async def submit_accusation {
        if busy {
            return;
        }
        case_id = case_id_now();
        suspect_id = accuseId;
        reason = accuseReason.strip();
        if not suspect_id {
            accuseError = "Pick a suspect first.";
            return;
        }
        if not reason {
            accuseError = "Write one line saying why.";
            return;
        }
        busy = True;
        accuseError = "";
        try {
            res = await accuse(case_id, suspect_id, reason);
            if res.error != "" {
                accuseError = "Could not accuse (" + res.error + ").";
            } else {
                score = res.score;
                if res.game_over {
                    outcome = res;
                    showAccuse = False;
                    screen = "result";
                } else {
                    chancesLeft = res.chances_left;
                    lastChance = res.chances_left <= 1;
                    showAccuse = False;
                    notice = "Wrong! -300. " + str(res.chances_left) + " chance(s) left.";
                    pop_flash("WRONG! -300", True);
                }
            }
        } except Exception {
            accuseError = "No answer came back. Try again.";
        }
        busy = False;
    }

    # ---------- setters for child components ----------
    def pick_suspect(sid: str) {
        selectedId = sid;
    }

    def set_draft(v: str) {
        draft = v;
    }

    def pick_clue(cid: str) {
        selectedClue = "" if selectedClue == cid else cid;
    }

    def pick_accused(sid: str) {
        accuseId = sid;
    }

    def set_reason(v: str) {
        accuseReason = v;
    }

    def play_again {
        reset_game();
        screen = "start";
    }

    def pick_level(level: str) {
        difficulty = level;
    }

    def clear_notice(_e: MouseEvent) {
        notice = "";
    }

    # ---------- screens ----------
    if screen == "start" or screen == "loading" {
        return <div className="dark min-h-svh bg-background text-foreground">
            <StartScreen
                loading={screen == "loading"}
                loadingMsg={loadingMsg}
                errorMsg={startError}
                onStart={start_case}
                selected={difficulty}
                onSelect={pick_level}
            />
        </div>;
    }

    if screen == "result" and outcome is not None {
        return <div className="dark min-h-svh bg-background text-foreground">
            <ResultScreen outcome={outcome} clues={clues} onPlayAgain={play_again} />
        </div>;
    }

    currentName = "Suspect";
    currentRole = "";
    for s in suspects {
        if s.id == selectedId {
            currentName = s.name;
            currentRole = s.role;
        }
    }
    currentLines: list[dict[str, str]] = chats[selectedId] if selectedId in chats else [];
    title = caseNow.title if caseNow is not None else "";
    setting = caseNow.place if caseNow is not None else "";
    summary = caseNow.what if caseNow is not None else "";

    return <div className="dark min-h-svh bg-background text-foreground">
        <div className="flex min-h-svh flex-col">
            <header className="flex flex-wrap items-center gap-4 border-b bg-card px-5 py-3">
                <span className="text-sm font-extrabold tracking-[0.15em] text-primary">WHODUNIT</span>
                <h1 className="flex-1 text-lg font-semibold">{title}</h1>
                <span className="rounded-full border border-primary px-3 py-1.5 text-xs font-bold uppercase tracking-widest text-primary">
                    {difficulty}
                </span>
                <span className="rounded-full border px-4 py-1.5">
                    Score <strong className="ml-1 text-lg text-primary">{score}</strong>
                </span>
            </header>
            {notice and <div className="mx-5 mt-3 flex items-center justify-between gap-3 rounded-lg border border-destructive bg-destructive/15 px-4 py-2.5">
                <span>{notice}</span>
                <button className="text-sm underline" onClick={clear_notice}>Dismiss</button>
            </div>}
            <main className="grid flex-1 gap-4 p-5 lg:grid-cols-[300px_1fr_300px]">
                <aside className="flex flex-col gap-4">
                    <CaseFile title={title} setting={setting} summary={summary} />
                    <SuspectList suspects={suspects} selectedId={selectedId} cracked={cracked} onSelect={pick_suspect} />
                </aside>
                <ChatPanel
                    name={currentName}
                    role={currentRole}
                    lines={currentLines}
                    draft={draft}
                    busy={busy}
                    isCracked={selectedId in cracked}
                    selectedClueText={clue_text(selectedClue) if selectedClue else ""}
                    onDraft={set_draft}
                    onSend={send_question}
                    onShow={show_clue}
                    onAsk={ask_starter}
                />
                <aside className="flex flex-col">
                    <Notebook
                        clues={clues}
                        selectedClue={selectedClue}
                        hints={hints}
                        busy={busy}
                        lastChance={lastChance}
                        hintCost={hintCost}
                        hintsLeft={hintsLeft}
                        onPickClue={pick_clue}
                        onHint={get_hint}
                        onAccuse={open_accuse}
                    />
                </aside>
            </main>
        </div>
        {flash and <div className={"pointer-events-none fixed left-1/2 top-24 z-50 -translate-x-1/2 animate-bounce rounded-xl px-6 py-3 text-2xl font-black shadow-lg " + ("bg-destructive text-white" if flashBad else "bg-primary text-primary-foreground")}>
            {flash}
        </div>}
        {showAccuse and <AccuseDialog
            suspects={suspects}
            accuseId={accuseId}
            reason={accuseReason}
            errorMsg={accuseError}
            busy={busy}
            lastChance={lastChance}
            chancesLeft={chancesLeft}
            onPick={pick_accused}
            onReason={set_reason}
            onSubmit={submit_accusation}
            onCancel={close_accuse}
        />}
    </div>;
}
