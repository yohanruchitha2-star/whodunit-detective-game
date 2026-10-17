"""Interrogation chat with the selected suspect (middle panel)."""

def:pub ChatBubble(who: str, name: str, text: str, kind: str) -> JsxElement {
    if who == "system" {
        tone = "text-destructive" if kind == "error" else ("font-semibold text-primary" if kind == "clue" else "text-muted-foreground");
        return <p className={"self-center text-center text-sm " + tone}>{text}</p>;
    }
    mine = who == "you";
    align = "self-end items-end" if mine else "self-start items-start";
    bubble = "border bg-muted";
    if mine {
        bubble = "border border-primary/40 bg-primary/15";
    }
    if kind == "show" {
        bubble = "border-2 border-primary bg-primary/15";
    } elif kind == "crack" {
        bubble = "border-2 border-destructive bg-destructive/20 font-semibold";
    } elif kind == "shrug" {
        bubble = "border bg-muted italic opacity-80";
    }
    return <div className={"flex max-w-[80%] flex-col " + align}>
        <span className="mb-1 text-xs text-muted-foreground">{"You" if mine else name}</span>
        <div className={"rounded-xl px-3.5 py-2.5 leading-relaxed " + bubble}>{text}</div>
    </div>;
}

def:pub ChatPanel(
    name: str,
    role: str,
    lines: list[dict[str, str]],
    draft: str,
    busy: bool,
    isCracked: bool,
    selectedClueText: str,
    onDraft: Callable[[str], None],
    onSend: Callable[[], None],
    onShow: Callable[[], None]
) -> JsxElement {
    def handle_change(e: ChangeEvent) {
        onDraft(e.target.value);
    }

    def handle_key(e: KeyboardEvent) {
        if e.key == "Enter" and not busy {
            e.preventDefault();
            onSend();
        }
    }

    def handle_send(_e: MouseEvent) {
        onSend();
    }

    def handle_show(_e: MouseEvent) {
        onShow();
    }

    showLabel = ("Show clue: " + selectedClueText) if selectedClueText else "Show clue (pick one in your notebook)";
    frame = "border-destructive ring-2 ring-destructive/40" if isCracked else "border-border";

    return <section className={"flex min-h-[480px] flex-1 flex-col rounded-xl border bg-card " + frame}>
        <div className="flex items-center justify-between border-b p-4">
            <div>
                <p className="text-xs font-bold tracking-[0.15em] text-primary">INTERROGATION</p>
                <h2 className="text-xl font-semibold">
                    {name}
                    {role and <span className="text-base font-normal text-muted-foreground">{" (" + role + ")"}</span>}
                </h2>
            </div>
            {isCracked and <span className="rounded-full bg-destructive px-2.5 py-1 text-xs font-bold tracking-wider text-white">
                CRACKED
            </span>}
        </div>
        <div className="flex max-h-[60vh] flex-1 flex-col gap-3 overflow-y-auto p-4" aria-live="polite">
            {if len(lines) == 0 {
                <p className="m-auto max-w-sm text-center text-muted-foreground">
                    {"Ask " + name + " anything. Try: \"Where were you when it happened?\""}
                </p>
            }}
            {for (i, ln) in enumerate(lines) {
                <ChatBubble key={str(i)} who={ln["who"]} name={name} text={ln["text"]} kind={ln["kind"]} />
            }}
            {busy and <div className="flex max-w-[80%] flex-col self-start">
                <span className="mb-1 text-xs text-muted-foreground">{name}</span>
                <div className="animate-pulse rounded-xl border bg-muted px-3.5 py-2.5 text-muted-foreground">thinking...</div>
            </div>}
        </div>
        <div className="grid grid-cols-[1fr_auto] gap-2 border-t p-3">
            <input
                className="min-w-0 flex-1 rounded-lg border bg-background px-3 py-2 outline-none focus:border-primary"
                value={draft}
                placeholder={"Ask " + name + " a question..."}
                disabled={busy}
                onChange={handle_change}
                onKeyDown={handle_key}
            />
            <button
                className="rounded-lg bg-primary px-4 py-2 font-semibold text-primary-foreground disabled:opacity-50"
                disabled={busy or not draft.strip()}
                onClick={handle_send}
            >
                Send
            </button>
            <button
                className="col-span-2 truncate rounded-lg border-2 border-primary px-4 py-2 font-semibold text-primary disabled:opacity-40"
                disabled={busy or not selectedClueText}
                title="Pick a clue in your notebook first"
                onClick={handle_show}
            >
                {showLabel}
            </button>
        </div>
    </section>;
}
