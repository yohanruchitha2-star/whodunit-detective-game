"""Accuse dialog: pick a suspect + a one-line reason, on a paper note."""

import from .Board { Paper, PhotoBox, hand }

sv import from game.types { PublicSuspect }

def:pub AccuseOption(
    sid: str,
    name: str,
    role: str,
    idx: int,
    selected: bool,
    onPick: Callable[[str], None]
) -> JsxElement {
    def handle_click(_e: MouseEvent) {
        onPick(sid);
    }

    tone = "ring-4 ring-red-700" if selected else "hover:-translate-y-0.5";
    return <button className={"flex flex-col bg-white p-1.5 pb-2 text-left shadow-md transition " + tone} onClick={handle_click}>
        <PhotoBox name={name} idx={idx} />
        <span className="mt-1 text-sm font-bold">{name}</span>
        <span className="text-xs text-[#5a4a3a]">{role}</span>
    </button>;
}

def:pub AccuseDialog(
    suspects: list[PublicSuspect],
    accuseId: str,
    reason: str,
    errorMsg: str,
    busy: bool,
    lastChance: bool,
    chancesLeft: int,
    onPick: Callable[[str], None],
    onReason: Callable[[str], None],
    onSubmit: Callable[[], None],
    onCancel: Callable[[], None]
) -> JsxElement {
    def handle_reason(e: ChangeEvent) {
        onReason(e.target.value);
    }

    def handle_submit(_e: MouseEvent) {
        onSubmit();
    }

    def handle_cancel(_e: MouseEvent) {
        onCancel();
    }

    cols = "grid-cols-3 sm:grid-cols-5" if len(suspects) > 4 else ("grid-cols-3" if len(suspects) == 3 else "grid-cols-2 sm:grid-cols-4");
    return <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/65 p-4">
        <div className="w-full max-w-2xl" role="dialog" aria-modal="true">
            <Paper className="flex flex-col gap-4 p-6" tilt="rotate-[-0.5deg]">
                <p className="text-4xl font-bold" style={hand()}>Who did it?</p>
                <p className={"text-sm " + ("font-bold text-red-700" if lastChance or chancesLeft <= 1 else "text-[#5a4a3a]")}>
                    {"This is your LAST chance." if chancesLeft <= 1 else "A wrong guess costs 300 points. Chances left: " + str(chancesLeft)}
                </p>
                <div className={"grid gap-3 " + cols}>
                    {for (i, s) in enumerate(suspects) {
                        <AccuseOption key={s.id} sid={s.id} name={s.name} role={s.role} idx={i} selected={s.id == accuseId} onPick={onPick} />
                    }}
                </div>
                <input
                    className="border-b-2 border-[#5a4a3a] bg-transparent px-1 py-2 text-lg outline-none focus:border-red-700"
                    style={hand()}
                    value={reason}
                    placeholder="One line: why them?"
                    onChange={handle_reason}
                />
                {errorMsg and <p className="text-sm font-semibold text-red-700">{errorMsg}</p>}
                <div className="flex justify-end gap-3">
                    <button className="rounded-sm border-2 border-[#5a4a3a] px-5 py-2 text-lg font-bold disabled:opacity-50" style={hand()} disabled={busy} onClick={handle_cancel}>
                        Cancel
                    </button>
                    <button
                        className="rounded-sm bg-[#8a2d1d] px-6 py-2 text-lg font-bold text-[#fdf6e3] hover:bg-[#a33a27] disabled:opacity-50"
                        style={hand()}
                        disabled={busy}
                        onClick={handle_submit}
                    >
                        {"Accusing..." if busy else "Accuse"}
                    </button>
                </div>
            </Paper>
        </div>
    </div>;
}
