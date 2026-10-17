"""Detective's notebook pinned to the board: found clues, hints, Hint and Accuse."""

import from .Board { Paper, hand }

sv import from game.types { PublicClue }

def:pub ClueItem(cid: str, text: str, selected: bool, onPick: Callable[[str], None]) -> JsxElement {
    def handle_click(_e: MouseEvent) {
        onPick(cid);
    }

    tone = "bg-[#fde68a] font-semibold" if selected else "hover:bg-[#fde68a]/50";
    return <button className={"w-full rounded-sm px-1.5 py-1 text-left text-sm leading-snug " + tone} onClick={handle_click}>
        {"• " + text}
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

    lined = {
        "backgroundImage": "repeating-linear-gradient(transparent 0px, transparent 27px, #c9d6e8 28px)",
        "backgroundPosition": "0 8px"
    };
    return <Paper className="flex min-h-[340px] flex-col border-l-[3px] border-red-300" tilt="-rotate-1">
        <div className="flex-1" style={lined}>
            <p className="text-2xl font-bold" style={hand()}>Clues found</p>
            {if len(clues) == 0 {
                <p className="text-sm italic text-[#6b5a48]">Nothing yet. Question the suspects.</p>
            }}
            {for c in clues {
                <ClueItem key={c.id} cid={c.id} text={c.text} selected={c.id == selectedClue} onPick={onPickClue} />
            }}
            {len(clues) > 0 and <p className="mt-1 text-xs italic text-[#6b5a48]">
                Pick a clue, then show it to a suspect.
            </p>}
            {len(hints) > 0 and <div className="mt-3">
                <p className="text-2xl font-bold" style={hand()}>Hints</p>
                {for (i, h) in enumerate(hints) {
                    <p key={str(i)} className="text-sm italic text-[#5a3a12]">{"→ " + h}</p>
                }}
            </div>}
        </div>
        <div className="mt-4 flex gap-2">
            <button
                className="flex-1 rounded-sm border-2 border-[#5a4a3a] px-3 py-2 text-lg font-bold hover:bg-[#fde68a] disabled:opacity-50"
                style={hand()}
                disabled={busy or hintsLeft == 0}
                onClick={handle_hint}
            >
                {"No hints left" if hintsLeft == 0 else "Hint (-" + str(hintCost) + ")"}
            </button>
            <button
                className="flex-1 rounded-sm bg-[#8a2d1d] px-3 py-2 text-lg font-bold text-[#fdf6e3] hover:bg-[#a33a27] disabled:opacity-50"
                style={hand()}
                disabled={busy}
                onClick={handle_accuse}
            >
                Accuse
            </button>
        </div>
        {lastChance and <p className="mt-2 text-center text-sm font-bold text-red-700">Last chance to accuse!</p>}
    </Paper>;
}
