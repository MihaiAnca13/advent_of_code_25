import std/[strutils, sequtils, strscans, parseutils]

const TargetFile = "day10/input.txt"

# =========================================================
# SECTION 1: MANUAL GLPK BINDINGS
# =========================================================

const LibName = "glpk.dll" 

# GLPK Constants
const 
    GLP_MIN = 1
    GLP_MAX = 2
    GLP_CV  = 1 
    GLP_IV  = 2 
    GLP_DB  = 4 
    GLP_LO  = 2 
    GLP_FX  = 5 
    GLP_ON  = 1
    GLP_MSG_OFF = 0

type 
    glp_prob = ptr object
    glp_iocp = object
        msg_lev: cint
        br_tech: cint
        bt_tech: cint
        tol_int: cdouble
        tol_obj: cdouble
        tm_lim: cint
        out_frq: cint
        out_dly: cint
        cb_func: pointer
        cb_info: pointer
        cb_size: cint
        pp_tech: cint
        mip_gap: cdouble
        mir_cuts: cint
        gmi_cuts: cint
        cov_cuts: cint
        clq_cuts: cint
        presolve: cint
        binarize: cint
        fp_heur: cint
        ps_heur: cint
        ps_tm_lim: cint
        sr_heur: cint
        use_sol: cint
        save_sol: cstring
        alien: cint
        flip_oct: cint
        presolve_delay: cint
        rotate: cint
        branch_order: cint
        reserved: array[40, cint] 

{.push dynlib: LibName, cdecl, importc.}

proc glp_create_prob(): glp_prob
proc glp_delete_prob(lp: glp_prob)
proc glp_set_prob_name(lp: glp_prob, name: cstring)
proc glp_set_obj_dir(lp: glp_prob, dir: cint)
proc glp_add_rows(lp: glp_prob, n_rows: cint): cint
proc glp_add_cols(lp: glp_prob, n_cols: cint): cint
proc glp_set_row_bnds(lp: glp_prob, i: cint, kind: cint, lb, ub: cdouble)
proc glp_set_col_kind(lp: glp_prob, j: cint, kind: cint)
proc glp_set_col_bnds(lp: glp_prob, j: cint, kind: cint, lb, ub: cdouble)
proc glp_set_obj_coef(lp: glp_prob, j: cint, coef: cdouble)
proc glp_load_matrix(lp: glp_prob, ne: cint, ia, ja: ptr cint, ar: ptr cdouble)
proc glp_init_iocp(parm: ptr glp_iocp)
proc glp_intopt(lp: glp_prob, parm: ptr glp_iocp): cint
proc glp_mip_obj_val(lp: glp_prob): cdouble

{.pop.}

# =========================================================
# SECTION 2: THE SOLUTION
# =========================================================

type Machine = object
    id: string
    button_vectors: seq[seq[int]] 
    target_vector: seq[int]

proc parseVector(input: string, dims: int): seq[int] =
    var clean = input.strip(chars={'(',')', '{', '}'})
    if clean.len == 0: return newSeqWith(dims, 0)
    let indices = clean.split(',').map(parseInt)
    result = newSeqWith(dims, 0)
    for idx in indices:
        if idx < dims: result[idx] = 1

proc solve_machine(machine: Machine): int =
    # 1. Create Problem
    let lp = glp_create_prob()
    glp_set_obj_dir(lp, GLP_MIN) # Minimize

    let n_cols = machine.button_vectors.len
    let n_rows = machine.target_vector.len

    # 2. Define Columns (Buttons)
    # GLPK uses 1-based indexing for add_cols
    discard glp_add_cols(lp, cint(n_cols))
    for j in 1 .. n_cols:
        glp_set_col_kind(lp, cint(j), GLP_IV)      # Integer Variable
        glp_set_col_bnds(lp, cint(j), GLP_LO, 0.0, 0.0) # Lower bound >= 0, No upper bound
        glp_set_obj_coef(lp, cint(j), 1.0)         # Cost = 1 per press

    # 3. Define Rows (Dimensions/Constraints)
    discard glp_add_rows(lp, cint(n_rows))
    for i in 1 .. n_rows:
        # Each dimension must EXACTLY equal the target value
        let targetVal = cdouble(machine.target_vector[i-1])
        glp_set_row_bnds(lp, cint(i), GLP_FX, targetVal, targetVal)

    # 4. Build Matrix (Coefficients)
    # Flatten 2D array into 3 1D arrays for GLPK sparse format
    var ia: seq[cint] = @[0.cint] # Row indices (1-based)
    var ja: seq[cint] = @[0.cint] # Col indices (1-based)
    var ar: seq[cdouble] = @[0.0] # Values
    
    # Note: GLPK ignores the 0th element, so we padded above
    var count = 0
    for j in 0 ..< n_cols:
        for i in 0 ..< n_rows:
            let val = machine.button_vectors[j][i]
            if val != 0:
                count.inc
                ia.add(cint(i + 1)) # Row (Dimension)
                ja.add(cint(j + 1)) # Col (Button)
                ar.add(cdouble(val))

    if count > 0:
        glp_load_matrix(lp, cint(count), addr ia[0], addr ja[0], addr ar[0])

    # 5. Solve (Integer Optimizer)
    var params: glp_iocp
    glp_init_iocp(addr params)
    params.presolve = GLP_ON
    params.msg_lev = GLP_MSG_OFF # Silence output

    let ret = glp_intopt(lp, addr params)

    # 6. Retrieve Result
    result = -1
    if ret == 0:
        # ret == 0 means "solver finished", checking if optimal
        let val = glp_mip_obj_val(lp)
        if val > 0.0 or (machine.target_vector.allIt(it == 0)):
             result = int(val + 0.5) # Round to nearest int

    glp_delete_prob(lp)


var machines: seq[Machine]

for line in lines(TargetFile):
    if line.strip.len == 0: continue
    let parts = line.split(' ')
    let rawTarget = parts[parts.high]
    let cleanTarget = rawTarget.strip(chars={'{','}'})
    var realTargetVec: seq[int] = @[]
    if cleanTarget.len > 0:
        realTargetVec = cleanTarget.split(',').map(parseInt)
    
    let dims = realTargetVec.len
    var buttons: seq[seq[int]] = @[]
    for i in 1 ..< parts.high:
        buttons.add(parseVector(parts[i], dims))

    machines.add(Machine(
        id: parts[0],
        target_vector: realTargetVec,
        button_vectors: buttons
    ))

var total = 0
for m in machines:
    let steps = solve_machine(m)
    if steps != -1:
        total += steps

echo "Total Presses: ", total