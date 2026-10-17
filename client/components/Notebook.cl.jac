"""Notebook of found clues + Hint and Accuse buttons (right panel)."""

sv import from game.types { PublicClue }

def:pub ClueItem(cid: str, text: str, selected: bool, onPick: Callable[[str], None]) -> JsxElement {
    def handle_click(_e: MouseEvent) {
        onPick(cid);
    }

    tone = "border-primary bg-primary/15" if selected else "border-border bg-background hover:border-primary/60";
    return <button
        className={"w-full rounded-lg border border-l-4 border-l-primary p-2.5 text-left text-sm transition " + tone}
        onClick={handle_click}
    >
        {text}
    </button>;
}

def:pub Notebook(
    clues: list[PublicClue],
    selectedClue: str,
    hints: list[str],
    busy: bool,
    lastChance: bool,
    hintCost: int,
    hintsLeft: int,
    onPickClue: Callable[[str], None],
    onHint: Callable[[], None],
    onAccuse: Callable[[], None]
) -> JsxElement {
    def handle_hint(_e: MouseEvent) {
        onHint();
    }

    def handle_accuse(_e: MouseEvent) {
        onAccuse();
    }

    return <section className="flex flex-1 flex-col gap-3 rounded-xl border bg-card p-4">
        <p className="text-xs font-bold tracking-[0.15em] text-primary">NOTEBOOK</p>
        <div className="flex flex-col gap-2">
            {if len(clues) == 0 {
                <p className="text-sm text-muted-foreground">No clues yet. Question the suspects.</p>
            }}
            {for c in clues {
                <ClueItem key={c.id} cid={c.id} text={c.text} selected={c.id == selectedClue} onPick={onPickClue} />
            }}
        </div>
        {len(clues) > 0 and <p className="text-xs text-muted-foreground">Pick a clue, then press Show in the chat.</p>}
        {len(hints) > 0 and <div className="flex flex-col gap-2">
            <p className="text-xs font-bold tracking-[0.15em] text-primary">HINTS</p>
            {for (i, h) in enumerate(hints) {
                <p key={str(i)} className="rounded-lg border border-dashed border-primary/60 p-2 text-sm">{h}</p>
            }}
        </div>}
        <div className="mt-auto flex gap-2 pt-2">
            <button
                className="flex-1 rounded-lg border px-3 py-2 font-semibold hover:border-primary disabled:opacity-50"
                disabled={busy or hintsLeft == 0}
                onClick={handle_hint}
            >
                {"No hints left" if hintsLeft == 0 else "Hint (-" + str(hintCost) + ")"}
            </button>
            <button
                className="flex-1 rounded-lg bg-destructive px-3 py-2 font-semibold text-white hover:bg-destructive/85 disabled:opacity-50"
                disabled={busy}
                onClick={handle_accuse}
            >
                Accuse
            </button>
        </div>
        {lastChance and <p className="text-sm font-semibold text-destructive">Last chance to accuse!</p>}
    </section>;
}
