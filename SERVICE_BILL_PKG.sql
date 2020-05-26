CREATE OR REPLACE PACKAGE "SERVICE_BILL_PKG" AS
	FUNCTION get_code_desc (
		p_code_type   VARCHAR2,
		p_code_no     VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_pat_name_ch (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_pat_name_en (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_pat_name_unicode (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_pat_nat_no (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_pat_no (
		p_hidno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_emp_name_ch (
		p_cardno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_emp_dept_no (
		p_cardno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_emp_dept_name (
		p_cardno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_emp_nat_no (
		p_cardno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_emp_card_no (
		p_psnidno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_adm_total_payable_amt (
		p_caseno     VARCHAR2,
		p_pfincode   VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_adm_fee_type_payable_amt (
		p_caseno     VARCHAR2,
		p_fee_type   VARCHAR2,
		p_pfincode   VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_emg_total_payable_amt (
		p_caseno     VARCHAR2,
		p_pfincode   VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_adm_total_prepaid_amt (
		p_caseno     VARCHAR2,
		p_unitcode   VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_emg_total_prepaid_amt (
		p_caseno     VARCHAR2,
		p_unitcode   VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_adm_owed_amt (
		p_caseno     VARCHAR2,
		p_unitcode   VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_emg_owed_amt (
		p_caseno     VARCHAR2,
		p_unitcode   VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_adm_total_contract_amt (
		p_caseno VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_emg_total_contract_amt (
		p_caseno VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_adm_tot_negot_instru_amt (
		p_caseno VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_emg_tot_negot_instru_amt (
		p_caseno VARCHAR2
	) RETURN NUMBER;
	FUNCTION get_preauthorized_enabled RETURN VARCHAR2;
	FUNCTION get_atm_card_enabled RETURN VARCHAR2;
	FUNCTION get_last_electr_trans_time (
		p_caseno VARCHAR2
	) RETURN DATE;
	FUNCTION get_adm_bill_pay_state (
		p_dischg_bill_no   VARCHAR2,
		p_caseno           VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_contract_bill_pay_state (
		p_adjst_bill_no   VARCHAR2,
		p_caseno          VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION check_is_full_payment (
		p_caseno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION check_is_full_negot_instru (
		p_caseno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_pat_state (
		p_hcaseno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_logic_id_by_host_id (
		p_code_no VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_logic_id_by_nurses (
		p_hnurstat   VARCHAR2,
		p_hbedno     VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_printer_id (
		p_logid    VARCHAR2,
		p_sys_id   VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_vtan_status (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_certificate_charge_seq RETURN NUMBER;
	FUNCTION get_last_cert_year_seq_no (
		p_abstype IN VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_fee_adjust_seq_no RETURN VARCHAR2;
	FUNCTION get_adm_pickup_medicine_no (
		p_encounter_id IN VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_emg_pickup_medicine_no (
		p_encounter_id IN VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_num_of_uncal_charge_item (
		p_caseno IN VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_adm_fee_locked_flag (
		p_caseno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_emg_fee_locked_flag (
		p_caseno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION check_has_been_bad_debt (
		p_caseno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_num_of_curr_db_sessions RETURN NUMBER;
	FUNCTION get_icd_name (
		p_icd_key   IN   VARCHAR2,
		p_lang      IN   VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_sw_flag (
		p_caseno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_last_nhi_apply_end_date (
		p_caseno VARCHAR2
	) RETURN DATE;
	PROCEDURE get_printer (
		p_prtid    IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_nurs_sta_printer_list (
		p_cursor OUT SYS_REFCURSOR
	);
	PROCEDURE get_code_mapping_list (
		p_code_type   IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	);
	PROCEDURE get_icd_info (
		p_icd_key   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_nurses_station_bed_no (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_nurses_station_bed_no (
		p_ecaseno   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_preauthorized_info (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_bed_info (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	FUNCTION get_bil_billmst_pay_state (
		p_dischg_bill_no   VARCHAR2,
		p_caseno           VARCHAR2,
		p_unitcode         VARCHAR2
	) RETURN VARCHAR2;
	PROCEDURE charge_adm_bill (
		p_dischg_bill_no    IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_pat_kind          IN    VARCHAR2,
		p_pat_paid_amt      IN    NUMBER,
		p_last_updated_by   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_host_id           IN    VARCHAR2,
		p_unitcode          IN    VARCHAR2,
		p_printer_id        IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE charge_emg_bill (
		p_dischg_bill_no    IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_pat_kind          IN    VARCHAR2,
		p_pat_paid_amt      IN    NUMBER,
		p_last_updated_by   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_host_id           IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE cancel_adm_bill (
		p_dischg_bill_no    IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_cancel_oper       IN    VARCHAR2,
		p_unitcode          IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE update_adm_bill_epay_info (
		p_dischg_bill_no    IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_seqno             IN    VARCHAR2,
		p_act_status        IN    VARCHAR2,
		p_last_updated_by   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_host_id           VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE upd_adm_bill_credit_pay_info (
		p_dischg_bill_no            IN    VARCHAR2,
		p_caseno                    IN    VARCHAR2,
		p_credit_card_approval_no   IN    VARCHAR2,
		p_last_updated_by           IN    VARCHAR2,
		p_handler                   IN    VARCHAR2,
		p_host_id                   VARCHAR2,
		p_num_of_aff_rows           OUT   NUMBER
	);
	PROCEDURE ins_upd_emg_bil_debt_rec (
		p_caseno             IN    VARCHAR2,
		p_change_flag        IN    VARCHAR2,
		p_display_flag       IN    VARCHAR2,
		p_overdue_date       IN    DATE,
		p_baddebt_date       IN    DATE,
		p_baddebt_document   IN    VARCHAR2,
		p_opr_emp_id         VARCHAR2,
		p_num_of_aff_rows    OUT   NUMBER
	);
	PROCEDURE get_priced_item_info (
		p_pf_key   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_priced_item_info_list (
		p_pricety1        IN    VARCHAR2,
		p_pfkey_pattern   IN    VARCHAR2,
		p_cursor          OUT   SYS_REFCURSOR
	);
	PROCEDURE get_priced_item_daily_revenue (
		p_pf_key           IN    VARCHAR2,
		p_start_bil_date   IN    DATE,
		p_end_bil_date     IN    DATE,
		p_cursor           OUT   SYS_REFCURSOR
	);
	PROCEDURE lock_bil_root_rec (
		p_caseno            IN    VARCHAR2,
		p_last_updated_by   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE unlock_bil_root_rec (
		p_caseno            IN    VARCHAR2,
		p_last_updated_by   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_nurses_station_list (
		p_cursor OUT SYS_REFCURSOR
	);
	PROCEDURE get_abs_form_def_mas_list (
		p_cursor OUT SYS_REFCURSOR
	);
	PROCEDURE get_certificate_root_list (
		p_absno    IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_certificate_data (
		p_abstype   IN    VARCHAR2,
		p_absno     IN    VARCHAR2,
		p_absseq    IN    NUMBER,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_abs_data_lob (
		p_abstype   IN    VARCHAR2,
		p_absno     IN    VARCHAR2,
		p_absseq    IN    NUMBER,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE update_certificate_data (
		p_abstype           IN    VARCHAR2,
		p_absno             IN    VARCHAR2,
		p_absseq            IN    NUMBER,
		p_col_id            IN    VARCHAR2,
		p_col_content       IN    VARCHAR2,
		p_updater           IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE upd_abs_root (
		p_abstype            IN    VARCHAR2,-- 證明種類
		p_absno              IN    VARCHAR2,-- 證明編號
		p_absseq             IN    NUMBER,  -- 證明序號
		p_certpsn            IN    VARCHAR2,-- 換領承辦人
		p_certprcp           IN    NUMBER,  -- 換領份數
		p_certpsns           IN    VARCHAR2,-- 領取人
		p_current_free_qty   IN    NUMBER,  -- 本次優待份數
		p_certseq            IN    VARCHAR, -- 證字號(年份4碼 + 流水號5碼)
		p_num_of_aff_rows    OUT   NUMBER
	);
	PROCEDURE charge_adm_certificate (
		p_seqno             IN    NUMBER,  -- 換領入帳序號
		p_hhisnum           IN    VARCHAR2,-- 病歷號
		p_caseno            IN    VARCHAR2,-- 住序院號
		p_abstype           IN    VARCHAR2,-- 證明種類
		p_amount            IN    NUMBER,  -- 數量
		p_price             IN    NUMBER,  -- 單價
		p_total             IN    NUMBER,  -- 總價
		p_chargeuser        IN    VARCHAR2,-- 入帳者卡號
		p_chargeusername    IN    VARCHAR2,-- 入帳者姓名
		p_in_billtemp       IN    VARCHAR2,-- 入住院帳單證書費 flag (Y: 入,N: 不入)
		p_absseq            IN    NUMBER,  -- 證明序號
		p_pat_kind          IN    VARCHAR2,-- 換領地點
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE charge_emg_certificate (
		p_absno             IN    VARCHAR2,-- 證明書CASENO
		p_abstype           IN    VARCHAR2,-- 證明書類別
		p_absseq            IN    NUMBER,  -- 證明書編號
		p_create_time       IN    DATE,    -- 收費日期
		p_creator_cardid    IN    VARCHAR2,-- 收費員卡號
		p_creator_name      IN    VARCHAR2,-- 收費員姓名
		p_amount            IN    NUMBER,  -- 數量
		p_price             IN    NUMBER,  -- 單價
		p_is_charge         IN    VARCHAR2,-- 是否已收費 flag (Y: 是,N: 否)
		p_emgspeu1          IN    VARCHAR2,
		p_emgspeu2          IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_charged_item_rec_list (
		p_caseno     IN    VARCHAR2,
		p_fee_kind   IN    VARCHAR2,
		p_pfincode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	);
	PROCEDURE get_fee_fee_type_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_bill_fee_type_list (
		p_bil_seqno   IN    VARCHAR2,
		p_caseno      IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	);
	PROCEDURE get_fee_financ_type_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_bill_financ_type_list (
		p_bil_seqno   IN    VARCHAR2,
		p_caseno      IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	);
	PROCEDURE get_fee_financ_amt_list (
		p_caseno     IN    VARCHAR2,
		p_fee_type   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_bill_financ_amt_list (
		p_bil_seqno   IN    VARCHAR2,
		p_caseno      IN    VARCHAR2,
		p_fee_type    IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	);
	PROCEDURE log_epay_rec (
		p_caseno              IN    VARCHAR2,
		p_seqno               IN    VARCHAR2,
		p_dischg_bill_no      IN    VARCHAR2,
		p_del_status          IN    VARCHAR2,
		p_created_by          IN    VARCHAR2,
		p_create_user_namec   IN    VARCHAR2,
		p_host_id             IN    VARCHAR2,
		p_pat_kind            IN    VARCHAR2,
		p_sysid               IN    VARCHAR2,
		p_pos_adm             IN    NUMBER,
		p_pos_emg             IN    NUMBER,
		p_pos_opd             IN    NUMBER,
		p_num_of_aff_rows     OUT   NUMBER
	);
	PROCEDURE get_bil_contr_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE ins_upd_bil_contr (
		p_hpatnum           IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_bilcunit          IN    VARCHAR2,
		p_bilcbgdt          IN    DATE,
		p_bilcendt          IN    DATE,
		p_operator_emp_id   IN    VARCHAR2,
		p_stop_flag         IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_bil_contr (
		p_hpatnum           IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_bilcunit          IN    VARCHAR2,
		p_bilcbgdt          IN    DATE,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE reset_bil_date_daily_flag (
		p_caseno            IN    VARCHAR2,
		p_start_bil_date    IN    DATE,
		p_end_bil_date      IN    DATE,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_bil_adjst_mst_list (
		p_adjst_seqno   IN    VARCHAR2,
		p_caseno        IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_bil_adjst_mst_list (
		p_adjst_seqno   IN    VARCHAR2,
		p_caseno        IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	);
	PROCEDURE ins_upd_bil_adjst_mst (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_bil_no            IN    VARCHAR2,
		p_blfrunit          IN    VARCHAR2,
		p_bltounit          IN    VARCHAR2,
		p_bladjtx           IN    VARCHAR2,
		p_adjst_reason      IN    VARCHAR2,
		p_before_amt        IN    NUMBER,
		p_after_fr_amt      IN    NUMBER,
		p_after_to_amt      IN    NUMBER,
		p_operator_emp_id   IN    VARCHAR2,
		p_donee_hpatnum     IN    VARCHAR2,
		p_donee_caseno      IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE ins_upd_emg_bil_adjst_mst (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_emg_bil_no        IN    VARCHAR2,
		p_blfrunit          IN    VARCHAR2,
		p_bltounit          IN    VARCHAR2,
		p_bladjtx           IN    VARCHAR2,
		p_adjst_reason      IN    VARCHAR2,
		p_before_amt        IN    NUMBER,
		p_after_fr_amt      IN    NUMBER,
		p_after_to_amt      IN    NUMBER,
		p_operator_emp_id   IN    VARCHAR2,
		p_donee_hpatnum     IN    VARCHAR2,
		p_donee_caseno      IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_bil_adjst_mst (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_emg_bil_adjst_mst (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_bil_adjst_dtl_list (
		p_adjst_seqno   IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_bil_adjst_dtl_list (
		p_adjst_seqno   IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	);
	PROCEDURE ins_bil_adjst_dtl (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_fee_kind          IN    VARCHAR2,
		p_before_amt        IN    NUMBER,
		p_after_fr_amt      IN    NUMBER,
		p_after_to_amt      IN    NUMBER,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE ins_emg_bil_adjst_dtl (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_fee_kind          IN    VARCHAR2,
		p_before_amt        IN    NUMBER,
		p_after_fr_amt      IN    NUMBER,
		p_after_to_amt      IN    NUMBER,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_bil_adjst_dtl (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_emg_bil_adjst_dtl (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_bil_epay_log_rec (
		p_dischg_bill_no   IN    VARCHAR2,
		p_caseno           IN    VARCHAR2,
		p_seqno            IN    VARCHAR2,
		p_cursor           OUT   SYS_REFCURSOR
	);
	PROCEDURE update_ambulance_record (
		p_id                IN    VARCHAR2,
		p_charge_opid       IN    VARCHAR2,
		p_charge_opname     IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE charge_ambulance (
		p_id                IN    VARCHAR2,-- 救護車計價序號
		p_charge_type       IN    VARCHAR2,-- 繳費方式 (1: 現金,3: 金融卡)
		p_charge_kind       IN    VARCHAR2,-- 入/退帳 (1: 入帳,2: 退帳)
		p_operater_id       IN    VARCHAR2,-- 入帳者卡號
		p_operater_name     IN    VARCHAR2,-- 入帳者姓名
		p_charge_amt        IN    NUMBER,  -- 入帳金額 (含正負)
		p_host_ip           IN    VARCHAR2,-- 入帳 IP
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE ins_ucccmst_rec (
		p_uccclog_seqno        IN    VARCHAR2,-- log 序號
		p_transamount          IN    NUMBER,  -- 交易金額
		p_transdate            IN    VARCHAR2,-- 交易日期
		p_transtime            IN    VARCHAR2,-- 交易時間
		p_storeid              IN    VARCHAR2,-- 櫃號
		p_createid             IN    VARCHAR2,-- 建立者身分證字號
		p_createnmc            IN    VARCHAR2,-- 建立者姓名
		p_createcard           IN    VARCHAR2,-- 建立者卡號
		p_rollbackapprovalno   IN    VARCHAR2,-- 沖正授權碼
		p_manual_yn            IN    VARCHAR2,-- 是否手動輸入
		p_num_of_aff_rows      OUT   NUMBER
	);
	PROCEDURE upd_ucccmst_rec (
		p_uccclog_seqno     IN    VARCHAR2,-- log 序號
		p_receiptno         IN    VARCHAR2,-- 簽單序號
		p_cardno            IN    VARCHAR2,-- 卡號
		p_approvalno        IN    VARCHAR2,-- 授權碼
		p_wavecard          IN    VARCHAR2,-- 感應卡卡別
		p_ecrresponsecode   IN    VARCHAR2,-- 通訊回應碼
		p_merchantid        IN    VARCHAR2,-- 商店代號
		p_terminalid        IN    VARCHAR2,-- 收銀機代號
		p_cardtype          IN    VARCHAR2,-- 卡別
		p_batchno           IN    VARCHAR2,-- 批次號碼
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE ins_ucccdtl_rec (
		p_uccclog_seqno     IN    VARCHAR2,-- log 序號
		p_hcaseno           IN    VARCHAR2,-- 就診號
		p_encnttype         IN    VARCHAR2,-- 診別
		p_dischg_bill_no    IN    VARCHAR2,-- 帳單號
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_newborn_self_pay_rsn_rec (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE ins_upd_nb_self_pay_rsn_rec (
		p_caseno            IN    VARCHAR2,
		p_patnum            IN    VARCHAR2,
		p_chang_reason      IN    VARCHAR2,
		p_effective_date    IN    DATE,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_nb_self_pay_rsn_rec (
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_bil_date_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE upd_bil_date (
		p_caseno            IN    VARCHAR2,
		p_bil_date          IN    DATE,
		p_blmeal            IN    VARCHAR2,
		p_beddge            IN    VARCHAR2,
		p_bldiet            IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_nhi_trans_rec_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_pat_basic (
		p_hhisnum   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_query_keys (
		p_case_type   IN    VARCHAR2,
		p_hhisnum     IN    VARCHAR2,
		p_caseno      IN    VARCHAR2,
		p_hidno       IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	);
	PROCEDURE get_pat_adm_case_list (
		p_hcaseno   IN    VARCHAR2,
		p_hhisnum   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_pat_emg_casen_list (
		p_ecaseno    IN    VARCHAR2,
		p_emghhist   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	);
	PROCEDURE get_ambulance_record_list (
		p_id        IN    VARCHAR2,
		p_hhisnum   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_opdroot_list (
		p_opdcaseno   IN    VARCHAR2,
		p_hhisnum     IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	);
	PROCEDURE get_bil_feemst (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_bil_feemst (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_bil_billmst_list (
		p_caseno     IN    VARCHAR2,
		p_unitcode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_bil_billmst_list (
		p_caseno     IN    VARCHAR2,
		p_unitcode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	);
	PROCEDURE get_bil_check_bill_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_bil_check_bill_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_bil_debt_rec_list (
		p_hpatnum             IN    VARCHAR2,
		p_caseno              IN    VARCHAR2,
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_lower_thold_amt     IN    NUMBER,
		p_upper_thold_amt     IN    NUMBER,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_bil_debt_rec_list (
		p_hpatnum             IN    VARCHAR2,
		p_caseno              IN    VARCHAR2,
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_lower_thold_amt     IN    NUMBER,
		p_upper_thold_amt     IN    NUMBER,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_opddebt_list (
		p_hhisnum           IN    VARCHAR2,
		p_hcaseno           IN    VARCHAR2,
		p_start_visitdate   IN    DATE,
		p_end_visitdate     IN    DATE,
		p_lower_thold_amt   IN    NUMBER,
		p_upper_thold_amt   IN    NUMBER,
		p_cursor            OUT   SYS_REFCURSOR
	);
	PROCEDURE get_pat_adm_financial_list (
		p_hcaseno   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_bil_critical_dtl_list (
		p_hhisnum      IN    VARCHAR2,
		p_icd          IN    VARCHAR2,
		p_begin_date   IN    DATE,
		p_end_date     IN    DATE,
		p_cursor       OUT   SYS_REFCURSOR
	);
	PROCEDURE get_abs_charge_list (
		p_abstype   IN    VARCHAR2,
		p_absno     IN    VARCHAR2,
		p_absseq    IN    NUMBER,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_abs_emg_charge_list (
		p_abstype   IN    VARCHAR2,
		p_absno     IN    VARCHAR2,
		p_absseq    IN    NUMBER,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_ambulance_charge_list (
		p_id       IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE ins_upd_bil_debt_rec (
		p_caseno             IN    VARCHAR2,
		p_change_flag        IN    VARCHAR2,
		p_overdue_date       IN    DATE,
		p_baddebt_date       IN    DATE,
		p_baddebt_document   IN    VARCHAR2,
		p_display_flag       IN    VARCHAR2,
		p_opr_emp_id         VARCHAR2,
		p_num_of_aff_rows    OUT   NUMBER
	);
	PROCEDURE ins_upd_bil_check_bill (
		p_caseno            IN    VARCHAR2,
		p_check_no          IN    VARCHAR2,
		p_bill_kind         IN    VARCHAR2,
		p_bill_amt          IN    NUMBER,
		p_bank_name         IN    VARCHAR2,
		p_accountno         IN    VARCHAR2,
		p_bill_date         IN    DATE,
		p_due_date          IN    DATE,
		p_pay_date          IN    DATE,
		p_return_date       IN    DATE,
		p_status            IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_note              IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE ins_upd_emg_bil_check_bill (
		p_caseno            IN    VARCHAR2,
		p_check_no          IN    VARCHAR2,
		p_bill_kind         IN    VARCHAR2,
		p_bill_amt          IN    NUMBER,
		p_bank_name         IN    VARCHAR2,
		p_accountno         IN    VARCHAR2,
		p_bill_date         IN    DATE,
		p_due_date          IN    DATE,
		p_pay_date          IN    DATE,
		p_return_date       IN    DATE,
		p_status            IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_note              IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE ins_upd_bil_critical_mst (
		p_hhisnum           IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE ins_upd_bil_critical_dtl (
		p_hhisnum           IN    VARCHAR2,
		p_copayno           IN    VARCHAR2,
		p_copayicd          IN    VARCHAR2,
		p_copaybdt          IN    DATE,
		p_copayedt          IN    DATE,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_bil_check_bill (
		p_caseno            IN    VARCHAR2,
		p_check_no          IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_emg_bil_check_bill (
		p_caseno            IN    VARCHAR2,
		p_check_no          IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_bil_critical_dtl (
		p_hhisnum           IN    VARCHAR2,
		p_copayicd          IN    VARCHAR2,
		p_copaybdt          IN    DATE,
		p_copayedt          IN    DATE,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_vtan_subsidy_list (
		p_idno     IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	);
	PROCEDURE apply_adm_vtan_subsidy (
		p_caseno    IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	);
	PROCEDURE apply_emg_vtan_subsidy (
		p_ecaseno   IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	);
	PROCEDURE get_bil_billdtl_list (
		p_bil_seqno   IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_bil_billdtl_list (
		p_emg_bil_seqno   IN    VARCHAR2,
		p_cursor          OUT   SYS_REFCURSOR
	);
	PROCEDURE ins_upd_pat_adm_financial (
		p_hcaseno           IN    VARCHAR2,
		p_hfinancl          IN    VARCHAR2,
		p_hfindate          IN    DATE,
		p_hfinuser          IN    VARCHAR2,
		p_hnhi1typ          IN    VARCHAR2,
		p_hcard             IN    VARCHAR2,
		p_hpaytype          IN    VARCHAR2,
		p_htraffic          IN    VARCHAR2,
		p_hcvadt            IN    DATE,
		p_hcardic           IN    VARCHAR2,
		p_hfininf_bil       IN    DATE,
		p_hnhi1end          IN    DATE,
		p_hfincl2           IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE del_pat_adm_financial (
		p_hcaseno           IN    VARCHAR2,
		p_hfinancl          IN    VARCHAR2,
		p_hfindate          IN    DATE,
		p_num_of_aff_rows   OUT   NUMBER
	);
	PROCEDURE get_bil_feedtl_list (
		p_caseno     IN    VARCHAR2,
		p_pfincode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_bil_feedtl_list (
		p_caseno     IN    VARCHAR2,
		p_pfincode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	);
	PROCEDURE get_deposit_charge_list (
		p_hhisnum   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_occur_list (
		i_caseno       IN    VARCHAR2,
		o_sys_refcur   OUT   SYS_REFCURSOR
	);
END service_bill_pkg;

/


CREATE OR REPLACE PACKAGE BODY "SERVICE_BILL_PKG" AS
	FUNCTION get_code_desc (
		p_code_type   VARCHAR2,
		p_code_no     VARCHAR2
	) RETURN VARCHAR2 IS
		code_desc VARCHAR2 (500);
	BEGIN
		SELECT
			code_desc
		INTO code_desc
		FROM
			bil_codedtl
		WHERE
			code_type = p_code_type
			AND
			code_no = p_code_no;
		RETURN code_desc;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN code_desc;
	END;
	FUNCTION get_pat_name_ch (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2 IS
		pat_name_ch VARCHAR2 (24);
	BEGIN
		SELECT
			hnamec
		INTO pat_name_ch
		FROM
			common.pat_basic
		WHERE
			hhisnum = p_hhisnum;
		RETURN pat_name_ch;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pat_name_ch;
	END;
	FUNCTION get_pat_name_en (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2 IS
		pat_name_en VARCHAR2 (26);
	BEGIN
		SELECT
			hname
		INTO pat_name_en
		FROM
			common.pat_basic
		WHERE
			hhisnum = p_hhisnum;
		RETURN pat_name_en;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pat_name_en;
	END;
	FUNCTION get_pat_name_unicode (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2 IS
		pat_name_unicode VARCHAR2 (50);
	BEGIN
		SELECT
			hnameu
		INTO pat_name_unicode
		FROM
			common.pat_basic
		WHERE
			hhisnum = p_hhisnum;
		RETURN pat_name_unicode;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pat_name_unicode;
	END;
	FUNCTION get_pat_nat_no (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2 IS
		pat_nat_no VARCHAR2 (10);
	BEGIN
		SELECT
			hidno
		INTO pat_nat_no
		FROM
			common.pat_basic
		WHERE
			hhisnum = p_hhisnum;
		RETURN pat_nat_no;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pat_nat_no;
	END;
	FUNCTION get_pat_no (
		p_hidno VARCHAR2
	) RETURN VARCHAR2 IS
		pat_no VARCHAR2 (10);
	BEGIN
		SELECT
			hhisnum
		INTO pat_no
		FROM
			common.pat_basic
		WHERE
			hidno = p_hidno;
		RETURN pat_no;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pat_no;
	END;
	FUNCTION get_emp_name_ch (
		p_cardno VARCHAR2
	) RETURN VARCHAR2 IS
		emp_name_ch VARCHAR2 (10);
	BEGIN
		SELECT
			namec
		INTO emp_name_ch
		FROM
			common.psbasic_vghtc
		WHERE
			cardno = p_cardno;
		RETURN emp_name_ch;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN emp_name_ch;
	END;
	FUNCTION get_emp_dept_no (
		p_cardno VARCHAR2
	) RETURN VARCHAR2 IS
		emp_dept_no VARCHAR2 (10);
	BEGIN
		SELECT
			cunit1
		INTO emp_dept_no
		FROM
			common.psbasic_vghtc
		WHERE
			cardno = p_cardno;
		RETURN emp_dept_no;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN emp_dept_no;
	END;
	FUNCTION get_emp_dept_name (
		p_cardno VARCHAR2
	) RETURN VARCHAR2 IS
		emp_dept_name VARCHAR2 (20);
	BEGIN
		SELECT
			service_bill_pkg.get_code_desc ('Dept', service_bill_pkg.get_emp_dept_no (p_cardno))
		INTO emp_dept_name
		FROM
			common.psbasic_vghtc
		WHERE
			cardno = p_cardno;
		RETURN emp_dept_name;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN emp_dept_name;
	END;
	FUNCTION get_emp_nat_no (
		p_cardno VARCHAR2
	) RETURN VARCHAR2 IS
		emp_nat_no VARCHAR2 (10);
	BEGIN
		SELECT
			psnidno
		INTO emp_nat_no
		FROM
			common.psbasic_vghtc
		WHERE
			cardno = p_cardno;
		RETURN emp_nat_no;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN emp_nat_no;
	END;
	FUNCTION get_emp_card_no (
		p_psnidno VARCHAR2
	) RETURN VARCHAR2 IS
		emp_card_no VARCHAR2 (5);
	BEGIN
		SELECT
			cardno
		INTO emp_card_no
		FROM
			common.psbasic_vghtc
		WHERE
			psnidno = p_psnidno;
		RETURN emp_card_no;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN emp_card_no;
	END;
	FUNCTION get_adm_total_payable_amt (
		p_caseno     VARCHAR2,
		p_pfincode   VARCHAR2
	) RETURN NUMBER IS
		total_payable_amt NUMBER := 0;
	BEGIN
		SELECT
			nvl (round (SUM (nvl (total_amt, 0))), 0)
		INTO total_payable_amt
		FROM
			bil_feedtl
		WHERE
			caseno = p_caseno
			AND
			pfincode = p_pfincode;
		RETURN total_payable_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN total_payable_amt;
	END;
	FUNCTION get_adm_fee_type_payable_amt (
		p_caseno     VARCHAR2,
		p_fee_type   VARCHAR2,
		p_pfincode   VARCHAR2
	) RETURN NUMBER IS
		v_fee_type_payable_amt NUMBER := 0;
	BEGIN
		SELECT
			nvl (total_amt, 0)
		INTO v_fee_type_payable_amt
		FROM
			bil_feedtl
		WHERE
			caseno = p_caseno
			AND
			fee_type = p_fee_type
			AND
			pfincode = p_pfincode;
		RETURN v_fee_type_payable_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN v_fee_type_payable_amt;
	END;
	FUNCTION get_emg_total_payable_amt (
		p_caseno     VARCHAR2,
		p_pfincode   VARCHAR2
	) RETURN NUMBER IS
		total_payable_amt NUMBER := 0;
	BEGIN
		SELECT
			nvl (round (SUM (nvl (total_amt, 0))), 0)
		INTO total_payable_amt
		FROM
			emg_bil_feedtl
		WHERE
			caseno = p_caseno
			AND
			pfincode = p_pfincode;
		RETURN total_payable_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN total_payable_amt;
	END;
	FUNCTION get_adm_total_prepaid_amt (
		p_caseno     VARCHAR2,
		p_unitcode   VARCHAR2
	) RETURN NUMBER IS
		total_prepaid_amt NUMBER := 0;
	BEGIN
		SELECT
			nvl (SUM (nvl (pat_paid_amt, 0)), 0)
		INTO total_prepaid_amt
		FROM
			bil_billmst
		WHERE
			rec_status = 'Y'
			AND
			caseno = p_caseno
			AND
			unitcode = p_unitcode;
		RETURN total_prepaid_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN total_prepaid_amt;
	END;
	FUNCTION get_emg_total_prepaid_amt (
		p_caseno     VARCHAR2,
		p_unitcode   VARCHAR2
	) RETURN NUMBER IS
		total_prepaid_amt NUMBER := 0;
	BEGIN
		SELECT
			nvl (SUM (nvl (paid_amt, 0)), 0)
		INTO total_prepaid_amt
		FROM
			(
				SELECT
					(
						CASE
							WHEN refund_amt IS NOT NULL THEN
								0 - refund_amt
							ELSE
								pat_paid_amt
						END
					) AS paid_amt
				FROM
					emg_bil_billmst
				WHERE
					paid_flag IN (
						'Y',
						'R',
						'C'
					)
					AND
					rec_status IN (
						'Y',
						'C'
					)
					AND
					caseno = p_caseno
					AND
					unitcode = p_unitcode
			);
		RETURN total_prepaid_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN total_prepaid_amt;
	END;
	FUNCTION get_adm_owed_amt (
		p_caseno     VARCHAR2,
		p_unitcode   VARCHAR2
	) RETURN NUMBER IS
		total_payable_amt   NUMBER := 0;
		total_prepaid_amt   NUMBER := 0;
		owed_amt            NUMBER := 0;
	BEGIN
		total_payable_amt   := service_bill_pkg.get_adm_total_payable_amt (p_caseno, p_unitcode);
		total_prepaid_amt   := service_bill_pkg.get_adm_total_prepaid_amt (p_caseno, p_unitcode);
		owed_amt            := total_payable_amt - total_prepaid_amt;
		RETURN owed_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN owed_amt;
	END;
	FUNCTION get_emg_owed_amt (
		p_caseno     VARCHAR2,
		p_unitcode   VARCHAR2
	) RETURN NUMBER IS
		total_payable_amt   NUMBER := 0;
		total_prepaid_amt   NUMBER := 0;
		owed_amt            NUMBER := 0;
	BEGIN
		total_payable_amt   := get_emg_total_payable_amt (p_caseno, p_unitcode);
		total_prepaid_amt   := get_emg_total_prepaid_amt (p_caseno, p_unitcode);
		owed_amt            := total_payable_amt - total_prepaid_amt;
		RETURN owed_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN owed_amt;
	END;
	FUNCTION get_adm_total_contract_amt (
		p_caseno VARCHAR2
	) RETURN NUMBER IS
		total_contract_amt NUMBER := 0;
	BEGIN
		SELECT
			nvl (credit_amt, 0)
		INTO total_contract_amt
		FROM
			bil_feemst
		WHERE
			caseno = p_caseno;
		RETURN total_contract_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN total_contract_amt;
	END;
	FUNCTION get_emg_total_contract_amt (
		p_caseno VARCHAR2
	) RETURN NUMBER IS
		total_contract_amt NUMBER := 0;
	BEGIN
		SELECT
			nvl (credit_amt, 0)
		INTO total_contract_amt
		FROM
			emg_bil_feemst
		WHERE
			caseno = p_caseno;
		RETURN total_contract_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN total_contract_amt;
	END;
	FUNCTION get_adm_tot_negot_instru_amt (
		p_caseno VARCHAR2
	) RETURN NUMBER IS
		tot_negot_instru_amt NUMBER := 0;
	BEGIN
		SELECT
			SUM (bill_amt)
		INTO tot_negot_instru_amt
		FROM
			bil_check_bill
		WHERE
			status != 'R'
			AND
			caseno = p_caseno;
		RETURN tot_negot_instru_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN tot_negot_instru_amt;
	END;
	FUNCTION get_emg_tot_negot_instru_amt (
		p_caseno VARCHAR2
	) RETURN NUMBER IS
		tot_negot_instru_amt NUMBER := 0;
	BEGIN
		SELECT
			SUM (bill_amt)
		INTO tot_negot_instru_amt
		FROM
			emg_bil_check_bill
		WHERE
			status != 'R'
			AND
			caseno = p_caseno;
		RETURN tot_negot_instru_amt;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN tot_negot_instru_amt;
	END;
	FUNCTION get_preauthorized_enabled RETURN VARCHAR2 IS
		preauthorized_enabled VARCHAR2 (1) := 'N';
	BEGIN
		SELECT
			granted_pay_yn
		INTO preauthorized_enabled
		FROM
			bil_epay_auth
		WHERE
			sysid = 'adm';
		RETURN preauthorized_enabled;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN preauthorized_enabled;
	END;
	FUNCTION get_atm_card_enabled RETURN VARCHAR2 IS
		atm_card_enabled VARCHAR2 (1) := 'N';
	BEGIN
		SELECT
			grented_atm_yn
		INTO atm_card_enabled
		FROM
			bil_epay_auth
		WHERE
			sysid = 'adm';
		RETURN atm_card_enabled;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN atm_card_enabled;
	END;
	FUNCTION get_last_electr_trans_time (
		p_caseno VARCHAR2
	) RETURN DATE IS
		last_electr_trans_time DATE;
	BEGIN
		SELECT
			MAX (creation_date)
		INTO last_electr_trans_time
		FROM
			bil_epay_log
		WHERE
			caseno = p_caseno
		GROUP BY
			caseno;
		RETURN last_electr_trans_time;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN last_electr_trans_time;
	END;
	FUNCTION get_adm_bill_pay_state (
		p_dischg_bill_no   VARCHAR2,
		p_caseno           VARCHAR2
	) RETURN VARCHAR2 IS
		pay_state VARCHAR2 (1);
	BEGIN
		SELECT
			rec_status
		INTO pay_state
		FROM
			bil_billmst
		WHERE
			dischg_bill_no = p_dischg_bill_no
			AND
			caseno = p_caseno;
		RETURN pay_state;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pay_state;
	END;
	FUNCTION get_contract_bill_pay_state (
		p_adjst_bill_no   VARCHAR2,
		p_caseno          VARCHAR2
	) RETURN VARCHAR2 IS
		pay_state VARCHAR2 (1);
	BEGIN
		SELECT
			rec_status
		INTO pay_state
		FROM
			bil_adjstbil_mst
		WHERE
			adjst_bill_no = p_adjst_bill_no
			AND
			caseno = p_caseno;
		RETURN pay_state;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pay_state;
	END;
	FUNCTION check_is_full_payment (
		p_caseno VARCHAR2
	) RETURN VARCHAR2 IS
		is_full_payment VARCHAR2 (1) := 'N';
	BEGIN
		SELECT
			CASE
				WHEN service_bill_pkg.get_adm_owed_amt (p_caseno, 'CIVC') <= 0 THEN
					'Y'
				ELSE
					'N'
			END
		INTO is_full_payment
		FROM
			dual;
		RETURN is_full_payment;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN is_full_payment;
	END;
	FUNCTION check_is_full_negot_instru (
		p_caseno VARCHAR2
	) RETURN VARCHAR2 IS
		is_full_negot_instru VARCHAR2 (1) := 'N';
	BEGIN
		SELECT
			CASE
				WHEN SUM (bill_amt) >= service_bill_pkg.get_adm_owed_amt (p_caseno, 'CIVC') THEN
					'Y'
				ELSE
					'N'
			END
		INTO is_full_negot_instru
		FROM
			bil_check_bill
		WHERE
			caseno = p_caseno
			AND
			status = 'N';
		RETURN is_full_negot_instru;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN is_full_negot_instru;
	END;
	FUNCTION get_pat_state (
		p_hcaseno VARCHAR2
	) RETURN VARCHAR2 IS
		pat_state VARCHAR2 (1);
	BEGIN
		SELECT
			hpatstat
		INTO pat_state
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = p_hcaseno;
		RETURN pat_state;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pat_state;
	END;
	FUNCTION get_logic_id_by_host_id (
		p_code_no VARCHAR2
	) RETURN VARCHAR2 IS
		logic_id VARCHAR2 (4);
	BEGIN
		logic_id := service_bill_pkg.get_code_desc ('HostLogic', p_code_no);
		RETURN logic_id;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN logic_id;
	END;
	FUNCTION get_logic_id_by_nurses (
		p_hnurstat   VARCHAR2,
		p_hbedno     VARCHAR2
	) RETURN VARCHAR2 IS
		logic_id VARCHAR2 (4);
	BEGIN
		SELECT
			logid
		INTO logic_id
		FROM
			cpoe.cpoe_ns_printset
		WHERE
			hnurstat = p_hnurstat
			AND
			(hbedno = p_hbedno
			 OR
			 hbedno = 'ALL')
		ORDER BY
			logid;
		RETURN logic_id;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN logic_id;
	END;
	FUNCTION get_printer_id (
		p_logid    VARCHAR2,
		p_sys_id   VARCHAR2
	) RETURN VARCHAR2 IS
		printer_id VARCHAR2 (4);
	BEGIN
		IF p_sys_id = 'adm' OR p_sys_id IS NULL THEN
			SELECT
				MAX (prtid)
			INTO printer_id
			FROM
				shared.new_print_base
			WHERE
				applid = 'cpoe'
				AND
				logid = p_logid;
		ELSIF p_sys_id = 'emg' THEN
			SELECT
				MAX (prtid)
			INTO printer_id
			FROM
				shared.new_print_base
			WHERE
				applid = 'emg'
				AND
				logid = p_logid;
		END IF;
		RETURN printer_id;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN printer_id;
	END;
	FUNCTION get_vtan_status (
		p_hhisnum VARCHAR2
	) RETURN VARCHAR2 IS
		vtan_status VARCHAR2 (1);
	BEGIN
		SELECT
			hvtfincl
		INTO vtan_status
		FROM
			common.pat_vtan_basic
		WHERE
			hhisnum = p_hhisnum;
		RETURN vtan_status;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN vtan_status;
	END;
	FUNCTION get_certificate_charge_seq RETURN NUMBER IS
		certif_charge_seq NUMBER;
	BEGIN
		SELECT
			abs_charge_seq.NEXTVAL
		INTO certif_charge_seq
		FROM
			dual;
		RETURN certif_charge_seq;
	END;
	FUNCTION get_last_cert_year_seq_no (
		p_abstype IN VARCHAR2
	) RETURN VARCHAR2 IS
		last_cert_year_seq_no VARCHAR2 (10);
	BEGIN
		SELECT
			TO_CHAR (MAX (to_number (certseq)))
		INTO last_cert_year_seq_no
		FROM
			abs_root
		WHERE
			abstype = p_abstype
			AND
			certseq IS NOT NULL;
		RETURN last_cert_year_seq_no;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN last_cert_year_seq_no;
	END;
	FUNCTION get_fee_adjust_seq_no RETURN VARCHAR2 IS
		fee_adjust_seq_no VARCHAR2 (20);
	BEGIN
		SELECT
			'ADJUST' || lpad (adjst_seqno.NEXTVAL, 14, '0')
		INTO fee_adjust_seq_no
		FROM
			dual;
		RETURN fee_adjust_seq_no;
	END;
	FUNCTION get_adm_pickup_medicine_no (
		p_encounter_id IN VARCHAR2
	) RETURN VARCHAR2 IS
		pickup_medicine_no vghtc.encounter_props.prop_value%TYPE;
	BEGIN
		SELECT
			prop_value
		INTO pickup_medicine_no
		FROM
			vghtc.encounter_props
		WHERE
			vghtc.encounter_props.prop_key = 'ipd.encounter.prop.discharge.draw.number'
			AND
			encounter_id = p_encounter_id;
		RETURN pickup_medicine_no;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pickup_medicine_no;
	END;
	FUNCTION get_emg_pickup_medicine_no (
		p_encounter_id IN VARCHAR2
	) RETURN VARCHAR2 IS
		pickup_medicine_no VARCHAR2 (7);
	BEGIN
		SELECT
			prop_value
		INTO pickup_medicine_no
		FROM
			vghtc.encounter_props
		WHERE
			vghtc.encounter_props.prop_key = 'emg.encounter.prop.discharge.draw.number'
			AND
			encounter_id = p_encounter_id;
		RETURN pickup_medicine_no;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pickup_medicine_no;
	END;
	FUNCTION get_num_of_uncal_charge_item (
		p_caseno IN VARCHAR2
	) RETURN VARCHAR2 IS
		num_of_uncal_charge_item NUMBER := 0;
	BEGIN
		SELECT
			COUNT (*)
		INTO num_of_uncal_charge_item
		FROM
			billtemp1
		WHERE
			trn_flag = 'N'
			AND
			caseno = p_caseno;
		RETURN num_of_uncal_charge_item;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN num_of_uncal_charge_item;
	END;
	FUNCTION get_adm_fee_locked_flag (
		p_caseno VARCHAR2
	) RETURN VARCHAR2 IS
		locked_flag VARCHAR2 (1) := 'N';
	BEGIN
		SELECT
			CASE
				WHEN created_by = 'No_Calculate' THEN
					'Y'
				ELSE
					'N'
			END
		INTO locked_flag
		FROM
			bil_root
		WHERE
			caseno = p_caseno;
		RETURN locked_flag;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN locked_flag;
	END;
	FUNCTION get_emg_fee_locked_flag (
		p_caseno VARCHAR2
	) RETURN VARCHAR2 IS
		locked_flag VARCHAR2 (1) := 'N';
	BEGIN
		SELECT
			CASE
				WHEN created_by = 'No_Calculate' THEN
					'Y'
				ELSE
					'N'
			END
		INTO locked_flag
		FROM
			emg_bil_debt_rec
		WHERE
			caseno = p_caseno;
		RETURN locked_flag;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN locked_flag;
	END;
	FUNCTION check_has_been_bad_debt (
		p_caseno VARCHAR2
	) RETURN VARCHAR2 IS
		has_been_bad_debt_flag VARCHAR2 (1) := 'N';
	BEGIN
		SELECT
			CASE
				WHEN COUNT (*) > 0 THEN
					'Y'
				ELSE
					'N'
			END
		INTO has_been_bad_debt_flag
		FROM
			(
				SELECT
					caseno
				FROM
					bil_debt_rec
				WHERE
					caseno = p_caseno
					AND
					change_flag = 'O'
				UNION
				SELECT
					caseno
				FROM
					bil_debt_rec_log
				WHERE
					caseno = p_caseno
					AND
					change_flag = 'O'
			);
		RETURN has_been_bad_debt_flag;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN has_been_bad_debt_flag;
	END;
	FUNCTION get_num_of_curr_db_sessions RETURN NUMBER IS
		num_of_curr_db_sessions NUMBER := 0;
	BEGIN
		SELECT
			COUNT (*)
		INTO num_of_curr_db_sessions
		FROM
			v$session;
		RETURN num_of_curr_db_sessions;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN num_of_curr_db_sessions;
	END;
	FUNCTION get_icd_name (
		p_icd_key   IN   VARCHAR2,
		p_lang      IN   VARCHAR2
	) RETURN VARCHAR2 IS
		icd_name    VARCHAR2 (250);
		v_cursor    SYS_REFCURSOR;
		v_icd_ver   VARCHAR2 (2);
		v_icd_key   VARCHAR2 (10);
		v_diage     VARCHAR2 (250);
		v_diagc     VARCHAR2 (250);
	BEGIN
		service_bill_pkg.get_icd_info (p_icd_key, v_cursor);
		FETCH v_cursor INTO
			v_icd_ver,
			v_icd_key,
			v_diage,
			v_diagc;
		IF (p_lang = 'EN') THEN
			icd_name := v_diage;
		ELSIF (p_lang = 'CH') THEN
			icd_name := v_diagc;
		END IF;
		RETURN icd_name;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN icd_name;
	END;
	PROCEDURE get_printer (
		p_prtid    IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  logid,
			                  prtid,
			                  prttype
		                  FROM
			                  shared.new_print_base
		                  WHERE
			                  applid IN (
				                  'cpoe',
				                  'emg'
			                  )
			                  AND
			                  TRIM (logid) IS NOT NULL
			                  AND
			                  prtid = p_prtid
		                  ORDER BY
			                  logid;
	END;
	FUNCTION get_sw_flag (
		p_caseno VARCHAR2
	) RETURN VARCHAR2 IS
		sw_flag VARCHAR2 (1) := 'N';
	BEGIN
		SELECT
			CASE
				WHEN COUNT (encntno) > 0 THEN
					'Y'
				ELSE
					'N'
			END
		INTO sw_flag
		FROM
			cpoe.consrepl_diet
		WHERE
			reason_id = '033'
			AND
			sub_id = '0242'
			AND
			encntno = p_caseno
			AND
			update_seq = (
				SELECT
					MAX (update_seq)
				FROM
					cpoe.consrepl_diet
				WHERE
					encntno = p_caseno
			);
		RETURN sw_flag;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN sw_flag;
	END;
	FUNCTION get_last_nhi_apply_end_date (
		p_caseno VARCHAR2
	) RETURN DATE IS
		last_nhi_apply_end_date DATE;
	BEGIN
		SELECT
			MAX (apply_end_date)
		INTO last_nhi_apply_end_date
		FROM
			billing.inh_basic
		WHERE
			rec_status = 'Y'
			AND
			caseno = p_caseno;
		RETURN last_nhi_apply_end_date;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN last_nhi_apply_end_date;
	END;
	PROCEDURE get_nurs_sta_printer_list (
		p_cursor OUT SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  logid,
			                  prtid,
			                  prttype
		                  FROM
			                  shared.new_print_base
		                  WHERE
			                  applid = 'cpoe'
			                  AND
			                  logid IN (
				                  SELECT
					                  logid
				                  FROM
					                  cpoe.cpoe_ns_printset
			                  )
		                  ORDER BY
			                  logid;
	END;
	PROCEDURE get_code_mapping_list (
		p_code_type   IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  code_type,
			                  code_no,
			                  code_desc,
			                  enabled
		                  FROM
			                  bil_codedtl
		                  WHERE
			                  code_type = p_code_type
			                  AND
			                  enabled = 'Y'
		                  ORDER BY
			                  (
				                  CASE
					                  WHEN code_type IN (
						                  'PrintPlace',
						                  'AbsPrint'
					                  ) THEN
						                  code_desc
					                  ELSE
						                  code_no
				                  END
			                  );
	END;
	PROCEDURE get_icd_info (
		p_icd_key   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  '9' AS icd_ver,
			                  icd_key,
			                  diage,
			                  diagc
		                  FROM
			                  billing.inh_icddksds
		                  WHERE
			                  codetype = 'ICD-9-CM'
			                  AND
			                  icd_key = p_icd_key
		                  UNION
		                  SELECT
			                  '10' AS icd_ver,
			                  icd_key,
			                  diage,
			                  diagc
		                  FROM
			                  common.icd10
		                  WHERE
			                  codetype = 'ICD-10-CM'
			                  AND
			                  icd_key = p_icd_key;
	END;
	PROCEDURE get_adm_nurses_station_bed_no (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  hnursta,
			                  hbed
		                  FROM
			                  common.pat_adm_case
		                  WHERE
			                  hcaseno = p_caseno;
	END;
	PROCEDURE get_emg_nurses_station_bed_no (
		p_ecaseno   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  emgns,
			                  emgbedno
		                  FROM
			                  common.pat_emg_casen
		                  WHERE
			                  ecaseno = p_ecaseno;
	END;
	PROCEDURE get_preauthorized_info (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  patid,
			                  patbegdt,
			                  patenddt
		                  FROM
			                  bil_bankservicelist
		                  WHERE
			                  patid = (
				                  SELECT
					                  id_no
				                  FROM
					                  bil_root
				                  WHERE
					                  caseno = p_caseno
			                  )
		                  ORDER BY
			                  noticedt DESC;
	END;
	PROCEDURE get_adm_bed_info (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  hnurstat,
			                  hbedno,
			                  hbeddge
		                  FROM
			                  common.adm_bed
		                  WHERE
			                  hcaseno = p_caseno
			                  AND
			                  hbedstat = 'A';
	END;
	FUNCTION get_bil_billmst_pay_state (
		p_dischg_bill_no   VARCHAR2,
		p_caseno           VARCHAR2,
		p_unitcode         VARCHAR2
	) RETURN VARCHAR2 IS
		pay_state VARCHAR2 (1);
	BEGIN
		SELECT
			rec_status
		INTO pay_state
		FROM
			bil_billmst
		WHERE
			dischg_bill_no = p_dischg_bill_no
			AND
			caseno = p_caseno
			AND
			unitcode = p_unitcode;
		RETURN pay_state;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN pay_state;
	END;
	PROCEDURE charge_adm_bill (
		p_dischg_bill_no    IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_pat_kind          IN    VARCHAR2,
		p_pat_paid_amt      IN    NUMBER,
		p_last_updated_by   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_host_id           IN    VARCHAR2,
		p_unitcode          IN    VARCHAR2,
		p_printer_id        IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		p_num_of_aff_rows   := 0;
		UPDATE bil_billmst
		SET
			rec_status = 'Y',
			pat_kind = p_pat_kind,
			pat_paid_amt = p_pat_paid_amt,
			last_updated_by = p_last_updated_by,
			last_update_date = SYSDATE,
			paid_date = SYSDATE,
			host_id = p_host_id,
			handler = p_handler,
			pat_eng_name = (
				SELECT
					hname
				FROM
					common.pat_basic
				WHERE
					hhisnum = (
						SELECT
							hpatnum
						FROM
							bil_root
						WHERE
							caseno = p_caseno
					)
			),
			printer_id = p_printer_id
		WHERE
			dischg_bill_no = p_dischg_bill_no
			AND
			caseno = p_caseno
			AND
			unitcode = p_unitcode;
		p_num_of_aff_rows   := SQL%rowcount;
	END;
	PROCEDURE charge_emg_bill (
		p_dischg_bill_no    IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_pat_kind          IN    VARCHAR2,
		p_pat_paid_amt      IN    NUMBER,
		p_last_updated_by   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_host_id           IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		p_num_of_aff_rows   := 0;
		UPDATE emg_bil_billmst
		SET
			rec_status = 'Y',
			pat_kind = p_pat_kind,
			pat_paid_amt = p_pat_paid_amt,
			last_updated_by = p_last_updated_by,
			last_update_date = SYSDATE,
			paid_date = SYSDATE,
			host_id = p_host_id,
			handler = p_handler
		WHERE
			dischg_bill_no = p_dischg_bill_no
			AND
			caseno = p_caseno;
		p_num_of_aff_rows   := SQL%rowcount;
		UPDATE emg_bil_billdtl
		SET
			act_status = 'paid',
			last_updated_by = p_last_updated_by,
			last_updateion_date = SYSDATE
		WHERE
			emg_bil_seqno = p_dischg_bill_no
			AND
			caseno = p_caseno;
		p_num_of_aff_rows   := SQL%rowcount;
	END;
	PROCEDURE cancel_adm_bill (
		p_dischg_bill_no    IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_cancel_oper       IN    VARCHAR2,
		p_unitcode          IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		p_num_of_aff_rows   := 0;
		UPDATE bil_billmst
		SET
			rec_status = 'C',
			cancel_date = SYSDATE,
			cancel_oper = p_cancel_oper
		WHERE
			dischg_bill_no = p_dischg_bill_no
			AND
			caseno = p_caseno
			AND
			unitcode = p_unitcode;
		p_num_of_aff_rows   := SQL%rowcount;
	END;
	PROCEDURE update_adm_bill_epay_info (
		p_dischg_bill_no    IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_seqno             IN    VARCHAR2,
		p_act_status        IN    VARCHAR2,
		p_last_updated_by   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_host_id           VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		UPDATE bil_billmst
		SET
			seqno = p_seqno,
			act_status = p_act_status,
			last_updated_by = p_last_updated_by,
			last_update_date = SYSDATE,
			handler = p_handler,
			host_id = p_host_id
		WHERE
			dischg_bill_no = p_dischg_bill_no
			AND
			caseno = p_caseno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE upd_adm_bill_credit_pay_info (
		p_dischg_bill_no            IN    VARCHAR2,
		p_caseno                    IN    VARCHAR2,
		p_credit_card_approval_no   IN    VARCHAR2,
		p_last_updated_by           IN    VARCHAR2,
		p_handler                   IN    VARCHAR2,
		p_host_id                   VARCHAR2,
		p_num_of_aff_rows           OUT   NUMBER
	) IS
	BEGIN
		UPDATE bil_billmst
		SET
			credit_card_approval_no = p_credit_card_approval_no,
			last_updated_by = p_last_updated_by,
			last_update_date = SYSDATE,
			handler = p_handler,
			host_id = p_host_id
		WHERE
			dischg_bill_no = p_dischg_bill_no
			AND
			caseno = p_caseno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE ins_upd_emg_bil_debt_rec (
		p_caseno             IN    VARCHAR2,
		p_change_flag        IN    VARCHAR2,
		p_display_flag       IN    VARCHAR2,
		p_overdue_date       IN    DATE,
		p_baddebt_date       IN    DATE,
		p_baddebt_document   IN    VARCHAR2,
		p_opr_emp_id         VARCHAR2,
		p_num_of_aff_rows    OUT   NUMBER
	) IS
		v_cnt                  NUMBER := 0;
		rec_pat_emg_casen      common.pat_emg_casen%rowtype;
		rec_emg_bil_debt_rec   emg_bil_debt_rec%rowtype;
	BEGIN
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			emg_bil_debt_rec
		WHERE
			caseno = p_caseno;
		IF v_cnt = 0 THEN
			SELECT
				*
			INTO rec_pat_emg_casen
			FROM
				common.pat_emg_casen
			WHERE
				ecaseno = p_caseno;
			INSERT INTO emg_bil_debt_rec (
				caseno,
				hpatnum,
				dischg_date,
				total_self_amt,
				total_paid_amt,
				total_disc_amt,
				debt_amt,
				created_date,
				created_by,
				last_update_date,
				last_updated_by,
				check_no,
				num
			) VALUES (
				rec_pat_emg_casen.ecaseno,
				rec_pat_emg_casen.emghhist,
				rec_pat_emg_casen.emglvdt,
				service_bill_pkg.get_emg_total_payable_amt (p_caseno, 'CIVC'),
				service_bill_pkg.get_emg_total_prepaid_amt (p_caseno, 'CIVC'),
				service_bill_pkg.get_emg_total_contract_amt (p_caseno),
				service_bill_pkg.get_emg_owed_amt (p_caseno, 'CIVC'),
				SYSDATE,
				p_opr_emp_id,
				SYSDATE,
				p_opr_emp_id,
				(
					SELECT
						check_no
					FROM
						emg_bil_check_bill
					WHERE
						caseno = p_caseno
						AND
						status = 'N'
				),
				0
			);
		ELSE
			SELECT
				*
			INTO rec_emg_bil_debt_rec
			FROM
				emg_bil_debt_rec
			WHERE
				caseno = p_caseno;
			INSERT INTO emg_bil_debt_rec_hist (
				caseno,
				ori_flag,
				change_flag,
				creator,
				created_date,
				seq,
				num
			) VALUES (
				rec_emg_bil_debt_rec.caseno,
				rec_emg_bil_debt_rec.change_flag,
				p_change_flag,
				p_opr_emp_id,
				SYSDATE,
				(nvl ((
					SELECT
						MAX (seq)
					FROM
						emg_bil_debt_rec_hist
					WHERE
						caseno = p_caseno
				), 0) + 1),
				rec_emg_bil_debt_rec.num
			);
			UPDATE emg_bil_debt_rec
			SET
				change_flag = p_change_flag,
				display_flag = p_display_flag,
				overdue_date = p_overdue_date,
				baddebt_date = p_baddebt_date,
				baddebt_document = p_baddebt_document,
				last_update_date = SYSDATE,
				last_updated_by = p_opr_emp_id
			WHERE
				caseno = p_caseno;
		END IF;
		p_num_of_aff_rows := SQL%rowcount;
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (sqlcode || ': ' || sqlerrm);
	END;
	PROCEDURE get_priced_item_info (
		p_pf_key   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  pfkey,
			                  orproced,
			                  pfnmc,
			                  pfprice1
		                  FROM
			                  cpoe.dbpfile
		                  WHERE
			                  pfkey = p_pf_key;
	END;
	PROCEDURE get_priced_item_info_list (
		p_pricety1        IN    VARCHAR2,
		p_pfkey_pattern   IN    VARCHAR2,
		p_cursor          OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  pfkey,
			                  orproced,
			                  pfnmc,
			                  pfprice1
		                  FROM
			                  cpoe.dbpfile
		                  WHERE
			                  pricety1 = p_pricety1
			                  AND
			                  pfkey LIKE p_pfkey_pattern
		                  ORDER BY
			                  pfkey;
	END;
	PROCEDURE get_priced_item_daily_revenue (
		p_pf_key           IN    VARCHAR2,
		p_start_bil_date   IN    DATE,
		p_end_bil_date     IN    DATE,
		p_cursor           OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  pf_key,
			                  bil_date,
			                  SUM (charge_amount) AS sum_charge_amount
		                  FROM
			                  bil_occur
		                  WHERE
			                  pf_key = p_pf_key
			                  AND
			                  trunc (bil_date) BETWEEN trunc (p_start_bil_date) AND trunc (p_end_bil_date)
		                  GROUP BY
			                  pf_key,
			                  bil_date
		                  ORDER BY
			                  pf_key,
			                  bil_date;
	END;
	PROCEDURE lock_bil_root_rec (
		p_caseno            IN    VARCHAR2,
		p_last_updated_by   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		p_num_of_aff_rows   := 0;
		UPDATE bil_root
		SET
			created_by = 'No_Calculate',
			last_updated_by = p_last_updated_by,
			last_update_date = SYSDATE
		WHERE
			caseno = p_caseno;
		p_num_of_aff_rows   := SQL%rowcount;
	END;
	PROCEDURE unlock_bil_root_rec (
		p_caseno            IN    VARCHAR2,
		p_last_updated_by   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		p_num_of_aff_rows   := 0;
		UPDATE bil_root
		SET
			created_by = 'Re_Calculate',
			last_updated_by = p_last_updated_by,
			last_update_date = SYSDATE
		WHERE
			caseno = p_caseno;
		p_num_of_aff_rows   := SQL%rowcount;
	END;
	PROCEDURE get_nurses_station_list (
		p_cursor OUT SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  id
		                  FROM
			                  vghtc.db_station_new
		                  WHERE
			                  ipd_use = 'Y'
		                  ORDER BY
			                  id;
	END;
	PROCEDURE get_abs_form_def_mas_list (
		p_cursor OUT SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  abs_type,
			                  abs_desc,
			                  gen_predet_free_quota,
			                  no_job_vtan_predet_free_quota,
			                  no_job_vtan_disc,
			                  emp_predet_free_quota,
			                  emp_disc,
			                  price_code
		                  FROM
			                  abs_form_def_mas
		                  WHERE
			                  enabled = 'Y'
		                  ORDER BY
			                  sort_order;
	END;
	PROCEDURE get_certificate_root_list (
		p_absno    IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  abs_root.absno,
			                  abs_root.abstype,
			                  (
				                  SELECT
					                  abs_desc
				                  FROM
					                  abs_form_def_mas
				                  WHERE
					                  abs_type = abs_root.abstype
			                  ) AS abstype_desc,
			                  abs_root.absseq,
			                  abs_root.abrdocno,
			                  abs_root.abrdocnm,
			                  abs_root.abvdocno,
			                  (
				                  SELECT
					                  cunit1
				                  FROM
					                  common.psbasic_vghtc
				                  WHERE
					                  "醫師章號" = abvdocno
					                  AND
					                  ROWNUM = 1
			                  ) AS v_doc_dept_no,
			                  service_bill_pkg.get_code_desc ('Dept', (
				                  SELECT
					                  cunit1
				                  FROM
					                  common.psbasic_vghtc
				                  WHERE
					                  "醫師章號" = abvdocno
					                  AND
					                  ROWNUM = 1
			                  )) AS v_doc_dept_desc,
			                  abs_root.abvdocnm,
			                  abs_root.create_date,
			                  abs_root.update_date,
			                  abs_root.certpsn,
			                  abs_root.certprdt,
			                  abs_root.certprcp,
			                  abs_root.certpsns,
			                  abs_root.certseq,
			                  nvl (abs_root.charged_free_qty, 0) AS charged_free_qty,
			                  abs_form_def_mas.sort_order,
			                  service_bill_pkg.get_code_desc ('SuptNameCh', (
				                  SELECT
					                  MIN (code_no)
				                  FROM
					                  bil_codedtl
				                  WHERE
					                  code_type = 'SuptNameCh'
					                  AND
					                  code_no >= TO_CHAR (abs_root.create_date, 'YYYYMMDD')
			                  )) AS supt_name_ch,
			                  service_bill_pkg.get_code_desc ('SuptNameEn', (
				                  SELECT
					                  MIN (code_no)
				                  FROM
					                  bil_codedtl
				                  WHERE
					                  code_type = 'SuptNameEn'
					                  AND
					                  code_no >= TO_CHAR (abs_root.create_date, 'YYYYMMDD')
			                  )) AS supt_name_en,
			                  (
				                  SELECT
					                  nvl (col_content, 'A')
				                  FROM
					                  abs_data
				                  WHERE
					                  abstype = abs_root.abstype
					                  AND
					                  absno = abs_root.absno
					                  AND
					                  absseq = abs_root.absseq
					                  AND
					                  col_id = 'COAE'
			                  ) AS case_type,
			                  service_bill_pkg.get_code_desc ('CaseType', (
				                  SELECT
					                  nvl (col_content, 'A')
				                  FROM
					                  abs_data
				                  WHERE
					                  abstype = abs_root.abstype
					                  AND
					                  absno = abs_root.absno
					                  AND
					                  absseq = abs_root.absseq
					                  AND
					                  col_id = 'COAE'
			                  )) AS case_type_desc
		                  FROM
			                  abs_root left
			                  JOIN abs_form_def_mas ON abs_root.abstype = abs_form_def_mas.abs_type
		                  WHERE
			                  abs_root.absno = p_absno
			                  AND
			                  abs_form_def_mas.enabled = 'Y';
	END;
	PROCEDURE get_certificate_data (
		p_abstype   IN    VARCHAR2,
		p_absno     IN    VARCHAR2,
		p_absseq    IN    NUMBER,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  abs_col_def.col_id,
			                  abs_col_def.col_name,
			                  abs_data.col_content
		                  FROM
			                  abs_col_def left
			                  JOIN abs_data ON abs_col_def.col_id = abs_data.col_id
		                  WHERE
			                  abs_data.abstype = p_abstype
			                  AND
			                  absno = p_absno
			                  AND
			                  absseq = p_absseq
		                  ORDER BY
			                  col_id;
	END;
	PROCEDURE get_abs_data_lob (
		p_abstype   IN    VARCHAR2,
		p_absno     IN    VARCHAR2,
		p_absseq    IN    NUMBER,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  abs_col_def.col_id,
			                  abs_col_def.col_name,
			                  abs_data_lob.col_content
		                  FROM
			                  abs_col_def left
			                  JOIN abs_data_lob ON abs_col_def.col_id = abs_data_lob.col_id
		                  WHERE
			                  abs_data_lob.abstype = p_abstype
			                  AND
			                  absno = p_absno
			                  AND
			                  absseq = p_absseq
		                  ORDER BY
			                  col_id;
	END;
	PROCEDURE update_certificate_data (
		p_abstype           IN    VARCHAR2,
		p_absno             IN    VARCHAR2,
		p_absseq            IN    NUMBER,
		p_col_id            IN    VARCHAR2,
		p_col_content       IN    VARCHAR2,
		p_updater           IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		UPDATE abs_root
		SET
			updater = p_updater,
			update_date = SYSDATE
		WHERE
			abstype = p_abstype
			AND
			absno = p_absno
			AND
			absseq = p_absseq;
		UPDATE abs_data
		SET
			col_content = p_col_content,
			updater = p_updater,
			update_date = SYSDATE
		WHERE
			abstype = p_abstype
			AND
			absno = p_absno
			AND
			absseq = p_absseq
			AND
			col_id = p_col_id;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE upd_abs_root (
		p_abstype            IN    VARCHAR2, -- 證明種類
		p_absno              IN    VARCHAR2, -- 證明編號
		p_absseq             IN    NUMBER,   -- 證明序號
		p_certpsn            IN    VARCHAR2, -- 換領承辦人
		p_certprcp           IN    NUMBER,   -- 換領份數
		p_certpsns           IN    VARCHAR2, -- 領取人
		p_current_free_qty   IN    NUMBER,   -- 本次優待份數
		p_certseq            IN    VARCHAR,  -- 證字號(年份4碼 + 流水號5碼)
		p_num_of_aff_rows    OUT   NUMBER
	) IS
	BEGIN
		UPDATE abs_root
		SET
			certpsn = p_certpsn,
			certprdt = SYSDATE,
			certprcp = p_certprcp,
			certpsns = p_certpsns,
			charged_free_qty = nvl (charged_free_qty, 0) + p_current_free_qty,
			certseq = p_certseq
		WHERE
			abstype = p_abstype
			AND
			absno = p_absno
			AND
			absseq = p_absseq;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE charge_adm_certificate (
		p_seqno             IN    NUMBER,   -- 入帳序號
		p_hhisnum           IN    VARCHAR2, -- 病歷號
		p_caseno            IN    VARCHAR2, -- 住序院號
		p_abstype           IN    VARCHAR2, -- 證明種類
		p_amount            IN    NUMBER,   -- 數量
		p_price             IN    NUMBER,   -- 單價
		p_total             IN    NUMBER,   -- 總價
		p_chargeuser        IN    VARCHAR2, -- 入帳者卡號
		p_chargeusername    IN    VARCHAR2, -- 入帳者姓名
		p_in_billtemp       IN    VARCHAR2, -- 入住院帳單證書費 flag (Y: 入, N: 不入)
		p_absseq            IN    NUMBER,   -- 證明序號
		p_pat_kind          IN    VARCHAR2, -- 換領地點
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
	-- 換領記錄寫入 abs_charge
		INSERT INTO abs_charge (
			seqno,
			hhisnum,
			caseno,
			abstype,
			amount,
			price,
			total,
			chargedate,
			chargeuser,
			chargeusername,
			in_billtemp,
			absseq,
			pat_kind
		) VALUES (
			p_seqno,
			p_hhisnum,
			p_caseno,
			p_abstype,
			p_amount,
			p_price,
			p_total,
			SYSDATE,
			p_chargeuser,
			p_chargeusername,
			p_in_billtemp,
			p_absseq,
			p_pat_kind
		);
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE charge_emg_certificate (
		p_absno             IN    VARCHAR2,-- 證明書CASENO
		p_abstype           IN    VARCHAR2,-- 證明書類別
		p_absseq            IN    NUMBER,  -- 證明書編號
		p_create_time       IN    DATE,    -- 收費日期
		p_creator_cardid    IN    VARCHAR2,-- 收費員卡號
		p_creator_name      IN    VARCHAR2,-- 收費員姓名
		p_amount            IN    NUMBER,  -- 數量
		p_price             IN    NUMBER,  -- 單價
		p_is_charge         IN    VARCHAR2,-- 是否已收費 flag (Y: 是,N: 否)
		p_emgspeu1          IN    VARCHAR2,
		p_emgspeu2          IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		MERGE INTO abs_emg_charge
		USING dual ON (absno = p_absno
		               AND
		               abstype = p_abstype
		               AND
		               absseq = p_absseq
		               AND
		               create_time = p_create_time)
		WHEN NOT MATCHED THEN
	-- 換領記錄寫入 abs_emg_charge
		INSERT (
			absno,
			abstype,
			absseq,
			create_time,
			creator_cardid,
			creator_name,
			amount,
			price,
			is_charge,
			emgspeu1,
			emgspeu2)
		VALUES
			(p_absno,
			 p_abstype,
			 p_absseq,
			 SYSDATE,
			 p_creator_cardid,
			 p_creator_name,
			 p_amount,
			 p_price,
			 p_is_charge,
			 p_emgspeu1,
			 p_emgspeu2)
		-- 換領記錄更新 abs_emg_charge
		WHEN MATCHED THEN UPDATE
		SET is_charge = p_is_charge,
		    creator_cardid = p_creator_cardid,
		    creator_name = p_creator_name;
		p_num_of_aff_rows := SQL%rowcount;
		UPDATE abs_emg_charge
		SET
			create_time = SYSDATE
		WHERE
			absno = p_absno
			AND
			abstype = p_abstype
			AND
			absseq = p_absseq
			AND
			create_time = p_create_time;
	END;
	PROCEDURE get_charged_item_rec_list (
		p_caseno     IN    VARCHAR2,
		p_fee_kind   IN    VARCHAR2,
		p_pfincode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  caseno,
			                  acnt_seq,
			                  seq_no,
			                  price_code,
			                  biling_common_pkg.f_get_pfkey_name (price_code, start_date) AS item_name_en,
			                  biling_common_pkg.f_get_pfkey_cname (price_code, start_date) AS item_name_ch,
			                  fee_kind,
			                  cost_code,
			                  keyin_date,
			                  (
				                  SELECT
					                  discharged
				                  FROM
					                  bil_occur
				                  WHERE
					                  caseno = bil_acnt_wk.caseno
					                  AND
					                  acnt_seq = bil_acnt_wk.seq_no
			                  ) AS keyin_after_discharge,
			                  (
				                  SELECT
					                  last_update_date
				                  FROM
					                  bil_occur
				                  WHERE
					                  caseno = bil_acnt_wk.caseno
					                  AND
					                  acnt_seq = bil_acnt_wk.seq_no
			                  ) AS last_update_date,
			                  unit_desc,
			                  qty,
			                  cir_code,
			                  path_code,
			                  days,
			                  tqty,
			                  insu_tqty,
			                  stock_code,
			                  emg_flag,
			                  emg_per,
			                  insu_amt,
			                  self_amt,
			                  part_amt,
			                  self_flag,
			                  order_doc,
			                  execute_doc,
			                  order_seq,
			                  clerk,
			                  service_bill_pkg.get_emp_name_ch (clerk) AS clerk_emp_name_ch,
			                  service_bill_pkg.get_emp_dept_no (clerk) AS clerk_emp_dept_no,
			                  service_bill_pkg.get_code_desc ('Dept', service_bill_pkg.get_emp_dept_no (clerk)) AS clerk_emp_dept_name,
			                  bed_no,
			                  dept_code,
			                  start_date,
			                  end_date,
			                  start_time,
			                  end_time,
			                  out_med_flag,
			                  diff_flag,
			                  remark,
			                  del_flag,
			                  upd_oper,
			                  upd_date,
			                  upd_time,
			                  med_consume,
			                  ins_fee_code,
			                  nh_type,
			                  e_level,
			                  discharged,
			                  ward,
			                  pfincode,
			                  old_acnt_seq,
			                  bildate,
			                  ordseq
		                  FROM
			                  bil_acnt_wk
		                  WHERE
			                  caseno = p_caseno
			                  AND
			                  ((p_fee_kind IS NULL)
			                   OR
			                   (p_fee_kind IS NOT NULL
			                    AND
			                    fee_kind = p_fee_kind))
			                  AND
			                  ((p_pfincode IS NULL)
			                   OR
			                   (p_pfincode IS NOT NULL
			                    AND
			                    pfincode = p_pfincode))
		                  ORDER BY
			                  last_update_date,
			                  fee_kind,
			                  start_date,
			                  seq_no;
	END;
	PROCEDURE get_fee_fee_type_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT DISTINCT
			                  fee_type,
			                  service_bill_pkg.get_code_desc ('PFTYPE', fee_type) AS fee_type_desc
		                  FROM
			                  bil_feedtl
		                  WHERE
			                  caseno = p_caseno
		                  ORDER BY
			                  fee_type;
	END;
	PROCEDURE get_adm_bill_fee_type_list (
		p_bil_seqno   IN    VARCHAR2,
		p_caseno      IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT DISTINCT
			                  fee_type,
			                  service_bill_pkg.get_code_desc ('PFTYPE', fee_type) AS fee_type_desc
		                  FROM
			                  bil_billdtl
		                  WHERE
			                  bil_seqno = p_bil_seqno
			                  AND
			                  caseno = p_caseno
		                  ORDER BY
			                  fee_type;
	END;
	PROCEDURE get_fee_financ_type_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT DISTINCT
			                  pfincode,
			                  pfincode_desc
		                  FROM
			                  (
				                  SELECT
					                  pfincode,
					                  (
						                  SELECT
							                  bilnamec
						                  FROM
							                  bil_discmst
						                  WHERE
							                  bilkey = pfincode
							                  AND
							                  ROWNUM = 1
					                  ) AS pfincode_desc
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  pfincode NOT IN (
						                  'LABI',
						                  'CIVC'
					                  )
					                  AND
					                  caseno = p_caseno
				                  UNION
				                  SELECT
					                  'LABI' AS pfincode,
					                  '健保' AS pfincode_desc
				                  FROM
					                  dual
				                  UNION
				                  SELECT
					                  'CIVC' AS pfincode,
					                  '自費' AS pfincode_desc
				                  FROM
					                  dual
			                  )
		                  ORDER BY
			                  CASE
				                  WHEN pfincode = 'LABI' THEN
					                  1
				                  WHEN pfincode = 'CIVC' THEN
					                  2
				                  ELSE
					                  3
			                  END,
			                  pfincode;
	END;
	PROCEDURE get_adm_bill_financ_type_list (
		p_bil_seqno   IN    VARCHAR2,
		p_caseno      IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT DISTINCT
			                  unitcode,
			                  unitcode_desc
		                  FROM
			                  (
				                  SELECT
					                  unitcode,
					                  (
						                  SELECT
							                  bilnamec
						                  FROM
							                  bil_discmst
						                  WHERE
							                  bilkey = unitcode
							                  AND
							                  ROWNUM = 1
					                  ) AS unitcode_desc
				                  FROM
					                  bil_billdtl
				                  WHERE
					                  unitcode NOT IN (
						                  'LABI',
						                  'CIVC'
					                  )
					                  AND
					                  bil_seqno = p_bil_seqno
					                  AND
					                  caseno = p_caseno
				                  UNION
				                  SELECT
					                  'LABI' AS unitcode,
					                  '健保' AS unitcode_desc
				                  FROM
					                  dual
				                  UNION
				                  SELECT
					                  'CIVC' AS unitcode,
					                  '自費' AS unitcode_desc
				                  FROM
					                  dual
			                  )
		                  ORDER BY
			                  CASE unitcode
				                  WHEN 'LABI'   THEN
					                  1
				                  WHEN 'CIVC'   THEN
					                  2
				                  ELSE
					                  3
			                  END,
			                  unitcode;
	END;
	PROCEDURE get_fee_financ_amt_list (
		p_caseno     IN    VARCHAR2,
		p_fee_type   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  pfincode,
			                  SUM (total_amt) AS sum_total_amt
		                  FROM
			                  bil_feedtl
		                  WHERE
			                  caseno = p_caseno
			                  AND
			                  fee_type = p_fee_type
		                  GROUP BY
			                  pfincode
		                  ORDER BY
			                  pfincode;
	END;
	PROCEDURE get_adm_bill_financ_amt_list (
		p_bil_seqno   IN    VARCHAR2,
		p_caseno      IN    VARCHAR2,
		p_fee_type    IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  unitcode,
			                  SUM (total_amt) AS sum_total_amt
		                  FROM
			                  bil_billdtl
		                  WHERE
			                  bil_seqno = p_bil_seqno
			                  AND
			                  caseno = p_caseno
			                  AND
			                  fee_type = p_fee_type
		                  GROUP BY
			                  unitcode
		                  ORDER BY
			                  unitcode;
	END;
	PROCEDURE log_epay_rec (
		p_caseno              IN    VARCHAR2,
		p_seqno               IN    VARCHAR2,
		p_dischg_bill_no      IN    VARCHAR2,
		p_del_status          IN    VARCHAR2,
		p_created_by          IN    VARCHAR2,
		p_create_user_namec   IN    VARCHAR2,
		p_host_id             IN    VARCHAR2,
		p_pat_kind            IN    VARCHAR2,
		p_sysid               IN    VARCHAR2,
		p_pos_adm             IN    NUMBER,
		p_pos_emg             IN    NUMBER,
		p_pos_opd             IN    NUMBER,
		p_num_of_aff_rows     OUT   NUMBER
	) IS
	BEGIN
		INSERT INTO bil_epay_log (
			hpatnum,
			caseno,
			seqno,
			dischg_bill_no,
			del_status,
			created_by,
			creation_date,
			create_user_namec,
			host_id,
			pat_kind,
			sysid,
			pos_adm,
			pos_emg,
			pos_opd
		) VALUES (
			(
				SELECT
					hpatnum
				FROM
					bil_root
				WHERE
					caseno = p_caseno
			),
			p_caseno,
			p_seqno,
			p_dischg_bill_no,
			p_del_status,
			p_created_by,
			SYSDATE,
			p_create_user_namec,
			p_host_id,
			p_pat_kind,
			p_sysid,
			p_pos_adm,
			p_pos_emg,
			p_pos_opd
		);
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE get_bil_contr_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  hpatnum,
			                  caseno,
			                  bilcunit,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = bilcunit
					                  AND
					                  bilkind = 'B'
			                  ) AS bilnamec,
			                  bilcbgdt,
			                  bilcendt,
			                  created_by,
			                  creation_date,
			                  last_updated_by,
			                  last_update_date,
			                  stop_by,
			                  stop_date,
			                  stop_flag,
			                  card_seq
		                  FROM
			                  bil_contr
		                  WHERE
			                  caseno = p_caseno;
	END;
	PROCEDURE ins_upd_bil_contr (
		p_hpatnum           IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_bilcunit          IN    VARCHAR2,
		p_bilcbgdt          IN    DATE,
		p_bilcendt          IN    DATE,
		p_operator_emp_id   IN    VARCHAR2,
		p_stop_flag         IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		MERGE INTO bil_contr
		USING dual ON (hpatnum = p_hpatnum
		               AND
		               caseno = p_caseno
		               AND
		               bilcunit = p_bilcunit
		               AND
		               bilcbgdt = p_bilcbgdt)
		WHEN NOT MATCHED THEN
		INSERT (
			hpatnum,
			caseno,
			bilcunit,
			bilcbgdt,
			bilcendt,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			stop_by,
			stop_date,
			stop_flag)
		VALUES
			(p_hpatnum,
			 p_caseno,
			 p_bilcunit,
			 p_bilcbgdt,
			 p_bilcendt,
			 p_operator_emp_id,
			 SYSDATE,
			 p_operator_emp_id,
			 SYSDATE,
			NULL,
			NULL,
			 p_stop_flag)
		WHEN MATCHED THEN UPDATE
		SET bilcendt = p_bilcendt,
		    last_updated_by = p_operator_emp_id,
		    last_update_date = SYSDATE,
		    stop_by =
			CASE
				WHEN p_stop_flag = 'Y' THEN
					p_operator_emp_id
				ELSE
					NULL
			END,
		    stop_date =
			CASE
				WHEN p_stop_flag = 'Y' THEN
					SYSDATE
				ELSE
					NULL
			END,
		    stop_flag = p_stop_flag;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_bil_contr (
		p_hpatnum           IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_bilcunit          IN    VARCHAR2,
		p_bilcbgdt          IN    DATE,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		DELETE FROM bil_contr
		WHERE
			hpatnum = p_hpatnum
			AND
			caseno = p_caseno
			AND
			bilcunit = p_bilcunit
			AND
			bilcbgdt = p_bilcbgdt;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE reset_bil_date_daily_flag (
		p_caseno            IN    VARCHAR2,
		p_start_bil_date    IN    DATE,
		p_end_bil_date      IN    DATE,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		p_num_of_aff_rows   := 0;
		UPDATE bil_date
		SET
			daily_flag = 'N'
		WHERE
			caseno = p_caseno
			AND
			bil_date BETWEEN p_start_bil_date AND p_end_bil_date;
		p_num_of_aff_rows   := SQL%rowcount;
	END;
--get_fee_adjust_mst_rec_list
	PROCEDURE get_bil_adjst_mst_list (
		p_adjst_seqno   IN    VARCHAR2,
		p_caseno        IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  adjst_seqno,
			                  blfrunit,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = blfrunit
					                  AND
					                  bilkind = 'B'
			                  ) AS blfrunit_desc,
			                  bltounit,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = bltounit
					                  AND
					                  bilkind = 'B'
			                  ) AS bltounit_desc,
			                  adjst_reason,
			                  before_amt,
			                  after_fr_amt,
			                  after_to_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  creation_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_update_date
		                  FROM
			                  bil_adjst_mst
		                  WHERE
			                  (p_adjst_seqno IS NOT NULL
			                   AND
			                   adjst_seqno = p_adjst_seqno)
			                  OR
			                  (p_adjst_seqno IS NULL
			                   AND
			                   caseno = p_caseno)
		                  ORDER BY
			                  last_update_date;
	END;
	PROCEDURE get_emg_bil_adjst_mst_list (
		p_adjst_seqno   IN    VARCHAR2,
		p_caseno        IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  adjst_seqno,
			                  blfrunit,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = blfrunit
					                  AND
					                  bilkind = 'B'
			                  ) AS blfrunit_desc,
			                  bltounit,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = bltounit
					                  AND
					                  bilkind = 'B'
			                  ) AS bltounit_desc,
			                  adjst_reason,
			                  service_bill_pkg.get_code_desc ('AdjsReason', adjst_reason) AS adjst_reason_desc,
			                  before_amt,
			                  after_fr_amt,
			                  after_to_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  created_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_update_date
		                  FROM
			                  emg_bil_adjst_mst
		                  WHERE
			                  (p_adjst_seqno IS NOT NULL
			                   AND
			                   adjst_seqno = p_adjst_seqno)
			                  OR
			                  (p_adjst_seqno IS NULL
			                   AND
			                   caseno = p_caseno)
		                  ORDER BY
			                  last_update_date;
	END;
--ins_upd_fee_adjust_mst_rec
	PROCEDURE ins_upd_bil_adjst_mst (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_bil_no            IN    VARCHAR2,
		p_blfrunit          IN    VARCHAR2,
		p_bltounit          IN    VARCHAR2,
		p_bladjtx           IN    VARCHAR2,
		p_adjst_reason      IN    VARCHAR2,
		p_before_amt        IN    NUMBER,
		p_after_fr_amt      IN    NUMBER,
		p_after_to_amt      IN    NUMBER,
		p_operator_emp_id   IN    VARCHAR2,
		p_donee_hpatnum     IN    VARCHAR2,
		p_donee_caseno      IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		MERGE INTO bil_adjst_mst
		USING dual ON (adjst_seqno = p_adjst_seqno)
		WHEN NOT MATCHED THEN
		INSERT (
			adjst_seqno,
			caseno,
			hpatnum,
			bil_no,
			blfrunit,
			bltounit,
			bladjtx,
			adjst_reason,
			before_amt,
			after_fr_amt,
			after_to_amt,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			donee_hpatnum,
			donee_caseno,
			cost1,
			cost2)
		VALUES
			(p_adjst_seqno,
			 p_caseno,
			(
				SELECT
					hpatnum
				FROM
					bil_root
				WHERE
					caseno = p_caseno
			),
			 p_bil_no,
			 p_blfrunit,
			 p_bltounit,
			 p_bladjtx,
			 p_adjst_reason,
			 p_before_amt,
			 p_after_fr_amt,
			 p_after_to_amt,
			 p_operator_emp_id,
			 SYSDATE,
			 p_operator_emp_id,
			 SYSDATE,
			 p_donee_hpatnum,
			 p_donee_caseno,
			(
				SELECT
					hcursvcl
				FROM
					bil_root
				WHERE
					caseno = p_caseno
			),
			(
				SELECT
					hcursvcl
				FROM
					bil_root
				WHERE
					caseno = p_caseno
			))
		WHEN MATCHED THEN UPDATE
		SET blfrunit = blfrunit,
		    bltounit = p_bltounit,
		    bladjtx = p_bladjtx,
		    adjst_reason = p_adjst_reason,
		    before_amt = p_before_amt,
		    after_fr_amt = p_after_fr_amt,
		    after_to_amt = p_after_to_amt,
		    last_updated_by = p_operator_emp_id,
		    last_update_date = SYSDATE,
		    donee_hpatnum = p_donee_hpatnum,
		    donee_caseno = p_donee_caseno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE ins_upd_emg_bil_adjst_mst (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_emg_bil_no        IN    VARCHAR2,
		p_blfrunit          IN    VARCHAR2,
		p_bltounit          IN    VARCHAR2,
		p_bladjtx           IN    VARCHAR2,
		p_adjst_reason      IN    VARCHAR2,
		p_before_amt        IN    NUMBER,
		p_after_fr_amt      IN    NUMBER,
		p_after_to_amt      IN    NUMBER,
		p_operator_emp_id   IN    VARCHAR2,
		p_donee_hpatnum     IN    VARCHAR2,
		p_donee_caseno      IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		MERGE INTO emg_bil_adjst_mst
		USING dual ON (adjst_seqno = p_adjst_seqno)
		WHEN NOT MATCHED THEN
		INSERT (
			adjst_seqno,
			caseno,
			hpatnum,
			emg_bil_no,
			blfrunit,
			bltounit,
			bladjtx,
			adjst_reason,
			before_amt,
			after_fr_amt,
			after_to_amt,
			created_by,
			created_date,
			last_updated_by,
			last_update_date,
			donee_hpatnum,
			donee_caseno,
			cost1,
			cost2)
		VALUES
			(p_adjst_seqno,
			 p_caseno,
			(
				SELECT
					hpatnum
				FROM
					bil_root
				WHERE
					caseno = p_caseno
			),
			 p_emg_bil_no,
			 p_blfrunit,
			 p_bltounit,
			 p_bladjtx,
			 p_adjst_reason,
			 p_before_amt,
			 p_after_fr_amt,
			 p_after_to_amt,
			 p_operator_emp_id,
			 SYSDATE,
			 p_operator_emp_id,
			 SYSDATE,
			 p_donee_hpatnum,
			 p_donee_caseno,
			(
				SELECT
					hcursvcl
				FROM
					bil_root
				WHERE
					caseno = p_caseno
			),
			(
				SELECT
					hcursvcl
				FROM
					bil_root
				WHERE
					caseno = p_caseno
			))
		WHEN MATCHED THEN UPDATE
		SET blfrunit = blfrunit,
		    bltounit = p_bltounit,
		    bladjtx = p_bladjtx,
		    adjst_reason = p_adjst_reason,
		    before_amt = p_before_amt,
		    after_fr_amt = p_after_fr_amt,
		    after_to_amt = p_after_to_amt,
		    last_updated_by = p_operator_emp_id,
		    last_update_date = SYSDATE,
		    donee_hpatnum = p_donee_hpatnum,
		    donee_caseno = p_donee_caseno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_bil_adjst_mst (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		DELETE FROM bil_adjst_mst
		WHERE
			adjst_seqno = p_adjst_seqno
			AND
			caseno = p_caseno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_emg_bil_adjst_mst (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		DELETE FROM emg_bil_adjst_mst
		WHERE
			adjst_seqno = p_adjst_seqno
			AND
			caseno = p_caseno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE get_bil_adjst_dtl_list (
		p_adjst_seqno   IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  adjst_seqno,
			                  fee_kind,
			                  service_bill_pkg.get_code_desc ('PFTYPE', fee_kind) AS fee_kind_desc,
			                  before_amt,
			                  after_fr_amt,
			                  after_to_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  creation_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_update_date
		                  FROM
			                  bil_adjst_dtl
		                  WHERE
			                  adjst_seqno = p_adjst_seqno;
	END;
	PROCEDURE get_emg_bil_adjst_dtl_list (
		p_adjst_seqno   IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  adjst_seqno,
			                  fee_kind,
			                  service_bill_pkg.get_code_desc ('PFTYPE', fee_kind) AS fee_kind_desc,
			                  before_amt,
			                  after_fr_amt,
			                  after_to_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  created_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_update_date
		                  FROM
			                  emg_bil_adjst_dtl
		                  WHERE
			                  adjst_seqno = p_adjst_seqno;
	END;
--ins_fee_adjust_dtl_rec
	PROCEDURE ins_bil_adjst_dtl (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_fee_kind          IN    VARCHAR2,
		p_before_amt        IN    NUMBER,
		p_after_fr_amt      IN    NUMBER,
		p_after_to_amt      IN    NUMBER,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		INSERT INTO bil_adjst_dtl (
			adjst_seqno,
			caseno,
			fee_kind,
			before_amt,
			after_fr_amt,
			after_to_amt,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date
		) VALUES (
			p_adjst_seqno,
			p_caseno,
			p_fee_kind,
			p_before_amt,
			p_after_fr_amt,
			p_after_to_amt,
			p_operator_emp_id,
			SYSDATE,
			p_operator_emp_id,
			SYSDATE
		);
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE ins_emg_bil_adjst_dtl (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_fee_kind          IN    VARCHAR2,
		p_before_amt        IN    NUMBER,
		p_after_fr_amt      IN    NUMBER,
		p_after_to_amt      IN    NUMBER,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		INSERT INTO emg_bil_adjst_dtl (
			adjst_seqno,
			caseno,
			fee_kind,
			before_amt,
			after_fr_amt,
			after_to_amt,
			created_by,
			created_date,
			last_updated_by,
			last_update_date
		) VALUES (
			p_adjst_seqno,
			p_caseno,
			p_fee_kind,
			p_before_amt,
			p_after_fr_amt,
			p_after_to_amt,
			p_operator_emp_id,
			SYSDATE,
			p_operator_emp_id,
			SYSDATE
		);
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_bil_adjst_dtl (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		DELETE FROM bil_adjst_dtl
		WHERE
			adjst_seqno = p_adjst_seqno
			AND
			caseno = p_caseno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_emg_bil_adjst_dtl (
		p_adjst_seqno       IN    VARCHAR2,
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		DELETE FROM emg_bil_adjst_dtl
		WHERE
			adjst_seqno = p_adjst_seqno
			AND
			caseno = p_caseno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE get_bil_epay_log_rec (
		p_dischg_bill_no   IN    VARCHAR2,
		p_caseno           IN    VARCHAR2,
		p_seqno            IN    VARCHAR2,
		p_cursor           OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  hpatnum,
			                  caseno,
			                  seqno,
			                  dischg_bill_no,
			                  send_logout_msg,
			                  service_bill_pkg.get_code_desc ('AtmResCode', send_logout_msg) AS send_logout_msg_desc,
			                  msg1,
			                  service_bill_pkg.get_code_desc ('AtmResCode', msg1) AS msg1_desc,
			                  msg1_rtn,
			                  msg1_rtn_msg,
			                  msg2,
			                  msg2_rtn,
			                  msg2_rtn_msg,
			                  del_status,
			                  created_by,
			                  creation_date,
			                  pat_kind,
			                  msg1_date,
			                  msg1_rtn_date,
			                  msg2_date,
			                  msg2_rtn_date,
			                  send_logout_msg_date,
			                  sysid,
			                  del_txnseq,
			                  clientno,
			                  rtn_url,
			                  errornoticeyn,
			                  errornoticedatetime,
			                  create_user_namec,
			                  host_id,
			                  pos_adm,
			                  pos_adm_flag,
			                  pos_adm_printed,
			                  is_adm_eng_receipt,
			                  pos_ambu,
			                  pos_ambu_flag,
			                  pos_ambu_printed,
			                  pos_emg,
			                  pos_emg_flag,
			                  pos_emg_printed,
			                  is_emg_eng_receipt,
			                  emg_case_no,
			                  emg_billno,
			                  pos_opd,
			                  pos_opd_flag,
			                  pos_opd_printed,
			                  is_opd_eng_receipt,
			                  patient_name_eng,
			                  pos_finished_flag
		                  FROM
			                  bil_epay_log
		                  WHERE
			                  dischg_bill_no = p_dischg_bill_no
			                  AND
			                  caseno = p_caseno
			                  AND
			                  seqno = p_seqno;
	END;
	PROCEDURE update_ambulance_record (
		p_id                IN    VARCHAR2,
		p_charge_opid       IN    VARCHAR2,
		p_charge_opname     IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		UPDATE cpoe.ambulance_record
		SET
			charge_yn =
				CASE
					WHEN (
						SELECT
							SUM (charge_amt)
						FROM
							ambulance_charge
						WHERE
							id = p_id
					) >= total THEN
						'Y'
					ELSE
						'N'
				END,
			charge_dtm = SYSDATE,
			charge_opid = p_charge_opid,
			charge_opname = p_charge_opname
		WHERE
			id = p_id;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE charge_ambulance (
		p_id                IN    VARCHAR2, -- 救護車計價序號
		p_charge_type       IN    VARCHAR2, -- 繳費方式 (1: 現金, 3: 金融卡)
		p_charge_kind       IN    VARCHAR2, -- 入/退帳 (1: 入帳, 2: 退帳)
		p_operater_id       IN    VARCHAR2, -- 入帳者卡號
		p_operater_name     IN    VARCHAR2, -- 入帳者姓名
		p_charge_amt        IN    NUMBER,   -- 入帳金額 (含正負)
		p_host_ip           IN    VARCHAR2, -- 入帳 IP
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		INSERT INTO ambulance_charge (
			id,
			caseno,
			charge_type,
			charge_kind,
			operater_id,
			operater_name,
			operater_date,
			charge_amt,
			host_ip,
			pt_name,
			chart_no,
			fee_kind
		) VALUES (
			p_id,
			(
				SELECT
					caseno
				FROM
					cpoe.ambulance_record
				WHERE
					id = p_id
			),
			p_charge_type,
			p_charge_kind,
			p_operater_id,
			p_operater_name,
			SYSDATE,
			p_charge_amt,
			p_host_ip,
			service_bill_pkg.get_pat_name_ch ((
				SELECT
					hhisnum
				FROM
					cpoe.ambulance_record
				WHERE
					id = p_id
			)),
			(
				SELECT
					hhisnum
				FROM
					cpoe.ambulance_record
				WHERE
					id = p_id
			),
			service_bill_pkg.get_code_desc ('AmbuAcctKind', (
				SELECT
					type
				FROM
					cpoe.ambulance_record
				WHERE
					id = p_id
			))
		);
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE ins_ucccmst_rec (
		p_uccclog_seqno        IN    VARCHAR2, -- log 序號
		p_transamount          IN    NUMBER,   -- 交易金額
		p_transdate            IN    VARCHAR2, -- 交易日期
		p_transtime            IN    VARCHAR2, -- 交易時間
		p_storeid              IN    VARCHAR2, -- 櫃號
		p_createid             IN    VARCHAR2, -- 建立者身分證字號
		p_createnmc            IN    VARCHAR2, -- 建立者姓名
		p_createcard           IN    VARCHAR2, -- 建立者卡號
		p_rollbackapprovalno   IN    VARCHAR2, -- 沖正授權碼
		p_manual_yn            IN    VARCHAR2, -- 是否手動輸入
		p_num_of_aff_rows      OUT   NUMBER
	) IS
	BEGIN
		INSERT INTO common.ucccmst (
			uccclog_seqno,
			transamount,
			transdate,
			transtime,
			storeid,
			createdatetime,
			createid,
			createnmc,
			createcard,
			rollbackapprovalno,
			manual_yn
		) VALUES (
			p_uccclog_seqno,
			p_transamount,
			p_transdate,
			p_transtime,
			p_storeid,
			TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
			p_createid,
			p_createnmc,
			p_createcard,
			p_rollbackapprovalno,
			p_manual_yn
		);
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE upd_ucccmst_rec (
		p_uccclog_seqno     IN    VARCHAR2, -- log 序號
		p_receiptno         IN    VARCHAR2, -- 簽單序號
		p_cardno            IN    VARCHAR2, -- 卡號
		p_approvalno        IN    VARCHAR2, -- 授權碼
		p_wavecard          IN    VARCHAR2, -- 感應卡卡別
		p_ecrresponsecode   IN    VARCHAR2, -- 通訊回應碼
		p_merchantid        IN    VARCHAR2, -- 商店代號
		p_terminalid        IN    VARCHAR2, -- 收銀機代號
		p_cardtype          IN    VARCHAR2, -- 卡別
		p_batchno           IN    VARCHAR2, -- 批次號碼
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		UPDATE common.ucccmst
		SET
			receiptno = p_receiptno,
			cardno = p_cardno,
			approvalno = p_approvalno,
			wavecard = p_wavecard,
			ecrresponsecode = p_ecrresponsecode,
			merchantid = p_merchantid,
			terminalid = p_terminalid,
			cardtype = p_cardtype,
			batchno = p_batchno
		WHERE
			uccclog_seqno = p_uccclog_seqno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE ins_ucccdtl_rec (
		p_uccclog_seqno     IN    VARCHAR2, -- log 序號
		p_hcaseno           IN    VARCHAR2, -- 就診號
		p_encnttype         IN    VARCHAR2, -- 診別
		p_dischg_bill_no    IN    VARCHAR2, -- 帳單號
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		INSERT INTO common.ucccdtl (
			uccclog_seqno,
			approvalno,
			transamount,
			createdatetime,
			createid,
			createnmc,
			createcard,
			hcaseno,
			encnttype,
			dischg_bill_no
		)
			SELECT
				uccclog_seqno,
				approvalno,
				transamount,
				createdatetime,
				createid,
				createnmc,
				createcard,
				p_hcaseno,
				p_encnttype,
				p_dischg_bill_no
			FROM
				common.ucccmst
			WHERE
				uccclog_seqno = p_uccclog_seqno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE get_newborn_self_pay_rsn_rec (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  caseno,
			                  patnum,
			                  chang_reason,
			                  service_bill_pkg.get_code_desc ('ChangReaso', chang_reason) AS chang_reason_desc,
			                  effective_date,
			                  effective_time,
			                  to_date_safe (TO_CHAR (nvl (effective_date, to_date_safe ('19700101', 'YYYYMMDD')), 'YYYYMMDD') || nvl (effective_time
			                  , '0000'), 'YYYYMMDDHH24MI') AS effective_date_full,
			                  created_by,
			                  creation_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_by_name,
			                  last_update_date
		                  FROM
			                  bil_baby_set
		                  WHERE
			                  caseno = p_caseno;
	END;
	PROCEDURE ins_upd_nb_self_pay_rsn_rec (
		p_caseno            IN    VARCHAR2,
		p_patnum            IN    VARCHAR2,
		p_chang_reason      IN    VARCHAR2,
		p_effective_date    IN    DATE,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		MERGE INTO bil_baby_set
		USING dual ON (caseno = p_caseno)
		WHEN NOT MATCHED THEN
		INSERT (
			caseno,
			patnum,
			chang_reason,
			effective_date,
			effective_time,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date)
		VALUES
			(p_caseno,
			 p_patnum,
			 p_chang_reason,
			 p_effective_date,
			TO_CHAR (p_effective_date, 'HH24MI'),
			 p_operator_emp_id,
			 SYSDATE,
			 p_operator_emp_id,
			 SYSDATE)
		WHEN MATCHED THEN UPDATE
		SET chang_reason = p_chang_reason,
		    effective_date = p_effective_date,
		    effective_time = TO_CHAR (p_effective_date, 'HH24MI'),
		    last_updated_by = p_operator_emp_id,
		    last_update_date = SYSDATE;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_nb_self_pay_rsn_rec (
		p_caseno            IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		DELETE FROM bil_baby_set
		WHERE
			caseno = p_caseno;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE get_bil_date_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  caseno,
			                  hpatnum,
			                  bed_no,
			                  bil_date,
			                  pat_state,
			                  hfinacl,
			                  hfinacl2,
			                  ec_flag,
			                  days,
			                  pay_code,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  creation_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_update_date,
			                  wardno,
			                  beddge,
			                  bldiet,
			                  blonleav,
			                  blorflag,
			                  blordge,
			                  hnhi1typ,
			                  htraffic,
			                  hpaytype,
			                  daily_flag,
			                  bldietis,
			                  blmealx,
			                  blmeal,
			                  pdwdiet,
			                  pdwuser,
			                  pdwtime,
			                  pdwcode,
			                  diet_flag,
			                  pdw_flag
		                  FROM
			                  bil_date
		                  WHERE
			                  caseno = p_caseno
		                  ORDER BY
			                  bil_date DESC;
	END;
	PROCEDURE upd_bil_date (
		p_caseno            IN    VARCHAR2,
		p_bil_date          IN    DATE,
		p_blmeal            IN    VARCHAR2,
		p_beddge            IN    VARCHAR2,
		p_bldiet            IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		p_num_of_aff_rows   := 0;
		UPDATE bil_date
		SET
			blmeal = p_blmeal,
			beddge = p_beddge,
			ec_flag =
				CASE
					WHEN instr (p_beddge, 'CH') = 0 THEN
						'E'
					ELSE
						'C'
				END,
			bldiet = p_bldiet,
			last_updated_by = p_operator_emp_id,
			last_update_date = SYSDATE,
			diet_flag = 'N',
			daily_flag = 'N'
		WHERE
			caseno = p_caseno
			AND
			bil_date = p_bil_date;
		p_num_of_aff_rows   := SQL%rowcount;
		FOR rec IN (
			SELECT
				*
			FROM
				bil_date
			WHERE
				caseno = p_caseno
		) LOOP UPDATE bil_date
		SET
			days = (
				SELECT
					COUNT (*) + 1
				FROM
					bil_date
				WHERE
					caseno = rec.caseno
					AND
					hfinacl = rec.hfinacl
					AND
					ec_flag = rec.ec_flag
					AND
					bil_date < rec.bil_date
			)
		WHERE
			caseno = rec.caseno
			AND
			bil_date = rec.bil_date;
		END LOOP;
	END;
	PROCEDURE get_nhi_trans_rec_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  caseno,
			                  acnt_seq,
			                  bil_date,
			                  order_seqno,
			                  id,
			                  discharged,
			                  pf_key,
			                  biling_common_pkg.f_get_pfkey_name (pf_key, bil_date) AS item_name_en,
			                  biling_common_pkg.f_get_pfkey_cname (pf_key, bil_date) AS item_name_ch,
			                  ins_fee_code,
			                  create_dt,
			                  fee_kind,
			                  qty,
			                  charge_amount,
			                  emergency,
			                  self_flag,
			                  income_dept,
			                  log_location,
			                  discharge_bring_back,
			                  ward,
			                  bed_no,
			                  trans_reason,
			                  created_by,
			                  creation_date,
			                  last_updated_by,
			                  last_update_date,
			                  e_level,
			                  new_ins_fee_code,
			                  new_amount,
			                  bildate
		                  FROM
			                  bil_occur_trans
		                  WHERE
			                  caseno = p_caseno
		                  ORDER BY
			                  fee_kind,
			                  pf_key,
			                  create_dt,
			                  bil_date;
	END;
	PROCEDURE get_pat_basic (
		p_hhisnum   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  hhisnum,
			                  hnamec,
			                  hname,
			                  hnameu,
			                  hidno,
			                  passport_no,
			                  uniform_id_no,
			                  hsex,
			                  service_bill_pkg.get_code_desc ('Gender', hsex) AS hsex_desc,
			                  to_date_safe (hbirthdt, 'YYYYMMDD') AS hbirthdt,
			                  hresdnce,
			                  service_bill_pkg.get_code_desc ('HRESDNCE', hresdnce) AS hresdnce_desc,
			                  countrycode,
			                  service_bill_pkg.get_code_desc ('CountryNameCh', countrycode) AS countrycode_desc_ch,
			                  service_bill_pkg.get_code_desc ('CountryNameEn', countrycode) AS countrycode_desc_en,
			                  hzip,
			                  hpatadr,
			                  hozip,
			                  hopatadr,
			                  hphonhm1,
			                  hphonhm2,
			                  hphonof1,
			                  hphonof2,
			                  hpmobil
		                  FROM
			                  common.pat_basic
		                  WHERE
			                  hhisnum = p_hhisnum;
	END;
	PROCEDURE get_query_keys (
		p_case_type   IN    VARCHAR2,
		p_hhisnum     IN    VARCHAR2,
		p_caseno      IN    VARCHAR2,
		p_hidno       IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	) IS
		v_hhisnum VARCHAR2 (10);
	BEGIN
		v_hhisnum := p_hhisnum;
		IF v_hhisnum IS NULL AND p_hidno IS NOT NULL THEN
			v_hhisnum := service_bill_pkg.get_pat_no (upper (p_hidno));
		END IF;
		IF p_case_type = 'A' THEN
			OPEN p_cursor FOR SELECT
				                  p_case_type   AS case_type,
				                  service_bill_pkg.get_code_desc ('CaseType', p_case_type) AS case_type_desc,
				                  hhisnum,
				                  hcaseno       AS caseno,
				                  service_bill_pkg.get_pat_nat_no (hhisnum) AS hidno
			                  FROM
				                  common.pat_adm_case
				                  INNER JOIN bil_root ON pat_adm_case.hcaseno = bil_root.caseno
			                  WHERE
				                  (p_caseno IS NOT NULL
				                   AND
				                   hcaseno = lpad (p_caseno, 8, '0'))
				                  OR
				                  (p_caseno IS NULL
				                   AND
				                   hhisnum = upper (lpad (v_hhisnum, 10, '0')))
			                  ORDER BY
				                  caseno DESC;
		ELSIF p_case_type = 'B' THEN
			OPEN p_cursor FOR SELECT
				                  p_case_type   AS case_type,
				                  service_bill_pkg.get_code_desc ('CaseType', p_case_type) AS case_type_desc,
				                  hhisnum,
				                  id            AS caseno,
				                  service_bill_pkg.get_pat_nat_no (hhisnum) AS hidno
			                  FROM
				                  cpoe.ambulance_record
			                  WHERE
				                  status = 'Y'
				                  AND
				                  ((p_caseno IS NOT NULL
				                    AND
				                    id = p_caseno)
				                   OR
				                   (p_caseno IS NULL
				                    AND
				                    hhisnum = upper (lpad (v_hhisnum, 10, '0'))))
			                  ORDER BY
				                  caseno DESC;
		ELSIF p_case_type = 'E' THEN
			OPEN p_cursor FOR SELECT
				                  p_case_type   AS case_type,
				                  service_bill_pkg.get_code_desc ('CaseType', p_case_type) AS case_type_desc,
				                  emghhist      AS hhisnum,
				                  ecaseno       AS caseno,
				                  service_bill_pkg.get_pat_nat_no (emghhist) AS hidno
			                  FROM
				                  common.pat_emg_casen
			                  WHERE
				                  (p_caseno IS NOT NULL
				                   AND
				                   ecaseno = lpad (p_caseno, 8, '0'))
				                  OR
				                  (p_caseno IS NULL
				                   AND
				                   emghhist = upper (lpad (v_hhisnum, 10, '0')))
			                  ORDER BY
				                  caseno DESC;
		END IF;
	END;
	PROCEDURE get_pat_adm_case_list (
		p_hcaseno   IN    VARCHAR2,
		p_hhisnum   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  pat_adm_case.hcaseno,
			                  pat_adm_case.hhisnum,
			                  to_date_safe (pat_adm_case.hadmdt || pat_adm_case.hadmtm, 'YYYYMMDDHH24MI') AS hadmdttm,
			                  bil_root.dischg_date,
			                  pat_adm_case.hpatstat,
			                  service_bill_pkg.get_code_desc ('PatState', pat_adm_case.hpatstat) AS hpatstat_desc,
			                  bil_root.hfinacl,
			                  service_bill_pkg.get_code_desc ('HFINACL1', bil_root.hfinacl) AS hfinacl_desc,
			                  bil_root.hfinacl2,
			                  service_bill_pkg.get_code_desc ('HFINACL2', bil_root.hfinacl2) AS hfinacl2_desc,
			                  pat_adm_case.hnursta,
			                  pat_adm_case.hbed,
			                  pat_adm_case.hcursvcl,
			                  service_bill_pkg.get_code_desc ('Section', pat_adm_case.hcursvcl) AS hcursvcl_desc,
			                  pat_adm_case.hcardic,
			                  service_bill_pkg.get_adm_pickup_medicine_no (pat_adm_case.hcaseno) AS pickup_medicine_no,
			                  pat_adm_case.hinptype,
			                  service_bill_pkg.get_code_desc ('AdmitSour', pat_adm_case.hinptype) AS hinptype_desc,
			                  pat_adm_case.in_caseno,
			                  pat_adm_case.hreadmit,
			                  bil_root.bl14days,
			                  bil_root.bl14c1,
			                  bil_root.blcsfg,
			                  pat_adm_case.hvdocnm
		                  FROM
			                  common.pat_adm_case
			                  INNER JOIN bil_root ON pat_adm_case.hcaseno = bil_root.caseno
		                  WHERE
			                  (p_hcaseno IS NOT NULL
			                   AND
			                   pat_adm_case.hcaseno = p_hcaseno)
			                  OR
			                  (p_hcaseno IS NULL
			                   AND
			                   pat_adm_case.hhisnum = p_hhisnum)
		                  ORDER BY
			                  hcaseno DESC;
	END;
	PROCEDURE get_pat_emg_casen_list (
		p_ecaseno    IN    VARCHAR2,
		p_emghhist   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  ecaseno,
			                  emghhist,
			                  emgdt,
			                  emglvdt,
			                  emgpstat,
			                  service_bill_pkg.get_code_desc ('PatState', emgpstat) AS emgpstat_desc,
			                  emg1fncl,
			                  service_bill_pkg.get_code_desc ('EMG1FNCL', emg1fncl) AS emg1fncl_desc,
			                  emg2fncl,
			                  service_bill_pkg.get_code_desc ('EMG2FNCL', emg2fncl) AS emg2fncl_desc,
			                  emgns,
			                  emgbedno,
			                  emgdept,
			                  service_bill_pkg.get_code_desc ('Section', emgdept) AS emgdept_desc,
			                  emgicard,
			                  service_bill_pkg.get_emg_pickup_medicine_no (ecaseno) AS pickup_medicine_no,
			                  emgvsnm,
			                  emgspeu1,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = emgspeu1
					                  AND
					                  bilkind = 'B'
			                  ) AS emgspeu1_desc,
			                  emgspeu1_sta_date,
			                  emgspeu1_end_date,
			                  emgspeu2,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = emgspeu2
					                  AND
					                  bilkind = 'B'
			                  ) AS emgspeu2_desc,
			                  emgspeu2_sta_date,
			                  emgspeu2_end_date
		                  FROM
			                  common.pat_emg_casen
		                  WHERE
			                  (p_ecaseno IS NOT NULL
			                   AND
			                   ecaseno = p_ecaseno)
			                  OR
			                  (p_ecaseno IS NULL
			                   AND
			                   emghhist = p_emghhist)
		                  ORDER BY
			                  ecaseno DESC;
	END;
	PROCEDURE get_ambulance_record_list (
		p_id        IN    VARCHAR2,
		p_hhisnum   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  id,
			                  status,
			                  service_bill_pkg.get_code_desc ('WardBldg', ward) AS bldg,
			                  ward,
			                  bedno,
			                  type,
			                  service_bill_pkg.get_code_desc ('AmbuType', ambulance_record.type) AS type_desc,
			                  code,
			                  (
				                  SELECT
					                  county || township
				                  FROM
					                  cpoe.ambulance_fee
				                  WHERE
					                  id = code
			                  ) AS code_desc,
			                  special_crew,
			                  service_bill_pkg.get_code_desc ('AmbuCrewType', cpoe.ambulance_record.special_crew) AS special_crew_desc,
			                  reinfcar,
			                  service_bill_pkg.get_code_desc ('AmbuModelType', ambulance_record.reinfcar) AS reinfcar_desc,
			                  oxygen,
			                  service_type,
			                  service_bill_pkg.get_code_desc ('AmbuSvcType', service_type) AS service_type_desc,
			                  service_note,
			                  discount_yn,
			                  fare,
			                  special_crew_fee,
			                  reinfcarfee,
			                  oxygen_fee,
			                  dr_crew_fee,
			                  nurse_crew_fee,
			                  driver_fee,
			                  incubator,
			                  inspirator,
			                  total,
			                  ins_opid,
			                  ins_opname,
			                  ins_dtm,
			                  charge_yn,
			                  service_bill_pkg.get_code_desc ('YesNoFlag', charge_yn) AS charge_yn_desc,
			                  charge_opid,
			                  charge_opname,
			                  charge_dtm,
			                  hhisnum,
			                  sysid    AS src_case_type,
			                  caseno   AS src_caseno
		                  FROM
			                  cpoe.ambulance_record
		                  WHERE
			                  status = 'Y'
			                  AND
			                  (p_id IS NOT NULL
			                   AND
			                   id = p_id)
			                  OR
			                  (p_id IS NULL
			                   AND
			                   hhisnum = p_hhisnum)
		                  ORDER BY
			                  id DESC;
	END;
	PROCEDURE get_opdroot_list (
		p_opdcaseno   IN    VARCHAR2,
		p_hhisnum     IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  opdcaseno,
			                  hhisnum,
			                  to_date_safe (opddate, 'YYYYMMDD') AS opddate,
			                  opdfinishcode,
			                  service_bill_pkg.get_code_desc ('OPDState', opdfinishcode) AS hpatstat_desc,
			                  hfinacl,
			                  service_bill_pkg.get_code_desc ('OPD1FNCL', hfinacl) AS hfinacl_desc,
			                  hfinacl2,
			                  service_bill_pkg.get_code_desc ('OPD2FNCL', hfinacl2) AS hfinacl2_desc,
			                  opdsection,
			                  service_bill_pkg.get_code_desc ('Section', opdsection) AS opdsection_desc,
			                  insulookseq,
			                  drugwincode || '-' || opddispno AS pickup_medicine_no,
			                  opddrnmc
		                  FROM
			                  opdusr.opdroot
		                  WHERE
			                  (p_opdcaseno IS NOT NULL
			                   AND
			                   opdcaseno = p_opdcaseno)
			                  OR
			                  (p_opdcaseno IS NULL
			                   AND
			                   hhisnum = p_hhisnum)
		                  ORDER BY
			                  opdcaseno DESC;
	END;
	PROCEDURE get_bil_feemst (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  caseno,
			                  st_date,
			                  end_date,
			                  emg_bed_days,
			                  nvl (emg_exp_amt1, 0) AS emg_exp_amt1,
			                  nvl (emg_pay_amt1, 0) AS emg_pay_amt1,
			                  nvl (emg_exp_amt2, 0) AS emg_exp_amt2,
			                  nvl (emg_pay_amt2, 0) AS emg_pay_amt2,
			                  nvl (emg_exp_amt3, 0) AS emg_exp_amt3,
			                  nvl (emg_pay_amt3, 0) AS emg_pay_amt3,
			                  nvl (emg_exp_amt4, 0) AS emg_exp_amt4,
			                  nvl (emg_pay_amt4, 0) AS emg_pay_amt4,
			                  chron_bed_days,
			                  nvl (chron_exp_amt1, 0) AS chron_exp_amt1,
			                  nvl (chron_pay_amt1, 0) AS chron_pay_amt1,
			                  nvl (chron_exp_amt2, 0) AS chron_exp_amt2,
			                  nvl (chron_pay_amt2, 0) AS chron_pay_amt2,
			                  nvl (chron_exp_amt3, 0) AS chron_exp_amt3,
			                  nvl (chron_pay_amt3, 0) AS chron_pay_amt3,
			                  nvl (chron_exp_amt4, 0) AS chron_exp_amt4,
			                  nvl (chron_pay_amt4, 0) AS chron_pay_amt4,
			                  tot_self_amt,
			                  tot_gl_amt,
			                  credit_amt,
			                  service_bill_pkg.get_adm_total_payable_amt (caseno, 'CIVC') AS total_payable_amt,
			                  service_bill_pkg.get_adm_total_prepaid_amt (caseno, 'CIVC') AS total_prepaid_amt,
			                  service_bill_pkg.get_adm_owed_amt (caseno, 'CIVC') AS owed_mt,
			                  service_bill_pkg.get_adm_tot_negot_instru_amt (caseno) AS tot_negot_instr_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  creation_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_update_date,
			                  service_bill_pkg.get_adm_fee_locked_flag (caseno) AS locked_flag,
			                  service_bill_pkg.get_num_of_uncal_charge_item (caseno) AS num_of_uncalc_items
		                  FROM
			                  bil_feemst
		                  WHERE
			                  caseno = p_caseno;
	END;
	PROCEDURE get_emg_bil_feemst (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  caseno,
			                  st_date,
			                  end_date,
			                  emg_bed_days,
			                  nvl (emg_exp_amt1, 0) AS emg_exp_amt1,
			                  nvl (emg_pay_amt1, 0) AS emg_pay_amt1,
			                  nvl (emg_exp_amt2, 0) AS emg_exp_amt2,
			                  nvl (emg_pay_amt2, 0) AS emg_pay_amt2,
			                  nvl (emg_exp_amt3, 0) AS emg_exp_amt3,
			                  nvl (emg_pay_amt3, 0) AS emg_pay_amt3,
			                  nvl (emg_exp_amt4, 0) AS emg_exp_amt4,
			                  nvl (emg_pay_amt4, 0) AS emg_pay_amt4,
			                  chron_bed_days,
			                  nvl (chron_exp_amt1, 0) AS chron_exp_amt1,
			                  nvl (chron_pay_amt1, 0) AS chron_pay_amt1,
			                  nvl (chron_exp_amt2, 0) AS chron_exp_amt2,
			                  nvl (chron_pay_amt2, 0) AS chron_pay_amt2,
			                  nvl (chron_exp_amt3, 0) AS chron_exp_amt3,
			                  nvl (chron_pay_amt3, 0) AS chron_pay_amt3,
			                  nvl (chron_exp_amt4, 0) AS chron_exp_amt4,
			                  nvl (chron_pay_amt4, 0) AS chron_pay_amt4,
			                  tot_self_amt,
			                  tot_gl_amt,
			                  credit_amt,
			                  service_bill_pkg.get_emg_total_payable_amt (caseno, 'CIVC') AS total_payable_amt,
			                  service_bill_pkg.get_emg_total_prepaid_amt (caseno, 'CIVC') AS total_prepaid_amt,
			                  service_bill_pkg.get_emg_owed_amt (caseno, 'CIVC') AS owed_mt,
			                  service_bill_pkg.get_emg_tot_negot_instru_amt (caseno) AS tot_negot_instr_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  created_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_update_date,
			                  service_bill_pkg.get_emg_fee_locked_flag (caseno) AS locked_flag
		                  FROM
			                  emg_bil_feemst
		                  WHERE
			                  caseno = p_caseno;
	END;
	PROCEDURE get_bil_billmst_list (
		p_caseno     IN    VARCHAR2,
		p_unitcode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  dischg_bill_no,
			                  caseno,
			                  paid_type,
			                  service_bill_pkg.get_code_desc ('PAID_TYPE', paid_type) AS paid_type_desc,
			                  paid_flag,
			                  service_bill_pkg.get_code_desc ('BillFlag', paid_flag) AS paid_flag_desc,
			                  st_date,
			                  end_date,
			                  emg_bed_days,
			                  nvl (emg_exp_amt1, 0) AS emg_exp_amt1,
			                  nvl (emg_pay_amt1, 0) AS emg_pay_amt1,
			                  nvl (emg_exp_amt2, 0) AS emg_exp_amt2,
			                  nvl (emg_pay_amt2, 0) AS emg_pay_amt2,
			                  nvl (emg_exp_amt3, 0) AS emg_exp_amt3,
			                  nvl (emg_pay_amt3, 0) AS emg_pay_amt3,
			                  nvl (emg_exp_amt4, 0) AS emg_exp_amt4,
			                  nvl (emg_pay_amt4, 0) AS emg_pay_amt4,
			                  chron_bed_days,
			                  nvl (chron_exp_amt1, 0) AS chron_exp_amt1,
			                  nvl (chron_pay_amt1, 0) AS chron_pay_amt1,
			                  nvl (chron_exp_amt2, 0) AS chron_exp_amt2,
			                  nvl (chron_pay_amt2, 0) AS chron_pay_amt2,
			                  nvl (chron_exp_amt3, 0) AS chron_exp_amt3,
			                  nvl (chron_pay_amt3, 0) AS chron_pay_amt3,
			                  nvl (chron_exp_amt4, 0) AS chron_exp_amt4,
			                  nvl (chron_pay_amt4, 0) AS chron_pay_amt4,
			                  tot_self_amt,
			                  tot_gl_amt,
			                  credit_amt,
			                  pre_paid_amt,
			                  total_amt,
			                  rec_status,
			                  service_bill_pkg.get_code_desc ('REC_STATUS', rec_status) AS rec_status_desc,
			                  pat_kind,
			                  service_bill_pkg.get_code_desc ('PayType', pat_kind) AS pat_kind_desc,
			                  pat_paid_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  creation_date,
			                  last_updated_by,
			                  handler,
			                  last_update_date,
			                  paid_date,
			                  seqno,
			                  credit_card_approval_no,
			                  host_id,
			                  printer_id,
			                  unitcode,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = unitcode
					                  AND
					                  bilkind = 'B'
			                  ) AS unitcode_desc
		                  FROM
			                  bil_billmst
		                  WHERE
			                  rec_status != 'C'
			                  AND
			                  caseno = p_caseno
			                  AND
			                  unitcode = p_unitcode
		                  ORDER BY
			                  creation_date DESC;
	END;
	PROCEDURE get_emg_bil_billmst_list (
		p_caseno     IN    VARCHAR2,
		p_unitcode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  dischg_bill_no,
			                  caseno,
			                  paid_type,
			                  service_bill_pkg.get_code_desc ('PAID_TYPE', paid_type) AS paid_type_desc,
			                  paid_flag,
			                  service_bill_pkg.get_code_desc ('BillFlag', paid_flag) AS paid_flag_desc,
			                  st_date,
			                  end_date,
			                  emg_bed_days,
			                  nvl (emg_exp_amt1, 0) AS emg_exp_amt1,
			                  nvl (emg_pay_amt1, 0) AS emg_pay_amt1,
			                  nvl (emg_exp_amt2, 0) AS emg_exp_amt2,
			                  nvl (emg_pay_amt2, 0) AS emg_pay_amt2,
			                  nvl (emg_exp_amt3, 0) AS emg_exp_amt3,
			                  nvl (emg_pay_amt3, 0) AS emg_pay_amt3,
			                  nvl (emg_exp_amt4, 0) AS emg_exp_amt4,
			                  nvl (emg_pay_amt4, 0) AS emg_pay_amt4,
			                  chron_bed_days,
			                  nvl (chron_exp_amt1, 0) AS chron_exp_amt1,
			                  nvl (chron_pay_amt1, 0) AS chron_pay_amt1,
			                  nvl (chron_exp_amt2, 0) AS chron_exp_amt2,
			                  nvl (chron_pay_amt2, 0) AS chron_pay_amt2,
			                  nvl (chron_exp_amt3, 0) AS chron_exp_amt3,
			                  nvl (chron_pay_amt3, 0) AS chron_pay_amt3,
			                  nvl (chron_exp_amt4, 0) AS chron_exp_amt4,
			                  nvl (chron_pay_amt4, 0) AS chron_pay_amt4,
			                  tot_self_amt,
			                  tot_gl_amt,
			                  credit_amt,
			                  pre_paid_amt,
			                  total_amt,
			                  rec_status,
			                  service_bill_pkg.get_code_desc ('REC_STATUS', rec_status) AS rec_status_desc,
			                  pat_kind,
			                  service_bill_pkg.get_code_desc ('PayType', pat_kind) AS pat_kind_desc,
			                  pat_paid_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  created_date,
			                  last_updated_by,
			                  handler,
			                  last_update_date,
			                  paid_date,
			                  seqno,
			                  credit_card_approval_no,
			                  host_id,
			                  printer_id,
			                  refund_amt,
			                  unitcode,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = unitcode
					                  AND
					                  bilkind = 'B'
			                  ) AS unitcode_desc
		                  FROM
			                  emg_bil_billmst
		                  WHERE
			                  (rec_status != 'C'
			                   OR
			                   paid_flag != 'N')
			                  AND
			                  caseno = p_caseno
			                  AND
			                  unitcode = p_unitcode
		                  ORDER BY
			                  created_date DESC;
	END;
	PROCEDURE get_bil_check_bill_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  caseno,
			                  bill_kind,
			                  service_bill_pkg.get_code_desc ('BillKind', bill_kind) AS bill_kind_desc,
			                  check_no,
			                  bill_date,
			                  due_date,
			                  bill_amt,
			                  bank_name,
			                  accountno,
			                  status,
			                  service_bill_pkg.get_code_desc ('CKStatus', status) AS status_desc,
			                  pay_date,
			                  return_date,
			                  note,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  createion_date,
			                  last_updated_by,
			                  handler,
			                  last_update_date
		                  FROM
			                  bil_check_bill
		                  WHERE
			                  caseno = p_caseno
		                  ORDER BY
			                  caseno DESC,
			                  last_update_date DESC;
	END;
	PROCEDURE get_emg_bil_check_bill_list (
		p_caseno   IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  caseno,
			                  bill_kind,
			                  service_bill_pkg.get_code_desc ('BillKind', bill_kind) AS bill_kind_desc,
			                  check_no,
			                  bill_date,
			                  due_date,
			                  bill_amt,
			                  bank_name,
			                  accountno,
			                  status,
			                  service_bill_pkg.get_code_desc ('CKStatus', status) AS status_desc,
			                  pay_date,
			                  return_date,
			                  note,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  created_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_update_date
		                  FROM
			                  emg_bil_check_bill
		                  WHERE
			                  caseno = p_caseno
		                  ORDER BY
			                  caseno DESC,
			                  last_update_date DESC;
	END;
	PROCEDURE get_bil_debt_rec_list (
		p_hpatnum             IN    VARCHAR2,
		p_caseno              IN    VARCHAR2,
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_lower_thold_amt     IN    NUMBER,
		p_upper_thold_amt     IN    NUMBER,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  bil_debt_rec.caseno,
			                  bil_debt_rec.dischg_date,
			                  bil_debt_rec.change_flag,
			                  service_bill_pkg.get_code_desc ('DebtFlag', bil_debt_rec.change_flag) AS change_flag_desc,
			                  bil_debt_rec.debt_amt,
			                  bil_debt_rec.overdue_date,
			                  bil_debt_rec.baddebt_date,
			                  bil_debt_rec.baddebt_document,
			                  bil_debt_rec.created_by,
			                  service_bill_pkg.get_emp_name_ch (bil_debt_rec.created_by) AS created_emp_name,
			                  bil_debt_rec.creation_date,
			                  bil_debt_rec.last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (bil_debt_rec.last_updated_by) AS last_updated_emp_name,
			                  bil_debt_rec.last_update_date,
			                  bil_debt_rec.display_flag,
			                  service_bill_pkg.get_sw_flag (caseno) AS sw_flag
		                  FROM
			                  bil_debt_rec
			                  INNER JOIN common.pat_adm_case ON bil_debt_rec.caseno = pat_adm_case.hcaseno
		                  WHERE
			                  (p_hpatnum IS NULL
			                   OR
			                   (p_hpatnum IS NOT NULL
			                    AND
			                    bil_debt_rec.hpatnum = p_hpatnum))
			                  AND
			                  (p_caseno IS NULL
			                   OR
			                   (p_caseno IS NOT NULL
			                    AND
			                    bil_debt_rec.caseno = p_caseno))
			                  AND
			                  (p_start_dischg_date IS NULL
			                   OR
			                   (p_start_dischg_date IS NOT NULL
			                    AND
			                    trunc (bil_debt_rec.dischg_date) >= trunc (p_start_dischg_date)))
			                  AND
			                  (p_end_dischg_date IS NULL
			                   OR
			                   (p_end_dischg_date IS NOT NULL
			                    AND
			                    trunc (bil_debt_rec.dischg_date) <= trunc (p_end_dischg_date)))
			                  AND
			                  (p_lower_thold_amt IS NULL
			                   OR
			                   (p_lower_thold_amt IS NOT NULL
			                    AND
			                    service_bill_pkg.get_adm_owed_amt (caseno, 'CIVC') >= p_lower_thold_amt))
			                  AND
			                  (p_upper_thold_amt IS NULL
			                   OR
			                   (p_upper_thold_amt IS NOT NULL
			                    AND
			                    service_bill_pkg.get_adm_owed_amt (caseno, 'CIVC') <= p_upper_thold_amt))
		                  ORDER BY
			                  bil_debt_rec.dischg_date DESC;
	END;
	PROCEDURE get_emg_bil_debt_rec_list (
		p_hpatnum             IN    VARCHAR2,
		p_caseno              IN    VARCHAR2,
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_lower_thold_amt     IN    NUMBER,
		p_upper_thold_amt     IN    NUMBER,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  emg_bil_debt_rec.caseno,
			                  emg_bil_debt_rec.dischg_date,
			                  emg_bil_debt_rec.change_flag,
			                  service_bill_pkg.get_code_desc ('DebtFlag', emg_bil_debt_rec.change_flag) AS change_flag_desc,
			                  emg_bil_debt_rec.debt_amt,
			                  emg_bil_debt_rec.overdue_date,
			                  emg_bil_debt_rec.baddebt_date,
			                  emg_bil_debt_rec.baddebt_document,
			                  emg_bil_debt_rec.created_by,
			                  service_bill_pkg.get_emp_name_ch (emg_bil_debt_rec.created_by) AS created_emp_name,
			                  emg_bil_debt_rec.created_date,
			                  emg_bil_debt_rec.last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (emg_bil_debt_rec.last_updated_by) AS last_updated_emp_name,
			                  emg_bil_debt_rec.last_update_date,
			                  emg_bil_debt_rec.display_flag
		                  FROM
			                  emg_bil_debt_rec
			                  INNER JOIN common.pat_emg_casen ON emg_bil_debt_rec.caseno = pat_emg_casen.ecaseno
		                  WHERE
			                  (p_hpatnum IS NULL
			                   OR
			                   (p_hpatnum IS NOT NULL
			                    AND
			                    emg_bil_debt_rec.hpatnum = p_hpatnum))
			                  AND
			                  (p_caseno IS NULL
			                   OR
			                   (p_caseno IS NOT NULL
			                    AND
			                    emg_bil_debt_rec.caseno = p_caseno))
			                  AND
			                  (p_start_dischg_date IS NULL
			                   OR
			                   (p_start_dischg_date IS NOT NULL
			                    AND
			                    trunc (emg_bil_debt_rec.dischg_date) >= p_start_dischg_date))
			                  AND
			                  (p_end_dischg_date IS NULL
			                   OR
			                   (p_end_dischg_date IS NOT NULL
			                    AND
			                    trunc (emg_bil_debt_rec.dischg_date) <= p_end_dischg_date))
			                  AND
			                  (p_lower_thold_amt IS NULL
			                   OR
			                   (p_lower_thold_amt IS NOT NULL
			                    AND
			                    service_bill_pkg.get_emg_owed_amt (caseno, 'CIVC') >= p_lower_thold_amt))
			                  AND
			                  (p_upper_thold_amt IS NULL
			                   OR
			                   (p_upper_thold_amt IS NOT NULL
			                    AND
			                    service_bill_pkg.get_emg_owed_amt (caseno, 'CIVC') <= p_upper_thold_amt))
		                  ORDER BY
			                  emg_bil_debt_rec.dischg_date DESC;
	END;
	PROCEDURE get_opddebt_list (
		p_hhisnum           IN    VARCHAR2,
		p_hcaseno           IN    VARCHAR2,
		p_start_visitdate   IN    DATE,
		p_end_visitdate     IN    DATE,
		p_lower_thold_amt   IN    NUMBER,
		p_upper_thold_amt   IN    NUMBER,
		p_cursor            OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  opddebt.hcaseno,
			                  opddebt.hhisnum,
			                  to_date_safe (opddebt.visitdate, 'YYYYMMDD') AS visitdate,
			                  opddebt.debttype,
			                  service_bill_pkg.get_code_desc ('OpdDebtFlag', opddebt.debttype) AS debttype_desc,
			                  opddebt.debtamount,
			                  opddebt.overdue_date,
			                  opddebt.baddebt_date,
			                  opddebt.baddebt_document,
			                  opddebt.createcard,
			                  opddebt.createnmc,
			                  to_date_safe (opddebt.createdatetime, 'YYYYMMDDHH24MISS') AS created_date,
			                  opddebt.proccard,
			                  opddebt.procnmc,
			                  to_date_safe (opddebt.procdatetime, 'YYYYMMDDHH24MISS') AS last_update_date,
			                  opddebt.displayyn
		                  FROM
			                  opdusr.opddebt
			                  INNER JOIN opdusr.opdroot ON opddebt.hcaseno = opdroot.opdcaseno
		                  WHERE
			                  opddebt.cancelyn = 'N'
			                  AND
			                  opddebt.recedemandyn = 'Y'
			                  AND
			                  (p_hhisnum IS NULL
			                   OR
			                   (p_hhisnum IS NOT NULL
			                    AND
			                    opddebt.hhisnum = p_hhisnum))
			                  AND
			                  (p_hcaseno IS NULL
			                   OR
			                   (p_hcaseno IS NOT NULL
			                    AND
			                    opddebt.hcaseno = p_hcaseno))
			                  AND
			                  (p_start_visitdate IS NULL
			                   OR
			                   (p_start_visitdate IS NOT NULL
			                    AND
			                    to_date_safe (opddebt.visitdate, 'YYYYMMDD') >= p_start_visitdate))
			                  AND
			                  (p_end_visitdate IS NULL
			                   OR
			                   (p_end_visitdate IS NOT NULL
			                    AND
			                    to_date_safe (opddebt.visitdate, 'YYYYMMDD') <= p_end_visitdate))
			                  AND
			                  (p_lower_thold_amt IS NULL
			                   OR
			                   (p_lower_thold_amt IS NOT NULL
			                    AND
			                    opddebt.debtamount >= p_lower_thold_amt))
			                  AND
			                  (p_upper_thold_amt IS NULL
			                   OR
			                   (p_upper_thold_amt IS NOT NULL
			                    AND
			                    opddebt.debtamount <= p_upper_thold_amt))
		                  UNION
		                  SELECT
			                  opdroot.opdcaseno,
			                  opdroot.hhisnum,
			                  to_date_safe (opdroot.opddate, 'YYYYMMDD'),
			                  '1',
			                  '中醫會診',
			                  opdblbm.paytotal,
			                  NULL,
			                  NULL,
			                  NULL,
			                  opdblbm.createcard,
			                  opdblbm.createnmc,
			                  to_date_safe (opdblbm.createdatetime, 'YYYYMMDDHH24MISS'),
			                  opdblbm.proccard,
			                  opdblbm.procnmc,
			                  to_date_safe (opdblbm.procdatetime, 'YYYYMMDDHH24MISS'),
			                  'Y'
		                  FROM
			                  opdusr.opdroot
			                  INNER JOIN opdusr.opdblbm ON opdroot.opdcaseno = opdblbm.opdcaseno
			                                               AND
			                                               opdblbm.billstatus = 'N'
			                  LEFT JOIN opdusr.opddebt ON opdroot.opdcaseno = opddebt.hcaseno
		                  WHERE
			                  opdroot.opdsection = 'TCM'
			                  AND
			                  opdroot.cancelyn = 'N'
			                  AND
			                  opdroot.opdasmfg LIKE 'A%'
			                  AND
			                  opddebt.hcaseno IS NULL
			                  AND
			                  (p_hhisnum IS NOT NULL
			                   AND
			                   opdroot.hhisnum = p_hhisnum)
		                  ORDER BY
			                  visitdate DESC;
	END;
	PROCEDURE get_pat_adm_financial_list (
		p_hcaseno   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  hfinancl,
			                  hfinancl_desc,
			                  hfincl2,
			                  hfinanc2_desc,
			                  hfindate,
			                  ins_date,
			                  hfinuser,
			                  hfinuser_emp_name,
			                  hfininf,
			                  hcardic,
			                  history_flag
		                  FROM
			                  (
				                  SELECT
					                  hfinancl,
					                  service_bill_pkg.get_code_desc ('HFINACL1', hfinancl) AS hfinancl_desc,
					                  hfincl2,
					                  service_bill_pkg.get_code_desc ('HFINACL2', hfincl2) AS hfinanc2_desc,
					                  to_date_safe (hfindate, 'YYYYMMDD') AS hfindate,
					                  ins_date,
					                  hfinuser,
					                  service_bill_pkg.get_emp_name_ch (hfinuser) AS hfinuser_emp_name,
					                  to_date_safe (hfininf, 'YYYYMMDD') AS hfininf,
					                  hcardic,
					                  'N' AS history_flag
				                  FROM
					                  common.pat_adm_financial
				                  WHERE
					                  hcaseno = p_hcaseno
				                  UNION ALL
				                  SELECT
					                  hfinancl,
					                  service_bill_pkg.get_code_desc ('HFINACL1', hfinancl),
					                  hfincl2,
					                  service_bill_pkg.get_code_desc ('HFINACL2', hfincl2),
					                  to_date_safe (hfindate, 'YYYYMMDD'),
					                  ins_date,
					                  hfinuser,
					                  service_bill_pkg.get_emp_name_ch (hfinuser),
					                  to_date_safe (hfininf, 'YYYYMMDD'),
					                  hcardic,
					                  'Y' AS history_flag
				                  FROM
					                  common.pat_adm_financial_hist
				                  WHERE
					                  hcaseno = p_hcaseno
			                  )
		                  ORDER BY
			                  CASE
				                  WHEN history_flag = 'N' THEN
					                  1
				                  WHEN history_flag = 'Y' THEN
					                  2
				                  ELSE
					                  3
			                  END,
			                  hfindate DESC,
			                  hfininf DESC,
			                  ins_date DESC;
	END;
	PROCEDURE get_bil_critical_dtl_list (
		p_hhisnum      IN    VARCHAR2,
		p_icd          IN    VARCHAR2,
		p_begin_date   IN    DATE,
		p_end_date     IN    DATE,
		p_cursor       OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  copayicd,
			                  service_bill_pkg.get_icd_name (copayicd, 'EN') AS icd_name_en,
			                  service_bill_pkg.get_icd_name (copayicd, 'CH') AS icd_name_ch,
			                  copaybdt,
			                  copayedt,
			                  copayno,
			                  copayiid,
			                  service_bill_pkg.get_emp_name_ch (copayiid) AS copayiid_emp_name,
			                  copayidt,
			                  copaymid,
			                  service_bill_pkg.get_emp_name_ch (copaymid) AS copaymid_emp_name,
			                  copaymdt
		                  FROM
			                  bil_critical_dtl
		                  WHERE
			                  copstatus = 'Y'
			                  AND
			                  (copayid = service_bill_pkg.get_pat_nat_no (p_hhisnum))
			                  AND
			                  (p_icd IS NULL
			                   OR
			                   (p_icd IS NOT NULL
			                    AND
			                    copayicd = p_icd))
			                  AND
			                  (p_begin_date IS NULL
			                   OR
			                   (p_begin_date IS NOT NULL
			                    AND
			                    copaybdt = p_begin_date))
			                  AND
			                  (p_end_date IS NULL
			                   OR
			                   (p_end_date IS NOT NULL
			                    AND
			                    copayedt = p_end_date))
		                  UNION
		                  SELECT
			                  dxicd,
			                  service_bill_pkg.get_icd_name (dxicd, 'EN'),
			                  service_bill_pkg.get_icd_name (dxicd, 'CH'),
			                  to_date_safe (begindate, 'YYYYMMDD'),
			                  to_date_safe (enddate, 'YYYYMMDD'),
			                  '',
			                  service_bill_pkg.get_emp_card_no (createid),
			                  createnmc,
			                  to_date_safe (createdatetime, 'YYYYMMDDHH24MISS'),
			                  service_bill_pkg.get_emp_card_no (procid),
			                  procnmc,
			                  to_date_safe (procdatetime, 'YYYYMMDDHH24MISS')
		                  FROM
			                  opdusr.nhicicard
		                  WHERE
			                  cancelyn = 'N'
			                  AND
			                  hhisnum = p_hhisnum
			                  AND
			                  (p_icd IS NULL
			                   OR
			                   (p_icd IS NOT NULL
			                    AND
			                    dxicd = p_icd))
			                  AND
			                  (p_begin_date IS NULL
			                   OR
			                   (p_begin_date IS NOT NULL
			                    AND
			                    to_date_safe (begindate, 'YYYYMMDD') = p_begin_date))
			                  AND
			                  (p_end_date IS NULL
			                   OR
			                   (p_end_date IS NOT NULL
			                    AND
			                    to_date_safe (enddate, 'YYYYMMDD') = p_end_date))
		                  ORDER BY
			                  copaybdt;
	END;
	PROCEDURE get_abs_charge_list (
		p_abstype   IN    VARCHAR2,
		p_absno     IN    VARCHAR2,
		p_absseq    IN    NUMBER,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  abstype,
			                  (
				                  SELECT
					                  abs_desc
				                  FROM
					                  abs_form_def_mas
				                  WHERE
					                  abs_type = abstype
			                  ) AS abstype_desc,
			                  CASE
				                  WHEN abstype IN (
					                  'HC',
					                  'HE',
					                  'DV'
				                  ) THEN
					                  caseno
				                  ELSE
					                  hhisnum
			                  END AS absno,
			                  absseq,
			                  price,
			                  amount,
			                  chargeuser,
			                  chargeusername,
			                  chargedate,
			                  seqno,
			                  in_billtemp,
			                  service_bill_pkg.get_code_desc ('YesNoFlag', in_billtemp) AS in_billtemp_desc,
			                  pat_kind
		                  FROM
			                  abs_charge
		                  WHERE
			                  abstype = p_abstype
			                  AND
			                  p_absno =
				                  CASE
					                  WHEN abstype IN (
						                  'HC',
						                  'HE',
						                  'DV'
					                  ) THEN
						                  caseno
					                  ELSE
						                  hhisnum
				                  END
			                  AND
			                  absseq = p_absseq
		                  ORDER BY
			                  chargedate DESC;
	END;
	PROCEDURE get_abs_emg_charge_list (
		p_abstype   IN    VARCHAR2,
		p_absno     IN    VARCHAR2,
		p_absseq    IN    NUMBER,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  abstype,
			                  (
				                  SELECT
					                  abs_desc
				                  FROM
					                  abs_form_def_mas
				                  WHERE
					                  abs_type = abstype
			                  ) AS abstype_desc,
			                  absno,
			                  absseq,
			                  price,
			                  amount,
			                  create_time,
			                  creator_cardid,
			                  creator_name,
			                  is_charge,
			                  service_bill_pkg.get_code_desc ('YesNoFlag', is_charge) AS is_charge_desc,
			                  emgspeu1,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = emgspeu1
					                  AND
					                  bilkind = 'B'
			                  ) AS emgspeu1_desc,
			                  emgspeu2,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = emgspeu2
					                  AND
					                  bilkind = 'B'
			                  ) AS emgspeu2_desc
		                  FROM
			                  abs_emg_charge
		                  WHERE
			                  abstype = p_abstype
			                  AND
			                  absno = p_absno
			                  AND
			                  absseq = p_absseq
		                  ORDER BY
			                  create_time DESC;
	END;
	PROCEDURE get_ambulance_charge_list (
		p_id       IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  id,
			                  caseno,
			                  charge_kind,
			                  charge_type,
			                  service_bill_pkg.get_code_desc ('PayType', charge_type) AS charge_type_desc,
			                  charge_amt,
			                  operater_id,
			                  operater_name,
			                  operater_date,
			                  seqno,
			                  accounting_seq,
			                  host_ip,
			                  log_printer_id
		                  FROM
			                  ambulance_charge
		                  WHERE
			                  id = p_id
		                  ORDER BY
			                  operater_date;
	END;
	PROCEDURE ins_upd_bil_debt_rec (
		p_caseno             IN    VARCHAR2,
		p_change_flag        IN    VARCHAR2,
		p_overdue_date       IN    DATE,
		p_baddebt_date       IN    DATE,
		p_baddebt_document   IN    VARCHAR2,
		p_display_flag       IN    VARCHAR2,
		p_opr_emp_id         VARCHAR2,
		p_num_of_aff_rows    OUT   NUMBER
	) IS
		v_cnt              NUMBER := 0;
		rec_bil_root       bil_root%rowtype;
		rec_bil_debt_rec   bil_debt_rec%rowtype;
	BEGIN
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			bil_debt_rec
		WHERE
			caseno = p_caseno;
		IF v_cnt = 0 THEN
			SELECT
				*
			INTO rec_bil_root
			FROM
				bil_root
			WHERE
				caseno = p_caseno;
			INSERT INTO bil_debt_rec (
				caseno,
				hpatnum,
				dischg_date,
				total_self_amt,
				total_paid_amt,
				total_disc_amt,
				debt_amt,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				check_no,
				change_flag,
				display_flag
			) VALUES (
				rec_bil_root.caseno,
				rec_bil_root.hpatnum,
				rec_bil_root.dischg_date,
				service_bill_pkg.get_adm_total_payable_amt (p_caseno, 'CIVC'),
				service_bill_pkg.get_adm_total_prepaid_amt (p_caseno, 'CIVC'),
				service_bill_pkg.get_adm_total_contract_amt (p_caseno),
				service_bill_pkg.get_adm_owed_amt (p_caseno, 'CIVC'),
				SYSDATE,
				p_opr_emp_id,
				SYSDATE,
				p_opr_emp_id,
				(
					SELECT
						check_no
					FROM
						bil_check_bill
					WHERE
						caseno = p_caseno
						AND
						status = 'N'
				),
				'N',
				'Y'
			);
		ELSE
			SELECT
				*
			INTO rec_bil_debt_rec
			FROM
				bil_debt_rec
			WHERE
				caseno = p_caseno;
			INSERT INTO bil_debt_rec_log (
				caseno,
				hpatnum,
				dischg_date,
				total_self_amt,
				total_paid_amt,
				total_disc_amt,
				debt_amt,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				check_no,
				change_flag,
				backup_date
			)
				(SELECT
					caseno,
					hpatnum,
					dischg_date,
					total_self_amt,
					total_paid_amt,
					total_disc_amt,
					debt_amt,
					creation_date,
					created_by,
					last_update_date,
					last_updated_by,
					check_no,
					change_flag,
					SYSDATE
				FROM
					bil_debt_rec
				WHERE
					caseno = p_caseno
				);
			UPDATE bil_debt_rec
			SET
				change_flag =
					CASE
						WHEN p_change_flag IS NULL THEN
							'N'
						ELSE
							p_change_flag
					END,
				overdue_date = p_overdue_date,
				baddebt_date = p_baddebt_date,
				baddebt_document = p_baddebt_document,
				display_flag = p_display_flag,
				last_update_date = SYSDATE,
				last_updated_by = p_opr_emp_id
			WHERE
				caseno = p_caseno;
		END IF;
		p_num_of_aff_rows := SQL%rowcount;
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (sqlcode || ': ' || sqlerrm);
	END;
	PROCEDURE ins_upd_bil_check_bill (
		p_caseno            IN    VARCHAR2,
		p_check_no          IN    VARCHAR2,
		p_bill_kind         IN    VARCHAR2,
		p_bill_amt          IN    NUMBER,
		p_bank_name         IN    VARCHAR2,
		p_accountno         IN    VARCHAR2,
		p_bill_date         IN    DATE,
		p_due_date          IN    DATE,
		p_pay_date          IN    DATE,
		p_return_date       IN    DATE,
		p_status            IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_note              IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		UPDATE bil_check_bill
		SET
			status = 'R',
			return_date = SYSDATE
		WHERE
			status = 'N'
			AND
			caseno = p_caseno;
		MERGE INTO bil_check_bill
		USING dual ON (caseno = p_caseno
		               AND
		               check_no = p_check_no)
		WHEN NOT MATCHED THEN
		INSERT (
			hpatnum,
			bill_kind,
			check_no,
			bank_name,
			bill_date,
			due_date,
			accountno,
			bill_amt,
			created_by,
			createion_date,
			last_updated_by,
			last_update_date,
			return_date,
			pay_date,
			status,
			caseno,
			handler,
			note)
		VALUES
			((
				SELECT
					hhisnum
				FROM
					common.pat_adm_case
				WHERE
					hcaseno = p_caseno
			),
			p_bill_kind,
			p_check_no,
			p_bank_name,
			p_bill_date,
			p_due_date,
			p_accountno,
			p_bill_amt,
			p_operator_emp_id,
			SYSDATE,
			p_operator_emp_id,
			SYSDATE,
			p_return_date,
			p_pay_date,
			p_status,
			p_caseno,
			p_handler,
			p_note)
		WHEN MATCHED THEN UPDATE
		SET bill_kind = p_bill_kind,
		    bank_name = p_bank_name,
		    bill_date = p_bill_date,
		    due_date = p_due_date,
		    accountno = p_accountno,
		    bill_amt = p_bill_amt,
		    last_updated_by = p_operator_emp_id,
		    last_update_date = SYSDATE,
		    return_date = p_return_date,
		    pay_date = p_pay_date,
		    status = p_status,
		    handler = p_handler,
		    note = p_note;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE ins_upd_emg_bil_check_bill (
		p_caseno            IN    VARCHAR2,
		p_check_no          IN    VARCHAR2,
		p_bill_kind         IN    VARCHAR2,
		p_bill_amt          IN    NUMBER,
		p_bank_name         IN    VARCHAR2,
		p_accountno         IN    VARCHAR2,
		p_bill_date         IN    DATE,
		p_due_date          IN    DATE,
		p_pay_date          IN    DATE,
		p_return_date       IN    DATE,
		p_status            IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_handler           IN    VARCHAR2,
		p_note              IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		UPDATE emg_bil_check_bill
		SET
			status = 'R',
			return_date = SYSDATE
		WHERE
			status = 'N'
			AND
			caseno = p_caseno;
		MERGE INTO emg_bil_check_bill
		USING dual ON (caseno = p_caseno
		               AND
		               check_no = p_check_no)
		WHEN NOT MATCHED THEN
		INSERT (
			hpatnum,
			bill_kind,
			check_no,
			bank_name,
			bill_date,
			due_date,
			accountno,
			bill_amt,
			created_by,
			created_date,
			last_updated_by,
			last_update_date,
			return_date,
			pay_date,
			status,
			caseno,
			handler,
			note)
		VALUES
			((
				SELECT
					emghhist
				FROM
					common.pat_emg_casen
				WHERE
					ecaseno = p_caseno
			),
			p_bill_kind,
			p_check_no,
			p_bank_name,
			p_bill_date,
			p_due_date,
			p_accountno,
			p_bill_amt,
			p_operator_emp_id,
			SYSDATE,
			p_operator_emp_id,
			SYSDATE,
			p_return_date,
			p_pay_date,
			p_status,
			p_caseno,
			p_handler,
			p_note)
		WHEN MATCHED THEN UPDATE
		SET bill_kind = p_bill_kind,
		    bank_name = p_bank_name,
		    bill_date = p_bill_date,
		    due_date = p_due_date,
		    accountno = p_accountno,
		    bill_amt = p_bill_amt,
		    last_updated_by = p_operator_emp_id,
		    last_update_date = SYSDATE,
		    return_date = p_return_date,
		    pay_date = p_pay_date,
		    status = p_status,
		    handler = p_handler,
		    note = p_note;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE ins_upd_bil_critical_mst (
		p_hhisnum           IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) AS
	BEGIN
		MERGE INTO bil_critical_mst
		USING dual ON (copayid = service_bill_pkg.get_pat_nat_no (p_hhisnum))
		WHEN NOT MATCHED THEN
		INSERT (
			copayid,
			copayiid,
			copayidt,
			copaymid,
			copaymdt)
		VALUES
			(service_bill_pkg.get_pat_nat_no (p_hhisnum),
			p_operator_emp_id,
			SYSDATE,
			p_operator_emp_id,
			SYSDATE)
		WHEN MATCHED THEN UPDATE
		SET copaymid = p_operator_emp_id,
		    copaymdt = SYSDATE;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE ins_upd_bil_critical_dtl (
		p_hhisnum           IN    VARCHAR2,
		p_copayno           IN    VARCHAR2,
		p_copayicd          IN    VARCHAR2,
		p_copaybdt          IN    DATE,
		p_copayedt          IN    DATE,
		p_operator_emp_id   IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) AS
	BEGIN
		MERGE INTO bil_critical_dtl
		USING dual ON (copayid = service_bill_pkg.get_pat_nat_no (p_hhisnum)
		               AND
		               copayicd = p_copayicd
		               AND
		               copaybdt = p_copaybdt
		               AND
		               copayedt = p_copayedt)
		WHEN NOT MATCHED THEN
		INSERT (
			copayid,
			copayno,
			copayicd,
			copaynam,
			copaybdt,
			copayedt,
			copayiid,
			copayidt,
			copaymid,
			copaymdt,
			copstatus)
		VALUES
			(service_bill_pkg.get_pat_nat_no (p_hhisnum),
			p_copayno,
			p_copayicd,
			service_bill_pkg.get_icd_name (p_copayicd, 'CH'),
			p_copaybdt,
			p_copayedt,
			p_operator_emp_id,
			SYSDATE,
			p_operator_emp_id,
			SYSDATE,
			'Y')
		WHEN MATCHED THEN UPDATE
		SET copayno = p_copayno,
		    copaymid = p_operator_emp_id,
		    copaymdt = SYSDATE;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_bil_check_bill (
		p_caseno            IN    VARCHAR2,
		p_check_no          IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		DELETE FROM bil_check_bill
		WHERE
			caseno = p_caseno
			AND
			check_no = p_check_no;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_emg_bil_check_bill (
		p_caseno            IN    VARCHAR2,
		p_check_no          IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		DELETE FROM emg_bil_check_bill
		WHERE
			caseno = p_caseno
			AND
			check_no = p_check_no;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_bil_critical_dtl (
		p_hhisnum           IN    VARCHAR2,
		p_copayicd          IN    VARCHAR2,
		p_copaybdt          IN    DATE,
		p_copayedt          IN    DATE,
		p_num_of_aff_rows   OUT   NUMBER
	) AS
	BEGIN
		DELETE FROM bil_critical_dtl
		WHERE
			copayid = service_bill_pkg.get_pat_nat_no (p_hhisnum)
			AND
			copayicd = p_copayicd
			AND
			copaybdt = p_copaybdt
			AND
			copayedt = p_copayedt;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE get_vtan_subsidy_list (
		p_idno     IN    VARCHAR2,
		p_cursor   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  copaycode,
			                  seqno,
			                  namec,
			                  birthday_tw,
			                  idno,
			                  begindate_tw,
			                  enddate_tw,
			                  lastupdatetime,
			                  TO_DATE (begindate, 'YYYYMMDD') AS begindate,
			                  TO_DATE (enddate, 'YYYYMMDD') - 1 AS enddate,
			                  subsidytype,
			                  cancelyn,
			                  TO_DATE (canceldatetime, 'YYYYMMDDHH24MISS') AS canceldatetime,
			                  cancelid,
			                  cancelnmc,
			                  cancelcard,
			                  TO_DATE (procdatetime, 'YYYYMMDDHH24MISS') AS procdatetime,
			                  procid,
			                  procnmc,
			                  proccard,
			                  to_date_safe (createdatetime, 'YYYYMMDDHH24MISS') AS createdatetime,
			                  createid,
			                  createnmc,
			                  createcard,
			                  service_bill_pkg.get_code_desc ('CopayCodeContractNoMap', copaycode) AS contract_no
		                  FROM
			                  common.vtan_subsidy
		                  WHERE
			                  idno = p_idno
		                  ORDER BY
			                  copaycode;
	END;
	PROCEDURE apply_adm_vtan_subsidy (
		p_caseno    IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	) IS
		TYPE t_rec IS RECORD (
			hhisnum       common.pat_adm_case.hhisnum%TYPE,
			hadmdt        common.pat_adm_case.hadmdt%TYPE,
			hdisdate      common.pat_adm_discharge.hdisdate%TYPE,
			copaycode     common.vtan_subsidy.copaycode%TYPE,
			contract_no   bil_codedtl.code_desc%TYPE,
			begindate     common.vtan_subsidy.begindate%TYPE,
			enddate       common.vtan_subsidy.enddate%TYPE
		);
		TYPE cursor_type IS REF CURSOR RETURN t_rec;
		v_cursor            cursor_type;
		v_rec               t_rec;
		v_num_of_aff_rows   NUMBER := 0;
	BEGIN
		p_out_msg := '0';
		OPEN v_cursor FOR SELECT
			                  pat_adm_case.hhisnum,
			                  pat_adm_case.hadmdt,
			                  pat_adm_discharge.hdisdate,
			                  vtan_subsidy.copaycode,
			                  service_bill_pkg.get_code_desc ('CopayCodeContractNoMap', vtan_subsidy.copaycode) AS contract_no,
			                  vtan_subsidy.begindate,
			                  vtan_subsidy.enddate
		                  FROM
			                  common.pat_adm_case left
			                  JOIN common.pat_adm_discharge ON pat_adm_case.hcaseno = pat_adm_discharge.hcaseno
			                  LEFT JOIN common.pat_basic ON pat_basic.hhisnum = pat_adm_case.hhisnum
			                  LEFT JOIN common.vtan_subsidy ON vtan_subsidy.idno = pat_basic.hidno
		                  WHERE
			                  pat_adm_discharge.hdisstat = 'I'
			                  AND
			                  pat_adm_case.hcaseno = p_caseno
		                  ORDER BY
			                  vtan_subsidy.copaycode,
			                  pat_adm_discharge.hdisperd DESC,
			                  pat_adm_discharge.hdispert DESC;
		FETCH v_cursor INTO v_rec;
		CLOSE v_cursor;
		IF v_rec.hdisdate BETWEEN v_rec.begindate AND v_rec.enddate THEN
			service_bill_pkg.ins_upd_bil_contr (v_rec.hhisnum, p_caseno, v_rec.contract_no, TO_DATE (v_rec.hadmdt, 'YYYYMMDD'), TO_DATE (v_rec
			.hdisdate, 'YYYYMMDD'), 'Inform', 'N', v_num_of_aff_rows);
			IF v_num_of_aff_rows > 0 THEN
				p_out_msg := '0';
			ELSE
				p_out_msg := '1';
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_out_msg := '1';
	END;
	PROCEDURE apply_emg_vtan_subsidy (
		p_ecaseno   IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	) IS
		rec_pat_emg_casen       common.pat_emg_casen%rowtype;
		rec_pat_baisc           common.pat_basic%rowtype;
		rec_vtan_subsidy        common.vtan_subsidy%rowtype;
		rec_pat_emg_discharge   common.pat_emg_discharge%rowtype;
		CURSOR cur_vtan_subsidy (
			p_idno VARCHAR2
		) IS
		SELECT
			*
		FROM
			common.vtan_subsidy
		WHERE
			idno = p_idno
		ORDER BY
			copaycode;
		CURSOR cur_pat_emg_discharge (
			p_ecaseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			common.pat_emg_discharge
		WHERE
			edisstat = 'I'
			AND
			ecaseno = p_ecaseno
		ORDER BY
			edisopdt DESC;
	BEGIN
		p_out_msg := '0';
		SELECT
			*
		INTO rec_pat_emg_casen
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = p_ecaseno;
		SELECT
			*
		INTO rec_pat_baisc
		FROM
			common.pat_basic
		WHERE
			hhisnum = rec_pat_emg_casen.emghhist;
		OPEN cur_vtan_subsidy (rec_pat_baisc.hidno);
		FETCH cur_vtan_subsidy INTO rec_vtan_subsidy;
		IF cur_vtan_subsidy%found THEN
			OPEN cur_pat_emg_discharge (rec_pat_emg_casen.ecaseno);
			FETCH cur_pat_emg_discharge INTO rec_pat_emg_discharge;
			IF cur_pat_emg_discharge%found THEN
				IF rec_pat_emg_discharge.edisdt BETWEEN to_date_safe (rec_vtan_subsidy.begindate, 'YYYYMMDD') AND to_date_safe (rec_vtan_subsidy
				.enddate, 'YYYYMMDD') - 1 THEN
					UPDATE common.pat_emg_casen
					SET
						emg2fncl = 'G',
						emgspeu1 = service_bill_pkg.get_code_desc ('CopayCodeContractNoMap', rec_vtan_subsidy.copaycode)
					WHERE
						ecaseno = rec_pat_emg_casen.ecaseno;
					IF SQL%rowcount > 0 THEN
						p_out_msg := '0';
					ELSE
						p_out_msg := '1';
					END IF;
					IF rec_pat_emg_casen.emg1fncl = '7' AND rec_pat_emg_casen.emgcopay IN (
						'A00',
						'E00'
					) THEN
						UPDATE common.pat_emg_casen
						SET
							emgcopay = rec_vtan_subsidy.copaycode
						WHERE
							ecaseno = rec_pat_emg_casen.ecaseno;
						IF SQL%rowcount > 0 THEN
							p_out_msg := '0';
						ELSE
							p_out_msg := '1';
						END IF;
					END IF;
				END IF;
			END IF;
			CLOSE cur_pat_emg_discharge;
		END IF;
		CLOSE cur_vtan_subsidy;
		COMMIT;
	END;
	PROCEDURE get_bil_billdtl_list (
		p_bil_seqno   IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  fee_type,
			                  service_bill_pkg.get_code_desc ('PFTYPE', fee_type) AS fee_type_desc,
			                  unitcode,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = unitcode
					                  AND
					                  ROWNUM = 1
			                  ) AS unitcode_desc,
			                  total_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  creation_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_updateion_date
		                  FROM
			                  bil_billdtl
		                  WHERE
			                  bil_seqno = p_bil_seqno;
	END;
	PROCEDURE get_emg_bil_billdtl_list (
		p_emg_bil_seqno   IN    VARCHAR2,
		p_cursor          OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  fee_type,
			                  service_bill_pkg.get_code_desc ('PFTYPE', fee_type) AS fee_type_desc,
			                  unitcode,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = unitcode
					                  AND
					                  ROWNUM = 1
			                  ) AS unitcode_desc,
			                  total_amt,
			                  created_by,
			                  service_bill_pkg.get_emp_name_ch (created_by) AS created_emp_name,
			                  created_date,
			                  last_updated_by,
			                  service_bill_pkg.get_emp_name_ch (last_updated_by) AS last_updated_emp_name,
			                  last_updateion_date,
			                  act_status
		                  FROM
			                  emg_bil_billdtl
		                  WHERE
			                  emg_bil_seqno = p_emg_bil_seqno;
	END;
	PROCEDURE ins_upd_pat_adm_financial (
		p_hcaseno           IN    VARCHAR2,
		p_hfinancl          IN    VARCHAR2,
		p_hfindate          IN    DATE,
		p_hfinuser          IN    VARCHAR2,
		p_hnhi1typ          IN    VARCHAR2,
		p_hcard             IN    VARCHAR2,
		p_hpaytype          IN    VARCHAR2,
		p_htraffic          IN    VARCHAR2,
		p_hcvadt            IN    DATE,
		p_hcardic           IN    VARCHAR2,
		p_hfininf_bil       IN    DATE,
		p_hnhi1end          IN    DATE,
		p_hfincl2           IN    VARCHAR2,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
		CURSOR cur_pat_adm_financial (
			p_caseno IN VARCHAR2
		) IS
		SELECT
			*
		FROM
			common.pat_adm_financial
		WHERE
			hcaseno = p_caseno
		ORDER BY
			hfindate DESC,
			hfininf DESC;
		rec_pat_adm_financial common.pat_adm_financial%rowtype;
	BEGIN
		OPEN cur_pat_adm_financial (p_hcaseno);
		FETCH cur_pat_adm_financial INTO rec_pat_adm_financial;
		CLOSE cur_pat_adm_financial;
		MERGE INTO common.pat_adm_financial
		USING dual ON (hcaseno = p_hcaseno
		               AND
		               hfindate = TO_CHAR (p_hfindate, 'YYYYMMDD')
		               AND
		               hfininf = TO_CHAR (SYSDATE, 'YYYYMMDD'))
		WHEN NOT MATCHED THEN
		INSERT (
			hcaseno,
			hfinancl,
			hfindate,
			hfininf,
			hfinuser,
			hnhi1typ,
			hcard,
			hpaytype,
			htraffic,
			hcvadt,
			ins_date,
			hcardic,
			hfininf_bil,
			hnhi1end,
			hfincl2)
		VALUES
			(p_hcaseno,
			 p_hfinancl,
			TO_CHAR (p_hfindate, 'YYYYMMDD'),
			TO_CHAR (SYSDATE, 'YYYYMMDD'),
			 p_hfinuser,
			nvl (p_hnhi1typ, rec_pat_adm_financial.hnhi1typ),
			nvl (p_hcard, rec_pat_adm_financial.hcard),
			nvl (p_hpaytype, rec_pat_adm_financial.hpaytype),
			nvl (p_htraffic, rec_pat_adm_financial.htraffic),
			nvl (TO_CHAR (p_hcvadt, 'YYYYMMDD'), rec_pat_adm_financial.hcvadt),
			 SYSDATE,
			nvl (p_hcardic, rec_pat_adm_financial.hcardic),
			nvl (TO_CHAR (p_hfininf_bil, 'YYYYMMDD'), rec_pat_adm_financial.hfininf_bil),
			nvl (TO_CHAR (p_hnhi1end, 'YYYYMMDD'), rec_pat_adm_financial.hnhi1end),
			nvl (p_hfincl2, rec_pat_adm_financial.hfincl2))
		WHEN MATCHED THEN UPDATE
		SET hfinancl = p_hfinancl,
		    hfinuser = p_hfinuser;
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE del_pat_adm_financial (
		p_hcaseno           IN    VARCHAR2,
		p_hfinancl          IN    VARCHAR2,
		p_hfindate          IN    DATE,
		p_num_of_aff_rows   OUT   NUMBER
	) IS
	BEGIN
		DELETE FROM common.pat_adm_financial
		WHERE
			hcaseno = p_hcaseno
			AND
			hfinancl = p_hfinancl
			AND
			hfindate = TO_CHAR (p_hfindate, 'YYYYMMDD');
		p_num_of_aff_rows := SQL%rowcount;
	END;
	PROCEDURE get_bil_feedtl_list (
		p_caseno     IN    VARCHAR2,
		p_pfincode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  fee_type,
			                  service_bill_pkg.get_code_desc ('PFTYPE', fee_type) AS fee_type_desc,
			                  pfincode,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = pfincode
					                  AND
					                  ROWNUM = 1
			                  ) AS pfincode_desc,
			                  total_amt,
			                  created_by,
			                  creation_date,
			                  last_updated_by,
			                  last_update_date
		                  FROM
			                  bil_feedtl
		                  WHERE
			                  caseno = p_caseno
			                  AND
			                  ((p_pfincode IS NULL)
			                   OR
			                   (p_pfincode IS NOT NULL
			                    AND
			                    pfincode = p_pfincode))
		                  ORDER BY
			                  fee_type,
			                  CASE
					                  WHEN pfincode = 'LABI' THEN
						                  1
					                  WHEN pfincode = 'CIVC' THEN
						                  2
					                  ELSE
						                  3
				                  END,
			                  pfincode;
	END;
	PROCEDURE get_emg_bil_feedtl_list (
		p_caseno     IN    VARCHAR2,
		p_pfincode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  fee_type,
			                  service_bill_pkg.get_code_desc ('PFTYPE', fee_type) AS fee_type_desc,
			                  pfincode,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = pfincode
					                  AND
					                  ROWNUM = 1
			                  ) AS pfincode_desc,
			                  total_amt,
			                  created_by,
			                  created_date,
			                  last_updated_by,
			                  last_update_date
		                  FROM
			                  emg_bil_feedtl
		                  WHERE
			                  caseno = p_caseno
			                  AND
			                  ((p_pfincode IS NULL)
			                   OR
			                   (p_pfincode IS NOT NULL
			                    AND
			                    pfincode = p_pfincode))
		                  ORDER BY
			                  fee_type,
			                  pfincode;
	END;
	PROCEDURE get_deposit_charge_list (
		p_hhisnum   IN    VARCHAR2,
		p_cursor    OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  opdcash.hhisnum,
			                  opdcash.opdcaseno,
			                  opdcash.billrecno,
			                  opdordf.feetype,
			                  service_bill_pkg.get_code_desc ('PFTYPE', opdordf.feetype) AS feetype_desc,
			                  opdordf.payamount,
			                  opdcash.createcard,
			                  opdcash.createnmc,
			                  TO_DATE (substr (opdcash.createdatetime, 1, 8), 'YYYY-MM-DD') AS create_date,
			                  CASE
				                  WHEN opdcash.creditcardpayseq IS NOT NULL THEN
					                  '信用卡'
				                  ELSE
					                  '現金'
			                  END AS paid_type_desc,
			                  opdcash.cancelyn,
			                  TO_DATE (substr (opdcash.canceldatetime, 1, 8), 'YYYY-MM-DD') AS refund_date,
			                  opdcash.cancelcard,
			                  opdcash.cancelnmc,
			                  CASE
				                  WHEN opdcash.cancelyn = 'Y' THEN
					                  (
						                  CASE
							                  WHEN opdcash.creditcardbackseq IS NOT NULL THEN
								                  '信用卡'
							                  ELSE
								                  '現金'
						                  END
					                  )
				                  ELSE
					                  ''
			                  END AS refund_type_desc
		                  FROM
			                  opdusr.opdcash left
			                  JOIN opdusr.opdroot ON (opdcash.opdcaseno = opdroot.opdcaseno)
			                  LEFT JOIN opdusr.opdblbm ON (opdcash.opdcaseno = opdblbm.opdcaseno
			                                               AND
			                                               opdcash.billrecno = opdblbm.billrecno)
			                  LEFT JOIN opdusr.opdordf ON (opdcash.opdcaseno = opdordf.opdcaseno
			                                               AND
			                                               opdblbm.feerecno = opdordf.feerecno)
		                  WHERE
			                  opdcash.hhisnum = p_hhisnum
			                  AND
			                  opdroot.opdfrom = '3'
			                  AND
			                  opdordf.feetype IN (
				                  '65',
				                  '66',
				                  '69'
			                  )
			                  AND
			                  opdordf.payamount != 0
		                  UNION ALL
		                  SELECT
			                  opdcash.hhisnum,
			                  opdcash.opdcaseno,
			                  opdcash.billrecno,
			                  logordf.feetype,
			                  service_bill_pkg.get_code_desc ('PFTYPE', logordf.feetype) AS feetype_desc,
			                  logordf.payamount,
			                  opdcash.createcard,
			                  opdcash.createnmc,
			                  TO_DATE (substr (opdcash.createdatetime, 1, 8), 'YYYY-MM-DD') AS create_date,
			                  CASE
				                  WHEN opdcash.creditcardpayseq IS NOT NULL THEN
					                  '信用卡'
				                  ELSE
					                  '現金'
			                  END AS paid_type_desc,
			                  opdcash.cancelyn,
			                  TO_DATE (substr (opdcash.canceldatetime, 1, 8), 'YYYY-MM-DD') AS refund_date,
			                  opdcash.cancelcard,
			                  opdcash.cancelnmc,
			                  CASE
				                  WHEN opdcash.cancelyn = 'Y' THEN
					                  (
						                  CASE
							                  WHEN opdcash.creditcardbackseq IS NOT NULL THEN
								                  '信用卡'
							                  ELSE
								                  '現金'
						                  END
					                  )
				                  ELSE
					                  ''
			                  END AS refund_type_desc
		                  FROM
			                  opdusr.opdcash left
			                  JOIN opdusr.opdroot ON (opdcash.opdcaseno = opdroot.opdcaseno)
			                  LEFT JOIN opdusr.opdblbm ON (opdcash.opdcaseno = opdblbm.opdcaseno
			                                               AND
			                                               opdcash.billrecno = opdblbm.billrecno)
			                  LEFT JOIN opdusr.logordf ON (opdcash.opdcaseno = logordf.opdcaseno
			                                               AND
			                                               opdblbm.feerecno = logordf.feerecno)
		                  WHERE
			                  opdcash.hhisnum = p_hhisnum
			                  AND
			                  opdroot.opdfrom = '3'
			                  AND
			                  opdcash.cancelyn = 'Y'
			                  AND
			                  logordf.feetype IS NOT NULL
			                  AND
			                  logordf.feetype IN (
				                  '65',
				                  '66',
				                  '69'
			                  )
			                  AND
			                  logordf.payamount != 0
			                  AND
			                  opdcash.creditcardpayseq IS NULL
		                  ORDER BY
			                  feetype,
			                  create_date;
	END;
	PROCEDURE get_emg_occur_list (
		i_caseno       IN    VARCHAR2,
		o_sys_refcur   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN o_sys_refcur FOR SELECT
			                      emblpk,
			                      caseno,
			                      emocdate,
			                      ordseq,
			                      emchcode,
			                      emchrgcr,
			                      embldate,
			                      emchtyp1,
			                      emchqty1,
			                      emchamt1,
			                      emchtyp2,
			                      emchqty2,
			                      emchamt2,
			                      emchtyp3,
			                      emchqty3,
			                      emchamt3,
			                      emchtyp4,
			                      emchqty4,
			                      emchamt4,
			                      emgcrat,
			                      emgerat,
			                      emchidep,
			                      emchemg,
			                      emchanes,
			                      emrescod,
			                      emchstat,
			                      emuserid,
			                      emorcat,
			                      emorcomp,
			                      emororno,
			                      empayfg,
			                      emocomb,
			                      emocdist,
			                      emocsect,
			                      emdgstus,
			                      emocns,
			                      emoedept,
			                      emochadp,
			                      card_no,
			                      hisdttm,
			                      hisst,
			                      hismsg,
			                      emgpay,
			                      emgorse1,
			                      emapply
		                      FROM
			                      cpoe.emg_occur
		                      WHERE
			                      caseno = i_caseno;
	END;
END service_bill_pkg;

/
