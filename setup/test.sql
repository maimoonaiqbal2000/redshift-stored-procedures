CREATE TEMP TABLE tmp_instrument_registry AS SELECT <required_attributes> 
FROM instrument_registry_tbl 
JOIN sec_pad ON sec_pad.deal_underlying_inst_id=instrument_registry_tbl.inst_id;

CREATE TEMP TABLE tmp_instrument_dl AS SELECT <required_attributes> 
FROM instrument_dl JOIN tmp_instrument_registry ON 
tmp_instrument_registry.deal_underlying_inst_id=instrument_dl.inst_id;

CREATE TEMP TABLE tmp_instrument_st1 AS SELECT <required_attributes> 
FROM instrument_st1_tbl JOIN tmp_instrument_dl ON 
tmp_instrument_dl.deal_underlying_inst_id=instrument_st1_tbl.inst_id;

CREATE TEMP TABLE tmp_instrument_rc1 AS SELECT <required_attributes> 
FROM instrument_rc1_tbl JOIN tmp_instrument_st1 ON 
tmp_instrument_st1.deal_underlying_inst_id=instrument_rc1_tbl.inst_id;

CREATE TEMP TABLE tmp_obligor_lu AS SELECT <required_attributes> 
FROM obligor_lu_tbl JOIN tmp_instrument_rc1 ON 
tmp_instrument_rc1.obligor_id=obligor_lu_tbl.obligor_id;

INSERT INTO sec_ul SELECT <required_attributes> 
FROM person_lu_tbl JOIN tmp_obligor_lu ON 
tmp_obligor_lu.obligor_id=person_lu_tbl.obligor_id;
