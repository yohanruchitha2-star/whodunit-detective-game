"""Accuse dialog: pick a suspect + a one-line reason."""

sv import from game.types { PublicSuspect }

def:pub AccuseOption(
    sid: str,
    name: str,
    role: str,
    selected: bool,
    onPick: Callable[[str], None]
) -> JsxElement {
    def handle_click(_e: MouseEvent) {
        onPick(sid);
    }

    tone = "border-destructive bg-destructive/15" if selected else "border-border bg-background hover:border-destructive/60";
    return <button className={"flex flex-col rounded-lg border p-2.5 text-left " + tone} onClick={handle_click}>
        <span className="font-semibold">{name}</span>
        <span className="text-xs text-muted-foreground">{role}</span>
    </button>;
}

def:pub AccuseDialog(
    suspects: list[PublicSuspect],
    accuseId: str,
    reason: str,
    errorMsg: str,
    busy: bool,
    lastChance: bool,
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

    return <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/70 p-4">
        <div className="flex w-full max-w-md flex-col gap-3 rounded-xl border bg-card p-5" role="dialog" aria-modal="true">
            <h2 className="text-xl font-semibold">Who did it?</h2>
            <p className={"text-sm " + ("font-semibold text-destructive" if lastChance else "text-muted-foreground")}>
                {"This is your LAST chance." if lastChance else "A wrong guess costs 300 points."}
            </p>
            <div className="grid grid-cols-2 gap-2">
                {for s in suspects {
                    <AccuseOption key={s.id} sid={s.id} name={s.name} role={s.role} selected={s.id == accuseId} onPick={onPick} />
                }}
            </div>
            <input
                className="rounded-lg border bg-background px-3 py-2 outline-none focus:border-primary"
                value={reason}
                placeholder="One line: why them?"
                onChange={handle_reason}
            />
            {errorMsg and <p className="text-sm text-destructive">{errorMsg}</p>}
            <div className="flex justify-end gap-2">
                <button className="rounded-lg border px-4 py-2 disabled:opacity-50" disabled={busy} onClick={handle_cancel}>
                    Cancel
                </button>
                <button
                    className="rounded-lg bg-destructive px-4 py-2 font-semibold text-white disabled:opacity-50"
                    disabled={busy}
                    onClick={handle_submit}
                >
                    {"Accusing..." if busy else "Accuse"}
                </button>
            </div>
        </div>
    </div>;
}
