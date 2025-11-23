#ifndef COMP_OPTIONS_H
#define COMP_OPTIONS_H

#include "types/string.h"

typedef enum {
	_fauto_inc_dec,
	_fbranch_count_reg,
	_fcombine_stack_adjustments,
	_fcompare_elim,
	_fcprop_registers,
	_fdce,
	_fdefer_pop,
	_fdelayed_branch,
	_fdse,
	_fforward_propagate,
	_fguess_branch_probability,
	_fif_conversion,
	_fif_conversion2,
	_finline_functions_called_once,
	_fipa_modref,
	_fipa_profile,
	_fipa_pure_const,
	_fipa_reference,
	_fipa_reference_addressable,
	_fivopts,
	_fmerge_constants,
	_fmove_loop_invariants,
	_fmove_loop_stores,
	_fomit_frame_pointer,
	_freorder_blocks,
	_fshrink_wrap,
	_fshrink_wrap_separate,
	_fsplit_wide_types,
	_fssa_backprop,
	_fssa_phiopt,
	_ftree_bit_ccp,
	_ftree_ccp,
	_ftree_ch,
	_ftree_coalesce_vars,
	_ftree_copy_prop,
	_ftree_dce,
	_ftree_dominator_opts,
	_ftree_dse,
	_ftree_forwprop,
	_ftree_fre,
	_ftree_phiprop,
	_ftree_pta,
	_ftree_scev_cprop,
	_ftree_sink,
	_ftree_slsr,
	_ftree_sra,
	_ftree_ter,
	_funit_at_a_time,
	_falign_functions,
	_falign_jumps,
	_falign_labels,
	_falign_loops,
	_fcaller_saves,
	_fcode_hoisting,
	_fcrossjumping,
	_fcse_follow_jumps,
	_fcse_skip_blocks,
	_fdelete_null_pointer_checks,
	_fdevirtualize,
	_fdevirtualize_speculatively,
	_fexpensive_optimizations,
	_ffinite_loops,
	_fgcse,
	_fgcse_lm,
	_fhoist_adjacent_loads,
	_finline_functions,
	_finline_small_functions,
	_findirect_inlining,
	_fipa_bit_cp,
	_fipa_cp,
	_fipa_icf,
	_fipa_ra,
	_fipa_sra,
	_fipa_vrp,
	_fisolate_erroneous_paths_dereference,
	_flra_remat,
	_foptimize_crc,
	_foptimize_sibling_calls,
	_foptimize_strlen,
	_fpartial_inlining,
	_fpeephole2,
	_freorder_blocks_algorithm, //=stc
	_freorder_blocks_and_partition,
	_freorder_functions,
	_frerun_cse_after_loop,
	_fschedule_insns,
	_fschedule_insns2,
	_fsched_interblock,
	_fsched_spec,
	_fstore_merging,
	_fstrict_aliasing,
	_fthread_jumps,
	_ftree_builtin_call_dce,
	_ftree_loop_vectorize,
	_ftree_pre,
	_ftree_slp_vectorize,
	_ftree_switch_conversion,
	_ftree_tail_merge,
	_ftree_vrp,
	_fvect_cost_model, //=very_cheap
	_fgcse_after_reload,
	_fipa_cp_clone,
	_floop_interchange,
	_floop_unroll_and_jam,
	_fpeel_loops,
	_fpredictive_commoning,
	_fsplit_loops,
	_fsplit_paths,
	_ftree_loop_distribution,
	_ftree_partial_pre,
	_funswitch_loops,
	//_fvect_cost_model,//=dynamic
	_fversion_loops_for_strides,
	_fprefetch_loop_arrays,
} Optimization;

dyn_array_decl(Optimization);

typedef struct {
	enum {
		Object,
		StaticLib,
		DynLib,
		Bin,
	} object_type;
	Slice(Optimization) optimizations;
	bool emit_llvm;
	Slice(str) assembler_args;
	Slice(str) linker_args;
	enum {
		x86_64_unknown_linux_gnu,
	} target;
} CompOutput;

dyn_array_decl(CompOutput);

typedef struct {
	Slice(str) luna_src_dirs;
	Slice(str) c_header_dirs;
	Slice(str) lib_dirs;
	Slice(str) libs;
	Slice(CompOutput) outputs;
} CompOptions;

CompOptions CompOptions_default_bin();
CompOptions CompOptions_default_lib();

#endif //COMP_OPTIONS_H