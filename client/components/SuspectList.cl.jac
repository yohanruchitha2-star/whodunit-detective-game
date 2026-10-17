"""The four suspect cards (left panel). Click one to question them."""

sv import from game.types { PublicSuspect }

def:pub SuspectCard(
    sid: str,
    name: str,
    role: str,
    personality: str,
    selected: bool,
    isCracked: bool,
    onSelect: Callable[[str], None]
) -> JsxElement {
    def handle_click(_e: MouseEvent) {
        onSelect(sid);
    }

    border = "border-primary bg-primary/10" if selected else "border-border bg-background hover:border-primary/60";
    avatar = "bg-destructive text-white" if isCracked else "bg-primary text-primary-foreground";
    return <button
        className={"flex w-full items-center gap-3 rounded-lg border p-2.5 text-left transition " + border}
        onClick={handle_click}
    >
        <span className={"flex size-9 shrink-0 items-center justify-center rounded-full font-bold " + avatar}>
            {name[0] if name else "?"}
        </span>
        <span className="flex-1">
            <span className="block font-semibold">{name}</span>
            <span className="block text-xs text-muted-foreground">
                {role + ((" · " + personality) if personality else "")}
            </span>
        </span>
        {isCracked and <span className="rounded-full bg-destructive px-2 py-0.5 text-[10px] font-bold tracking-wider text-white">
            CRACKED
        </span>}
    </button>;
}

def:pub SuspectList(
    suspects: list[PublicSuspect],
    selectedId: str,
    cracked: list[str],
    onSelect: Callable[[str], None]
) -> JsxElement {
    return <section className="flex flex-col gap-2 rounded-xl border bg-card p-4">
        <p className="text-xs font-bold tracking-[0.15em] text-primary">SUSPECTS</p>
        {for s in suspects {
            <SuspectCard
                key={s.id}
                sid={s.id}
                name={s.name}
                role={s.role}
                personality={s.style}
                selected={s.id == selectedId}
                isCracked={s.cracked or s.id in cracked}
                onSelect={onSelect}
            />
        }}
    </section>;
}
