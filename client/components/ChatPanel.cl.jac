"""Interrogation pop-up: suspect profile on the left, chat on the right.

Includes the starter question cards, clue chips for "Show clue", and an
Accuse button for the suspect being questioned.
"""

import from .Board { PhotoBox, Stamp, Tape, hand }

sv import from game.types { PublicClue }

def:pub ChatBubble(who: str, name: str, text: str, kind: str) -> JsxElement {
    if who == "system" {
        tone = "text-red-700" if kind == "error" else ("font-bold text-[#8a2d1d]" if kind == "clue" else "text-[#6b5a48]");
        return <p className={"self-center text-center text-sm italic " + tone}>{text}</p>;
    }
    mine = who == "you";
    align = "self-end items-end" if mine else "self-start items-start";
    bubble = "bg-white border border-[#e5d5b5]";
    if mine {
        bubble = "bg-[#e8e4f8] border border-[#d6cff0]";
    }
    if kind == "show" {
        bubble = "bg-[#fde68a] border-2 border-[#b07a1a]";
    } elif kind == "crack" {
        bubble = "bg-red-50 border-2 border-red-700 font-semibold";
    } elif kind == "shrug" {
        bubble = "bg-white border border-[#e5d5b5] italic opacity-80";
    }
    return <div className={"flex max-w-[85%] flex-col " + align}>
        <span className="mb-0.5 text-xs text-[#6b5a48]">{"You" if mine else name}</span>
        <div className={"rounded-lg px-3.5 py-2.5 leading-relaxed shadow-sm " + bubble}>{text}</div>
    </div>;
}

# Starter question card: one click sends a ready-made question (costs a normal question).
def:pub StarterCard(label: str, blurb: str, ask: str, onAsk: Callable[[str], None], className: str = "") -> JsxElement {
    def handle_click(_e: MouseEvent) {
        onAsk(ask);
    }

    return <button
        className={"flex flex-col rounded-md border border-[#d9c8a5] bg-white px-4 py-3 text-left shadow-sm transition hover:-translate-y-0.5 hover:border-[#8a2d1d] " + className}
        title={ask}
        onClick={handle_click}
    >
        <span className="text-lg font-bold">{label}</span>
        <span className="text-sm text-[#5a4a3a]">{blurb}</span>
    </button>;
}

def:pub ClueChip(cid: str, text: str, selected: bool, onPick: Callable[[str], None]) -> JsxElement {
    def handle_click(_e: MouseEvent) {
        onPick(cid);
    }

    tone = "bg-[#fde68a] border-[#b07a1a] font-semibold" if selected else "bg-white border-[#d9c8a5] hover:border-[#b07a1a]";
    short = (text[:42] + "...") if len(text) > 45 else text;
    return <button className={"max-w-full truncate rounded-full border px-3 py-1 text-xs " + tone} title={text} onClick={handle_click}>
        {short}
    </button>;
}

def:pub ChatPanel(
    name: str,
    role: str,
    style: str,
    idx: int,
    lines: list[dict[str, str]],
    draft: str,
    busy: bool,
    isCracked: bool,
    clues: list[PublicClue],
    selectedClue: str,
    onPickClue: Callable[[str], None],
    onDraft: Callable[[str], None],
    onSend: Callable[[], None],
    onShow: Callable[[], None],
    onAsk: Callable[[str], None],
    onAccuse: Callable[[], None],
    onClose: Callable[[], None]
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

    def handle_accuse(_e: MouseEvent) {
        onAccuse();
    }

    def handle_close(_e: MouseEvent) {
        onClose();
    }

    return <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/60 p-3 sm:p-6">
        <div className="relative grid max-h-[92vh] w-full max-w-5xl grid-cols-1 overflow-hidden bg-[#fdf3dc] text-[#231a12] shadow-2xl md:grid-cols-[300px_1fr]" role="dialog" aria-modal="true">
            <button
                className="absolute right-3 top-2 z-10 text-3xl font-bold leading-none text-[#231a12] hover:text-red-700"
                title="Close"
                onClick={handle_close}
            >
                {"×"}
            </button>
            <aside className="hidden flex-col gap-3 overflow-y-auto border-r border-[#e5d5b5] p-4 md:flex">
                <div className="relative bg-white p-2 pb-3 shadow-md">
                    <Tape className="-top-3 left-1/2 -translate-x-1/2 rotate-2" />
                    <PhotoBox name={name} idx={idx} />
                    {isCracked and <span className="absolute right-3 top-8">
                        <Stamp text="Cracked" className="bg-white/70 text-xl" />
                    </span>}
                </div>
                <p className="text-3xl font-bold" style={hand()}>{name}</p>
                <p className="text-sm">
                    <span className="font-bold text-[#8a2d1d]">Role: </span>{role}
                </p>
                {style and <p className="text-sm">
                    <span className="font-bold text-[#8a2d1d]">Manner: </span>{style}
                </p>}
                <p className="mt-auto text-xs italic text-[#6b5a48]">Each question costs 50 points. Showing the right clue cracks a lie (+150).</p>
            </aside>
            <section className="flex min-h-[70vh] flex-col md:min-h-[560px]">
                <div className="border-b border-[#e5d5b5] px-5 py-3 md:hidden">
                    <p className="text-2xl font-bold" style={hand()}>{name}</p>
                    <p className="text-sm text-[#5a4a3a]">{role + ((" · " + style) if style else "")}</p>
                </div>
                <div className="flex flex-1 flex-col gap-3 overflow-y-auto px-5 pb-3 pt-10" aria-live="polite">
                    {if len(lines) == 0 and not busy {
                        <div className="m-auto flex w-full max-w-md flex-col items-center gap-3">
                            <p className="text-center text-2xl font-bold" style={hand()}>{"Start questioning " + name}</p>
                            <StarterCard
                                label="Relation"
                                blurb="Overview of victim connection"
                                ask="How would you describe your relationship with the victim?"
                                onAsk={onAsk}
                                className="w-full sm:w-2/3"
                            />
                            <div className="grid w-full grid-cols-1 gap-3 sm:grid-cols-2">
                                <StarterCard
                                    label="Alibi"
                                    blurb="Details on whereabouts"
                                    ask="Where were you when it happened, and who can confirm it?"
                                    onAsk={onAsk}
                                />
                                <StarterCard
                                    label="Observations"
                                    blurb="Identify irregular details"
                                    ask="Did you notice anything strange or anyone acting oddly?"
                                    onAsk={onAsk}
                                />
                            </div>
                        </div>
                    }}
                    {for (i, ln) in enumerate(lines) {
                        <ChatBubble key={str(i)} who={ln["who"]} name={name} text={ln["text"]} kind={ln["kind"]} />
                    }}
                    {busy and <div className="flex max-w-[85%] flex-col self-start">
                        <span className="mb-0.5 text-xs text-[#6b5a48]">{name}</span>
                        <div className="animate-pulse rounded-lg border border-[#e5d5b5] bg-white px-3.5 py-2.5 italic text-[#6b5a48]">thinking...</div>
                    </div>}
                </div>
                <div className="border-t border-[#e5d5b5] bg-[#fbecc9] p-3">
                    {len(clues) > 0 and <div className="mb-2 flex flex-wrap items-center gap-1.5">
                        <span className="text-xs font-bold text-[#8a2d1d]">Show a clue:</span>
                        {for c in clues {
                            <ClueChip key={c.id} cid={c.id} text={c.text} selected={c.id == selectedClue} onPick={onPickClue} />
                        }}
                    </div>}
                    <div className="rounded-md border border-[#d9c8a5] bg-[#fffaf0] p-2">
                        <input
                            className="w-full bg-transparent px-2 py-1.5 outline-none"
                            value={draft}
                            placeholder={"Ask " + name + " a question..."}
                            disabled={busy}
                            onChange={handle_change}
                            onKeyDown={handle_key}
                        />
                        <div className="mt-1 flex items-center justify-end gap-2">
                            {selectedClue and <button
                                className="rounded-md border-2 border-[#b07a1a] bg-[#fde68a] px-3 py-1.5 text-sm font-bold disabled:opacity-50"
                                disabled={busy}
                                onClick={handle_show}
                            >
                                Show clue
                            </button>}
                            <button
                                className="rounded-md bg-[#fde047] px-4 py-1.5 text-sm font-bold text-[#231a12] hover:bg-[#facc15] disabled:opacity-50"
                                disabled={busy}
                                onClick={handle_accuse}
                            >
                                {"Accuse " + name}
                            </button>
                            <button
                                className="flex size-9 items-center justify-center rounded-full bg-[#8a2d1d] text-lg font-bold text-white disabled:opacity-40"
                                title="Send"
                                disabled={busy or not draft.strip()}
                                onClick={handle_send}
                            >
                                {"↑"}
                            </button>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>;
}
