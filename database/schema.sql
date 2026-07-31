-- the function of this file is to create a schema of tables in which I can easily store data
-- the app is designed to give good problems and collect as much and as high quality as possible solution data to recommend problems

create extension if not exists "pgcrypto";

create table solvers (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    created_at timestamptz default now()
);

create table problems (
    id uuid primary key default gen_random_uuid(),
    problem_type text,
    title text,
    statement_text text,
    statement_latex text,
    statement_html text,
    image_path text,
    source text,
    contributor uuid,
    metadata jsonb not null default '{}',
    created_at timestamptz default now()
);

create table sessions (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    scheduled_at timestamptz,
    title text,
    current_problem_id uuid references problems(id)
);

create table session_problems (
    session_id uuid not null references sessions(id),
    position int not null,
    problem_id uuid not null references problems(id),
    primary key (session_id, problem_id)
);


create table session_states_log (
    id uuid primary key default gen_random_uuid(),
    session_id uuid not null,
    problem_id uuid not null,
    presented_at timestamptz,
    closed_at timestamptz,
    foreign key (session_id, problem_id) references session_problems(session_id, problem_id)
);

-- any kind of problem source is acceptable and the backend/frontend logic should be developed to accomodate

create table solutions (
    id uuid primary key default gen_random_uuid(),
    problem_id uuid not null references problems(id),
    canon boolean not null default false,
    method text not null,
    method_description text,
    title text,
    statement_text text,
    statement_latex text,
    statement_html text,
    image_path text,
    source text,
    contributor uuid,
    metadata jsonb not null default '{}',
    created_at timestamptz default now(),
    unique (id, problem_id)
);

create table hints (
    id uuid primary key default gen_random_uuid(),
    problem_id uuid not null,
    solution_id uuid not null,
    contributor uuid,
    hint_order int not null,
    title text,
    statement_text text,
    statement_latex text,
    statement_html text,
    image_path text,
    source text,
    metadata jsonb not null default '{}',
    created_at timestamptz default now(),
    foreign key (solution_id, problem_id) references solutions(id, problem_id),
    unique (solution_id, hint_order) 
);

/*
create table canonical_solutions (
    id uuid primary key default gen_random_uuid(),
    problem_id uuid not null,
    method text not null,
    method_description text,
    title text,
    statement_text text,
    statement_latex text,
    statement_html text,
    image_path text,
    source text,
    contributor uuid,
    metadata jsonb not null default '{}',
    created_at timestamptz default now(),
    unique (id, problem_id)
);
*/

create table attempts (
    id uuid primary key default gen_random_uuid(),
    solver_id uuid not null references solvers(id),
    problem_id uuid not null references problems(id),
    solution_id uuid references solutions(id),
    session_id uuid not null references sessions(id),
    attempt_number int not null default 1, -- indexing by 1
    is_correct boolean,
    time_taken_seconds int,
    difficulty_self_rating int,
    how_interesting_and_informative int,
    self_reported_method_note text,     -- filled when the student picks "Other" instead
                                        -- of a known solution — free text describing
                                        -- their approach, for you to review later and
                                        -- possibly promote into a new `solutions` row
    submitted_at     timestamptz not null default now(),
    unique (solver_id, problem_id, attempt_number)
);

create table attempt_hints (
    attempt_id uuid not null references attempts(id),
    hint_id uuid not null references hints(id),
    requested_at timestamptz default now(),
    primary key (attempt_id, hint_id)
);