%-----------------------------------------------------------------------
% Job saved on 06-Dec-2018 19:12:20 by cfg_util (rev $Rev: 380 $)
% pspm PsPM - Unknown
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.datafile = '<UNDEFINED>';
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.pupil.chan_nr.chan_nr_spec = 1;
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.pupil.sample_rate = 60;
matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = true;
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.modelfile = '<UNDEFINED>';
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.outdir = '<UNDEFINED>';
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.chan.chan_def.best_eye = 'pupil';
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.timeunits.samples = 'samples';
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.datafile(1) = cfg_dep('Import: Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{':'}));
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.missing.no_epochs = 0;
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condfile = '<UNDEFINED>';
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.nuisancefile = {''};
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.latency.fixed = 'fixed'; %alternatively: 'free'
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.bf.psrf_fc1 = 1;
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.norm = false;
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.filter.def = 0;
matlabbatch{2}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.overwrite = true;
