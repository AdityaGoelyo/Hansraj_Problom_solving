alter table solvers
add column email text;

create table session_attempts (
    id uuid primary key default gen_random_uuid(),
    session_id uuid not null references sessions(id),
    solver_id uuid not null references solvers(id),
    attempt_number int not null,
    unique (session_id, solver_id, attempt_number),
    started_at timestamptz,
    closed_at timestamptz
);

alter table attempts
add column session_attempt_id uuid references session_attempts(id);