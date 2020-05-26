CREATE OR REPLACE PACKAGE "SERVICE_BILL_REPORT_PKG" AS
	FUNCTION get_report_acct_seq (
		p_report_id     VARCHAR2,
		p_report_date   DATE
	) RETURN VARCHAR2;
	FUNCTION check_has_been_bad_debt (
		p_case_type   VARCHAR2,
		p_caseno      VARCHAR2
	) RETURN VARCHAR2;
	PROCEDURE get_mail_report (
		p_report_id   IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	);
	PROCEDURE get_mail_report_recipient_list (
		p_report_id   IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	);
	PROCEDURE get_contract_adm_case_no (
		p_bilcunit            IN    VARCHAR2,
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_contract_fee_dtl_list (
		p_caseno     IN    VARCHAR2,
		p_pfincode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_cashier_cash_dtl_list (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_cashier_epay_dtl_list (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_pat_kind            IN    VARCHAR2,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_acct_code_list (
		i_visit_type   IN    VARCHAR2,
		o_sys_refcur   OUT   SYS_REFCURSOR
	);
	PROCEDURE get_charged_item_dtl_list (
		p_start_dischg_date   DATE,
		p_end_dischg_date     DATE,
		p_fee_kind            IN    VARCHAR2,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_fastreport_list (
		p_irf_form_no   IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	);
	PROCEDURE get_njob_vtan_meal_subsidy (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_njob_vtan_ward_subsidy (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_njob_vtan_meterial_subsidy (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_njob_vtan_all_subsidy (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_yjob_vtan_subsidy_list (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_njob_vtan_subsidy_list (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
    PROCEDURE get_vtan_payment_summary (
        p_start_dischg_date   IN DATE,
        p_end_dischg_date     IN DATE,
        p_cursor              OUT SYS_REFCURSOR
    );
    PROCEDURE get_vtan_payment_detail (
        p_start_dischg_date   IN DATE,
        p_end_dischg_date     IN DATE,
        p_cursor              OUT SYS_REFCURSOR
    );
	PROCEDURE get_adm_med_income_list (
		p_start_report_date   IN    DATE,
		p_end_report_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_med_nor_deduct_list (
		p_start_report_date   IN    DATE,
		p_end_report_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_med_income_list (
		p_start_report_date   IN    DATE,
		p_end_report_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_med_nor_deduct_list (
		p_start_report_date   IN    DATE,
		p_end_report_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_cert_income_list (
		p_start_chargedate   IN    DATE,
		p_end_chargedate     IN    DATE,
		p_cursor             OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_cert_income_list (
		p_start_create_time   IN    DATE,
		p_end_create_time     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_adm_med_spc_ded_dtl_list (
		p_start_creation_date   IN    DATE,
		p_end_creation_date     IN    DATE,
		p_cursor                OUT   SYS_REFCURSOR
	);
	PROCEDURE get_emg_med_spc_ded_dtl_list (
		p_start_created_date   IN    DATE,
		p_end_created_date     IN    DATE,
		p_cursor               OUT   SYS_REFCURSOR
	);
	PROCEDURE get_dea_notify_cert_no_list (
		p_notify_date   IN    DATE,
		p_cursor        OUT   SYS_REFCURSOR
	);
	PROCEDURE get_amb_cashier_dtl_list (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
	PROCEDURE get_amb_acct_info_list (
		p_cursor OUT SYS_REFCURSOR
	);

		-- 住院現金明細
	PROCEDURE get_adm_cash_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);

	-- 住院電子交易明細
	PROCEDURE get_adm_epay_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);

	-- 急診現金明細
	PROCEDURE get_emg_cash_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);

	-- 急診電子交易明細
	PROCEDURE get_emg_epay_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);

	-- 急診證明書現金明細
	PROCEDURE get_emg_cert_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	);
END service_bill_report_pkg;
/


CREATE OR REPLACE PACKAGE BODY "SERVICE_BILL_REPORT_PKG" AS
	FUNCTION get_report_acct_seq (
		p_report_id     VARCHAR2,
		p_report_date   DATE
	) RETURN VARCHAR2 IS
		report_acct_seq        VARCHAR2 (20);
		v_acct_seq_report_id   emg_bil_accountnum.report_id%TYPE;
	BEGIN
		IF p_report_id = 'AdmDailyCashSummaryReport' THEN
			SELECT
				accountseqno
			INTO report_acct_seq
			FROM
				bil_cashdailysta
			WHERE
				trunc (bil_date) = trunc (p_report_date);
		ELSIF p_report_id = 'AdmMonthlyMedIncomeReport' THEN
			SELECT
				connectseqno
			INTO report_acct_seq
			FROM
				bil_incommonthmst
			WHERE
				bil_month = TO_CHAR (p_report_date, 'YYYYMM');
		ELSIF p_report_id = 'EmgMonthlyMedIncomeReport' THEN
			SELECT
				connectseqno
			INTO report_acct_seq
			FROM
				emg_incommonthmst
			WHERE
				bil_month = TO_CHAR (p_report_date, 'YYYYMM');
		ELSIF p_report_id = 'AdmMonthlyMedSpecialDeductSummaryReport' THEN
			SELECT
				inhconnectseqno_v
			INTO report_acct_seq
			FROM
				bil_incommonthmst
			WHERE
				bil_month = TO_CHAR (p_report_date, 'YYYYMM');
		ELSIF p_report_id = 'EmgMonthlyMedSpecialDeductSummaryReport' THEN
			SELECT
				inhconnectseqno_v
			INTO report_acct_seq
			FROM
				emg_incommonthmst
			WHERE
				bil_month = TO_CHAR (p_report_date, 'YYYYMM');
		ELSE
			IF p_report_id = 'AdmDailyEpaySummaryReport' OR p_report_id IN (
				'AdmDailyEpaySummaryReport1',
				'AdmDailyEpaySummaryReport2'
			) THEN
				v_acct_seq_report_id := 'bil_elctronic';
			ELSIF p_report_id = 'AdmMonthlyCertIncomeReport' THEN
				v_acct_seq_report_id := 'bil_abs_account';
			ELSIF p_report_id = 'EmgMonthlyCertIncomeReport' THEN
				v_acct_seq_report_id := 'abs_income';
			END IF;
			SELECT
				account_num
			INTO report_acct_seq
			FROM
				emg_bil_accountnum
			WHERE
				report_id = v_acct_seq_report_id
				AND
				trunc (begin_date) = trunc (p_report_date);
		END IF;
		RETURN report_acct_seq;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN report_acct_seq;
	END;
	FUNCTION check_has_been_bad_debt (
		p_case_type   VARCHAR2,
		p_caseno      VARCHAR2
	) RETURN VARCHAR2 IS
		has_been_bad_debt_flag VARCHAR2 (1) := 'N';
	BEGIN
		IF p_case_type = 'A' THEN
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
		ELSIF p_case_type = 'E' THEN
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
						emg_bil_debt_rec
					WHERE
						caseno = p_caseno
						AND
						change_flag = 'O'
					UNION
					SELECT
						caseno
					FROM
						emg_bil_debt_rec_hist
					WHERE
						caseno = p_caseno
						AND
						change_flag = 'O'
				);
		END IF;
		RETURN has_been_bad_debt_flag;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN has_been_bad_debt_flag;
	END;
	PROCEDURE get_mail_report (
		p_report_id   IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	) AS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  report_id,
			                  report_desc,
			                  enabled,
			                  send_days
		                  FROM
			                  bill_report
		                  WHERE
			                  report_id = p_report_id
			                  AND
			                  enabled = 'Y';
	END;
	PROCEDURE get_mail_report_recipient_list (
		p_report_id   IN    VARCHAR2,
		p_cursor      OUT   SYS_REFCURSOR
	) AS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  bill_report_recipient.recipient_mail,
			                  psbasic_vghtc.cardno,
			                  psbasic_vghtc.namec,
			                  psbasic_vghtc.deptno,
			                  service_bill_pkg.get_code_desc ('Dept', deptno) AS dept_desc
		                  FROM
			                  bill_report_recipient left
			                  JOIN common.psbasic_vghtc ON substr (bill_report_recipient.recipient_mail, 1, instr (bill_report_recipient.recipient_mail
			                  , '@') - 1) = psbasic_vghtc.email
		                  WHERE
			                  (psbasic_vghtc.pslvflag IS NULL
			                   OR
			                   psbasic_vghtc.pslvflag != 'Y')
			                  AND
			                  bill_report_recipient.enabled = 'Y'
			                  AND
			                  bill_report_recipient.report_id = p_report_id
		                  ORDER BY
			                  recipient_mail;
	END;
	PROCEDURE get_contract_adm_case_no (
		p_bilcunit            IN    VARCHAR2,
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) AS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  bil_root.caseno
		                  FROM
			                  bil_root
			                  INNER JOIN bil_contr ON bil_root.caseno = bil_contr.caseno
		                  WHERE
			                  bilcunit = p_bilcunit
			                  AND
			                  trunc (dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date);
	END;
	PROCEDURE get_contract_fee_dtl_list (
		p_caseno     IN    VARCHAR2,
		p_pfincode   IN    VARCHAR2,
		p_cursor     OUT   SYS_REFCURSOR
	) AS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.fee_type,
			                  service_bill_pkg.get_code_desc ('PFTYPE', t1.fee_type) AS fee_type_desc,
			                  service_bill_pkg.get_code_desc ('PFETYPE', t1.fee_type) AS fee_type_eng_desc,
			                  nvl (t2.total_amt, 0) AS nhi_amt,
			                  nvl (t3.total_amt, 0) AS self_amt,
			                  nvl (t4.total_amt, 0) AS contract_amt,
			                  nvl (t5.sum_total_amt, 0) AS fee_type_amt
		                  FROM
			                  (
				                  SELECT DISTINCT
					                  fee_type
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  caseno = p_caseno
			                  ) t1
			                  LEFT JOIN (
				                  SELECT
					                  fee_type,
					                  total_amt
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  pfincode = 'LABI'
					                  AND
					                  caseno = p_caseno
			                  ) t2 ON t1.fee_type = t2.fee_type
			                  LEFT JOIN (
				                  SELECT
					                  fee_type,
					                  total_amt
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  pfincode = 'CIVC'
					                  AND
					                  caseno = p_caseno
			                  ) t3 ON t1.fee_type = t3.fee_type
			                  LEFT JOIN (
				                  SELECT
					                  fee_type,
					                  total_amt
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  pfincode = p_pfincode
					                  AND
					                  caseno = p_caseno
			                  ) t4 ON t1.fee_type = t4.fee_type
			                  LEFT JOIN (
				                  SELECT
					                  fee_type,
					                  SUM (nvl (total_amt, 0)) AS sum_total_amt
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  caseno = p_caseno
				                  GROUP BY
					                  fee_type
			                  ) t5 ON t1.fee_type = t5.fee_type
		                  ORDER BY
			                  fee_type;
	END;
	PROCEDURE get_adm_cashier_cash_dtl_list (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  revenue_type,
			                  caseno,
			                  (
				                  SELECT
					                  hpatnum
				                  FROM
					                  bil_root
				                  WHERE
					                  caseno = t1.caseno
			                  ) AS hpatnum,
			                  (
				                  SELECT
					                  hnamec
				                  FROM
					                  bil_root
				                  WHERE
					                  caseno = t1.caseno
			                  ) AS hnamec,
			                  charge_date,
			                  cashier_emp_id,
			                  service_bill_pkg.get_emp_name_ch (cashier_emp_id) AS cashier_name,
			                  service_bill_pkg.get_emp_dept_no (cashier_emp_id) AS cashier_dept_no,
			                  service_bill_pkg.get_emp_dept_name (cashier_emp_id) AS cashier_dept_name,
			                  charge_amt,
			                  charge_type
		                  FROM
			                  (
				                  SELECT
					                  'AdmBill' AS revenue_type,
					                  caseno,
					                  last_update_date   AS charge_date,
					                  last_updated_by    AS cashier_emp_id,
					                  CASE
						                  WHEN pat_paid_amt >= 0 THEN
							                  pat_paid_amt
						                  ELSE
							                  (pre_paid_amt + pat_paid_amt)
					                  END AS charge_amt,
					                  CASE
						                  WHEN pat_paid_amt >= 0 THEN
							                  'Charge'
						                  ELSE
							                  'Refund'
					                  END AS charge_type
				                  FROM
					                  bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status = 'Y'
					                  AND
					                  pat_kind = '1'
				                  UNION ALL
				                  SELECT
					                  'CertificateCharge',
					                  caseno,
					                  chargedate,
					                  chargeuser,
					                  total,
					                  'Charge'
				                  FROM
					                  abs_charge
				                  WHERE
					                  trunc (chargedate) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  pat_kind = '1'
					                  AND
					                  total > 0
					                  AND
					                  in_billtemp = 'N'
				                  UNION ALL
				                  SELECT
					                  'CharityBill',
					                  caseno,
					                  last_update_date,
					                  last_updated_by,
					                  CASE
						                  WHEN pat_paid_amt >= 0 THEN
							                  pat_paid_amt
						                  ELSE
							                  (pre_paid_amt + pat_paid_amt)
					                  END AS charge_amt,
					                  CASE
						                  WHEN pat_paid_amt >= 0 THEN
							                  'Charge'
						                  ELSE
							                  'Refund'
					                  END AS charge_type
				                  FROM
					                  bil_adjstbil_mst
				                  WHERE
					                  trunc (paid_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status = 'Y'
					                  AND
					                  pat_kind = '1'
				                  UNION ALL
				                  SELECT
					                  'AdmBill',
					                  caseno,
					                  last_update_date,
					                  last_updated_by,
					                  pre_paid_amt * - 1,
					                  'Refund'
				                  FROM
					                  bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  pat_paid_amt < 0
					                  AND
					                  rec_status = 'Y'
					                  AND
					                  pat_kind = '1'
				                  UNION ALL
				                  SELECT
					                  'CertificateCharge',
					                  caseno,
					                  chargedate,
					                  chargeuser,
					                  total,
					                  'Refund'
				                  FROM
					                  abs_charge
				                  WHERE
					                  trunc (chargedate) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  pat_kind = '1'
					                  AND
					                  total < 0
					                  AND
					                  in_billtemp = 'N'
				                  UNION ALL
				                  SELECT
					                  'CharityBill',
					                  caseno,
					                  last_update_date,
					                  last_updated_by,
					                  pre_paid_amt * - 1,
					                  'Refund'
				                  FROM
					                  bil_adjstbil_mst
				                  WHERE
					                  trunc (paid_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status = 'Y'
					                  AND
					                  pat_kind = '1'
					                  AND
					                  pat_paid_amt < 0
			                  ) t1
		                  ORDER BY
			                  charge_date;
	END;
	PROCEDURE get_adm_cashier_epay_dtl_list (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_pat_kind            IN    VARCHAR2,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		IF p_pat_kind IN (
			'2',
			'3'
		) THEN
			OPEN p_cursor FOR SELECT
				                  bil_epay_log.caseno          AS caseno,
				                  bil_epay_log.creation_date   AS charge_date,
				                  bil_epay_log.created_by      AS cashier_emp_id,
				                  service_bill_pkg.get_emp_name_ch (bil_epay_log.created_by) AS cashier_name,
				                  service_bill_pkg.get_emp_dept_no (bil_epay_log.created_by) AS cashier_dept_no,
				                  service_bill_pkg.get_emp_dept_name (bil_epay_log.created_by) AS cashier_dept_name,
				                  CASE
					                  WHEN bil_epay_log.pos_adm IS NULL THEN
						                  (bil_payservicenotice.txamount * 0.01)
					                  ELSE
						                  bil_epay_log.pos_adm
				                  END AS charge_amt,
				                  bil_epay_log.pat_kind,
				                  bil_root.hpatnum,
				                  bil_root.hnamec
			                  FROM
				                  bil_payservicenotice,
				                  bil_epay_log,
				                  bil_root
			                  WHERE
				                  bil_payservicenotice.pr_key2 = bil_epay_log.seqno
				                  AND
				                  bil_epay_log.caseno = bil_root.caseno
				                  AND
				                  bil_payservicenotice.sysid = 'adm'
				                  AND
				                  bil_payservicenotice.rec_status = 'Y'
				                  AND
				                  bil_epay_log.pat_kind = p_pat_kind
				                  AND
				                  bil_payservicenotice.valuedate BETWEEN TO_CHAR (p_start_charge_date, 'YYYYMMDD') AND TO_CHAR (p_end_charge_date
				                  , 'YYYYMMDD')
			                  ORDER BY
				                  charge_date;
		ELSIF p_pat_kind IN (
			'4',
			'5'
		) THEN
			OPEN p_cursor FOR SELECT
				                  bil_billmst.caseno             AS caseno,
				                  bil_billmst.last_update_date   AS charge_date,
				                  bil_billmst.last_updated_by    AS cashier_emp_id,
				                  service_bill_pkg.get_emp_name_ch (bil_billmst.last_updated_by) AS cashier_name,
				                  service_bill_pkg.get_emp_dept_no (bil_billmst.last_updated_by) AS cashier_dept_no,
				                  service_bill_pkg.get_emp_dept_name (bil_billmst.last_updated_by) AS cashier_dept_name,
				                  bil_billmst.pat_paid_amt       AS charge_amt,
				                  bil_billmst.pat_kind,
				                  bil_root.hpatnum,
				                  bil_root.hnamec
			                  FROM
				                  bil_billmst,
				                  bil_root
			                  WHERE
				                  bil_billmst.caseno = bil_root.caseno
				                  AND
				                  bil_billmst.rec_status = 'Y'
				                  AND
				                  bil_billmst.pat_kind = p_pat_kind
				                  AND
				                  trunc (bil_billmst.last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
			                  ORDER BY
				                  charge_date;
		END IF;
	END;
	PROCEDURE get_acct_code_list (
		i_visit_type   IN    VARCHAR2,
		o_sys_refcur   OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN o_sys_refcur FOR SELECT
			                      fee_kind,
			                      account_code,
			                      cosacbrn,
			                      kind_desc
		                      FROM
			                      bil_feekindbas
		                      WHERE
			                      fee_kind LIKE
				                      CASE i_visit_type
					                      WHEN 'A'   THEN
						                      'ADMCASH%'
					                      WHEN 'E'   THEN
						                      'EMGCASH%'
				                      END
			                      AND
			                      enabled = 'Y'
		                      ORDER BY
			                      fee_kind;
	END;
	PROCEDURE get_charged_item_dtl_list (
		p_start_dischg_date   DATE,
		p_end_dischg_date     DATE,
		p_fee_kind            IN    VARCHAR2,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  bil_root.caseno,
			                  bil_root.hpatnum,
			                  bil_root.hnamec,
			                  bil_root.admit_date,
			                  bil_root.dischg_date,
			                  bil_acnt_wk.fee_kind,
			                  service_bill_pkg.get_code_desc ('PFTYPE', bil_acnt_wk.fee_kind) AS fee_kind_desc,
			                  bil_acnt_wk.start_date,
			                  bil_acnt_wk.keyin_date,
			                  bil_acnt_wk.price_code,
			                  biling_common_pkg.f_get_pfkey_name (bil_acnt_wk.price_code, bil_acnt_wk.start_date) AS item_name_en,
			                  biling_common_pkg.f_get_pfkey_cname (bil_acnt_wk.price_code, bil_acnt_wk.start_date) AS item_name_ch,
			                  CASE bil_acnt_wk.pfincode
				                  WHEN 'LABI'   THEN
					                  bil_acnt_wk.insu_amt
				                  WHEN 'CIVC'   THEN
					                  bil_acnt_wk.self_amt
				                  ELSE
					                  bil_acnt_wk.part_amt
			                  END AS unit_price,
			                  bil_acnt_wk.tqty,
			                  bil_acnt_wk.emg_per,
			                  CASE bil_acnt_wk.pfincode
					                  WHEN 'LABI'   THEN
						                  bil_acnt_wk.insu_amt
					                  WHEN 'CIVC'   THEN
						                  bil_acnt_wk.self_amt
					                  ELSE
						                  bil_acnt_wk.part_amt
				                  END
			                  * tqty * emg_per AS total_amt
		                  FROM
			                  bil_root,
			                  bil_acnt_wk
		                  WHERE
			                  bil_root.caseno = bil_acnt_wk.caseno
			                  AND
			                  bil_root.dischg_date BETWEEN p_start_dischg_date AND p_end_dischg_date
			                  AND
			                  bil_acnt_wk.fee_kind = p_fee_kind
		                  ORDER BY
			                  bil_root.caseno,
			                  bil_acnt_wk.start_date,
			                  bil_acnt_wk.keyin_date,
			                  bil_acnt_wk.price_code;
	END;
	PROCEDURE get_fastreport_list (
		p_irf_form_no   IN    VARCHAR2,
		p_cursor        OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  irf_form_no,
			                  irf_eff_date,
			                  irf_type_no,
			                  irf_create_dt,
			                  irf_create_user,
			                  irf_form_name,
			                  irf_password,
			                  irf_paper_type,
			                  irf_paper_width,
			                  irf_paper_height,
			                  irf_fastreport,
			                  irf_pd_jsonvar,
			                  irf_pd_sqlvar,
			                  irf_pd_sqlkey,
			                  irf_md_binddb,
			                  irf_md_fullsql_conn,
			                  irf_md_sqlvar_conn,
			                  irf_md_jsonvar,
			                  irf_md_fullsql,
			                  irf_md_sqlvar,
			                  irf_md_sqlkey,
			                  irf_dd_jsonvar
		                  FROM
			                  fastreport.irptform
		                  WHERE
			                  irf_form_no = p_irf_form_no
		                  ORDER BY
			                  irf_eff_date DESC;
	END;
	PROCEDURE get_njob_vtan_meal_subsidy (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.caseno, -- 住院號
			                  t1.hpatnum, -- 索引號
			                  t1.id_no, -- 身份證號
			                  t1.hnamec, -- 姓名
                              t1.sex, -- 性別
			                  t1.hcursvcl, -- 科別
			                  t1.admit_date, -- 入院日期
			                  t1.dischg_date, -- 出院日期
			                  t2.start_date, -- 計價日期
			                  round (t3.total_amt) total_self_amt, -- 自付總金額
			                  round (t4.total_amt) AS total_part_amt  -- 補助總金額
		                  FROM
			                  (
				                  SELECT
					                  caseno,
					                  hpatnum,
					                  id_no,
					                  hnamec,
                                      sex,
					                  hcursvcl,
					                  admit_date,
					                  dischg_date
				                  FROM
					                  bil_root,
					                  common.pat_adm_vtan_rec
				                  WHERE
					                  bil_root.caseno = pat_adm_vtan_rec.hcaseno
					                  AND
					                  trunc (bil_root.dischg_date) BETWEEN p_start_dischg_date AND p_end_dischg_date
					                  AND
					                  pat_adm_vtan_rec.hvtfincl IN (
						                  '1',
						                  '3'
					                  )
					                  AND
					                  (
						                  SELECT
							                  COUNT (*)
						                  FROM
							                  bil_acnt_wk
						                  WHERE
							                  caseno = bil_root.caseno
							                  AND
							                  fee_kind = '02'
							                  AND
							                  pfincode IN (
								                  'VERT',
								                  'VERN',
								                  'VTAN'
							                  )
					                  ) > 0
			                  ) t1
			                  LEFT JOIN (
				                  SELECT DISTINCT
					                  caseno,
					                  start_date
				                  FROM
					                  bil_acnt_wk
				                  WHERE
					                  caseno IN (
						                  SELECT
							                  caseno
						                  FROM
							                  bil_root,
							                  common.pat_adm_vtan_rec
						                  WHERE
							                  bil_root.caseno = pat_adm_vtan_rec.hcaseno
							                  AND
							                  trunc (bil_root.dischg_date) BETWEEN p_start_dischg_date AND p_end_dischg_date
							                  AND
							                  pat_adm_vtan_rec.hvtfincl IN (
								                  '1',
								                  '3'
							                  )
							                  AND
							                  (
								                  SELECT
									                  COUNT (*)
								                  FROM
									                  bil_acnt_wk
								                  WHERE
									                  caseno = bil_root.caseno
									                  AND
									                  fee_kind = '02'
									                  AND
									                  pfincode IN (
										                  'VERT',
										                  'VERN',
										                  'VTAN'
									                  )
							                  ) > 0
					                  )
			                  ) t2 ON t1.caseno = t2.caseno
			                  LEFT JOIN (
				                  SELECT
					                  caseno,
					                  start_date,
					                  SUM (self_amt * emg_per * tqty) AS total_amt -- 自付總金額
				                  FROM
					                  bil_acnt_wk
				                  WHERE
					                  fee_kind = '02'
					                  AND
					                  pfincode = 'CIVC'
					                  AND
					                  substr (price_code, 1, 4) != 'DITG'
					                  AND
					                  caseno IN (
						                  SELECT
							                  caseno
						                  FROM
							                  bil_root,
							                  common.pat_adm_vtan_rec
						                  WHERE
							                  bil_root.caseno = pat_adm_vtan_rec.hcaseno
							                  AND
							                  trunc (bil_root.dischg_date) BETWEEN p_start_dischg_date AND p_end_dischg_date
							                  AND
							                  pat_adm_vtan_rec.hvtfincl IN (
								                  '1',
								                  '3'
							                  )
							                  AND
							                  (
								                  SELECT
									                  COUNT (*)
								                  FROM
									                  bil_acnt_wk
								                  WHERE
									                  caseno = bil_root.caseno
									                  AND
									                  fee_kind = '02'
									                  AND
									                  pfincode IN (
										                  'VERT',
										                  'VERN',
										                  'VTAN'
									                  )
							                  ) > 0
					                  )
				                  GROUP BY
					                  caseno,
					                  start_date
			                  ) t3 ON t2.caseno = t3.caseno
			                          AND
			                          t2.start_date = t3.start_date
			                  LEFT JOIN (
				                  SELECT
					                  caseno,
					                  start_date,
					                  SUM (part_amt * emg_per * tqty) AS total_amt -- 補助總金額
				                  FROM
					                  bil_acnt_wk
				                  WHERE
					                  fee_kind = '02'
					                  AND
					                  pfincode IN (
						                  'VERT',
						                  'VERN',
						                  'VTAN'
					                  )
					                  AND
					                  substr (price_code, 1, 4) != 'DITG'
					                  AND
					                  caseno IN (
						                  SELECT
							                  caseno
						                  FROM
							                  bil_root,
							                  common.pat_adm_vtan_rec
						                  WHERE
							                  bil_root.caseno = pat_adm_vtan_rec.hcaseno
							                  AND
							                  trunc (bil_root.dischg_date) BETWEEN p_start_dischg_date AND p_end_dischg_date
							                  AND
							                  pat_adm_vtan_rec.hvtfincl IN (
								                  '1',
								                  '3'
							                  )
							                  AND
							                  (
								                  SELECT
									                  COUNT (*)
								                  FROM
									                  bil_acnt_wk
								                  WHERE
									                  caseno = bil_root.caseno
									                  AND
									                  fee_kind = '02'
									                  AND
									                  pfincode IN (
										                  'VERT',
										                  'VERN',
										                  'VTAN'
									                  )
							                  ) > 0
					                  )
				                  GROUP BY
					                  caseno,
					                  start_date
			                  ) t4 ON t2.caseno = t4.caseno
			                          AND
			                          t2.start_date = t4.start_date
		                  WHERE
			                  t4.total_amt IS NOT NULL
		                  ORDER BY
			                  caseno,
			                  start_date;
	END;
	PROCEDURE get_njob_vtan_ward_subsidy (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.hpatnum,
			                  t1.id_no,
			                  t1.hnamec,
                              t1.sex,
			                  t1.admit_date,
			                  t1.dischg_date,
			                  (trunc (t1.dischg_date) - trunc (t1.admit_date) + 1) AS inp_days,
			                  t2.ward,
			                  t2.bed_no,
			                  t2.cost_code,
			                  t2.price_code,
			                  (biling_common_pkg.f_getprice (t2.price_code) - biling_common_pkg.f_getprice ('WARD3W4')) AS ward_price,
			                  t2.ward_days,
			                  t2.ward_subsidy,
			                  t2.ward_start_date,
			                  t2.ward_end_date
		                  FROM
			                  (
				                  SELECT
					                  caseno,
					                  hpatnum,
					                  id_no,
					                  hnamec,
                                      sex,
					                  admit_date,
					                  dischg_date,
					                  hcursvcl
				                  FROM
					                  bil_root
				                  WHERE
					                  caseno IN (
						                  SELECT
							                  bil_root.caseno
						                  FROM
							                  bil_root,
							                  bil_feedtl,
							                  common.pat_adm_vtan_rec
						                  WHERE
							                  bil_root.caseno = bil_feedtl.caseno
							                  AND
							                  bil_root.caseno = pat_adm_vtan_rec.hcaseno
							                  AND
							                  trunc (bil_root.dischg_date) BETWEEN p_start_dischg_date AND p_end_dischg_date
							                  AND
							                  bil_feedtl.fee_type = '01'
							                  AND
							                  bil_feedtl.pfincode IN (
								                  'VERT',
								                  'VERN',
								                  'VTAN'
							                  )
							                  AND
							                  pat_adm_vtan_rec.hvtfincl IN (
								                  '1',
								                  '3'
							                  )
					                  )
			                  ) t1,
			                  (
				                  SELECT
					                  caseno,
					                  ward,
					                  bed_no,
					                  cost_code,
					                  price_code,
					                  SUM (tqty) / 2 AS ward_days,
					                  SUM (part_amt * emg_per * tqty) AS ward_subsidy,
					                  MIN (start_date) AS ward_start_date,
					                  MAX (start_date) AS ward_end_date
				                  FROM
					                  bil_acnt_wk
				                  WHERE
					                  fee_kind = '01'
					                  AND
					                  pfincode IN (
						                  'VERT',
						                  'VERN',
						                  'VTAN'
					                  )
					                  AND
					                  substr (price_code, 1, 5) = 'WARD2'
					                  AND
					                  nvl (part_amt, 0) != 0
					                  AND
					                  caseno IN (
						                  SELECT
							                  bil_root.caseno
						                  FROM
							                  bil_root,
							                  bil_feedtl,
							                  common.pat_adm_vtan_rec
						                  WHERE
							                  bil_root.caseno = bil_feedtl.caseno
							                  AND
							                  bil_root.caseno = pat_adm_vtan_rec.hcaseno
							                  AND
							                  trunc (bil_root.dischg_date) BETWEEN p_start_dischg_date AND p_end_dischg_date
							                  AND
							                  bil_feedtl.fee_type = '01'
							                  AND
							                  bil_feedtl.pfincode IN (
								                  'VERT',
								                  'VERN',
								                  'VTAN'
							                  )
							                  AND
							                  pat_adm_vtan_rec.hvtfincl IN (
								                  '1',
								                  '3'
							                  )
					                  )
				                  GROUP BY
					                  caseno,
					                  price_code,
					                  ward,
					                  bed_no,
					                  cost_code
			                  ) t2
		                  WHERE
			                  t1.caseno = t2.caseno
		                  ORDER BY
			                  t1.id_no,
			                  t2.ward_start_date;
	END;
	PROCEDURE get_njob_vtan_meterial_subsidy (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.*,
			                  t2.*
		                  FROM
			                  (
				                  SELECT
					                  bil_root.caseno,
					                  bil_root.id_no,
					                  bil_root.hpatnum,
					                  bil_root.hnamec,
					                  bil_root.admit_date,
					                  bil_root.dischg_date,
					                  bil_root.hcursvcl
				                  FROM
					                  bil_root
				                  WHERE
					                  caseno IN (
						                  SELECT
							                  hcaseno
						                  FROM
							                  common.pat_adm_vtan_rec
						                  WHERE
							                  hvtfincl IN (
								                  '1',
								                  '3'
							                  )
					                  )
					                  AND
					                  trunc (bil_root.dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
			                  ) t1
			                  JOIN (
				                  SELECT
					                  bil_acnt_wk.caseno,
					                  bil_acnt_wk.price_code,
					                  bil_acnt_wk.fee_kind,
					                  bil_acnt_wk.emg_per AS emg_per,
					                  round (bil_acnt_wk.tqty) AS tqty,
					                  round (bil_acnt_wk.part_amt) AS part_amt,--健保差額單價
					                  bil_acnt_wk.pfincode,--身份別
					                  bil_acnt_wk.end_date,
					                  CASE bil_acnt_wk.fee_kind
						                  WHEN '06' THEN
							                  t4.udnmftdgnm
						                  ELSE
							                  t3.orproced
					                  END AS item_name_en,
					                  CASE bil_acnt_wk.fee_kind
						                  WHEN '06' THEN
							                  t6.pfcomcd
						                  ELSE
							                  t5.pfcomcd
					                  END AS item_no
                        -- t3.orproced              ,
                        -- t4.udnmftdgnm            ,
                        --  t5.pfcomcd               ,
                        -- t6.pfcomcd AS pfcomcd_ud
				                  FROM
					                  (
						                  SELECT
							                  *
						                  FROM
							                  bil_acnt_wk
						                  WHERE
							                  pfincode IN (
								                  'VERT',
								                  'VERN'
							                  )
							                  AND
							                  fee_kind NOT IN (
								                  '01',
								                  '02'
							                  )
							                  AND
							                  caseno IN (
								                  SELECT
									                  caseno
								                  FROM
									                  bil_root
								                  WHERE
									                  trunc (bil_root.dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
							                  )
					                  ) bil_acnt_wk
					                  LEFT JOIN (
						                  SELECT
							                  pfkey,
							                  orproced
						                  FROM
							                  cpoe.dbpfile
					                  ) t3 ON bil_acnt_wk.price_code = t3.pfkey
					                  LEFT JOIN cpoe.udndrgoc t4 ON t4.udndrgcode = substr (bil_acnt_wk.price_code, 4)
					                                                AND
					                                                (t4.udnenddate >= bil_acnt_wk.end_date
					                                                 OR
					                                                 t4.udnenddate IS NULL)
					                                                AND
					                                                (t4.udnbgndate <= bil_acnt_wk.end_date)
					                  LEFT JOIN (
						                  SELECT
							                  pfkey,
							                  pfcomcd
						                  FROM
							                  pfclass
						                  WHERE
							                  pfincode = 'VTAN'
					                  ) t5 ON t5.pfkey = bil_acnt_wk.price_code
					                  LEFT JOIN (
						                  SELECT
							                  udddrgcode,
							                  pfcomcd
						                  FROM
							                  cpoe.uddrugpf
						                  WHERE
							                  uddpayself = 'V'
					                  ) t6 ON t6.udddrgcode = substr (bil_acnt_wk.price_code, 4)
			                  ) t2 ON t1.caseno = t2.caseno
		                  ORDER BY
			                  t1.dischg_date,
			                  t1.admit_date,
			                  t1.caseno,
			                  t2.fee_kind;
	END;
	PROCEDURE get_njob_vtan_all_subsidy (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.*,
			                  t2.*
		                  FROM
			                  (
				                  SELECT
					                  bil_root.caseno,
					                  bil_root.id_no,
					                  bil_root.hpatnum,
					                  bil_root.hnamec,
					                  bil_root.admit_date,
					                  bil_root.dischg_date,
					                  bil_root.hcursvcl
				                  FROM
					                  bil_root
				                  WHERE
					                  caseno IN (
						                  SELECT
							                  hcaseno
						                  FROM
							                  common.pat_adm_vtan_rec
						                  WHERE
							                  hvtfincl IN (
								                  '1',
								                  '3'
							                  )
					                  )
					                  AND
					                  trunc (bil_root.dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
			                  ) t1
			                  JOIN (
				                  SELECT
					                  bil_acnt_wk.caseno,
					                  bil_acnt_wk.price_code,
					                  bil_acnt_wk.fee_kind,
					                  bil_acnt_wk.emg_per AS emg_per,
					                  round (bil_acnt_wk.tqty) AS tqty,
					                  round (bil_acnt_wk.part_amt) AS part_amt,--健保差額單價
					                  bil_acnt_wk.pfincode,--身份別
					                  bil_acnt_wk.end_date,
					                  CASE bil_acnt_wk.fee_kind
						                  WHEN '06' THEN
							                  t4.udnmftdgnm
						                  ELSE
							                  t3.orproced
					                  END AS item_name_en,
					                  CASE bil_acnt_wk.fee_kind
						                  WHEN '06' THEN
							                  t6.pfcomcd
						                  ELSE
							                  t5.pfcomcd
					                  END AS item_no
                        -- t3.orproced              ,
                        -- t4.udnmftdgnm            ,
                        --  t5.pfcomcd               ,
                        -- t6.pfcomcd AS pfcomcd_ud
				                  FROM
					                  (
						                  SELECT
							                  *
						                  FROM
							                  bil_acnt_wk
						                  WHERE
							                  pfincode IN (
								                  'VERT',
								                  'VERN',
								                  'VTAN'
							                  )
							                  AND
							                  caseno IN (
								                  SELECT
									                  caseno
								                  FROM
									                  bil_root
								                  WHERE
									                  trunc (bil_root.dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
							                  )
					                  ) bil_acnt_wk
					                  LEFT JOIN (
						                  SELECT
							                  pfkey,
							                  orproced
						                  FROM
							                  cpoe.dbpfile
					                  ) t3 ON bil_acnt_wk.price_code = t3.pfkey
					                  LEFT JOIN cpoe.udndrgoc t4 ON t4.udndrgcode = substr (bil_acnt_wk.price_code, 4)
					                                                AND
					                                                (t4.udnenddate >= bil_acnt_wk.end_date
					                                                 OR
					                                                 t4.udnenddate IS NULL)
					                                                AND
					                                                (t4.udnbgndate <= bil_acnt_wk.end_date)
					                  LEFT JOIN (
						                  SELECT
							                  pfkey,
							                  pfcomcd
						                  FROM
							                  pfclass
						                  WHERE
							                  pfincode = 'VTAN'
					                  ) t5 ON t5.pfkey = bil_acnt_wk.price_code
					                  LEFT JOIN (
						                  SELECT
							                  udddrgcode,
							                  pfcomcd
						                  FROM
							                  cpoe.uddrugpf
						                  WHERE
							                  uddpayself = 'V'
					                  ) t6 ON t6.udddrgcode = substr (bil_acnt_wk.price_code, 4)
			                  ) t2 ON t1.caseno = t2.caseno
		                  ORDER BY
			                  t1.dischg_date,
			                  t1.admit_date,
			                  t1.caseno,
			                  t2.fee_kind;
	END;
	PROCEDURE get_yjob_vtan_subsidy_list (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.caseno,
			                  t1.id_no,
			                  t1.hpatnum,
			                  t1.hnamec,
			                  t1.admit_date,
			                  t1.dischg_date,
			                  t1.hcursvcl,
			                  t2.hvtfincl,
			                  t2.hvtrnkcd,
			                  service_bill_pkg.get_code_desc ('RankName', t2.hvtrnkcd) AS hvtrnkcd_desc,
			                  service_bill_pkg.get_code_desc ('YesJobVtanRankSubsidyRate', t2.hvtrnkcd) AS subsidy_rate,
			                  t3.fee_type,
			                  t3.payable_amt,
			                  t4.subsidy_amt,
			                  t5.hsex,
			                  service_bill_pkg.get_code_desc ('Gender', t5.hsex) AS hsex_desc
		                  FROM
			                  (
				                  SELECT
					                  caseno,
					                  id_no,
					                  hpatnum,
					                  hnamec,
					                  admit_date,
					                  dischg_date,
					                  hcursvcl
				                  FROM
					                  bil_root
				                  WHERE
					                  trunc (dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
			                  ) t1
			                  INNER JOIN (
				                  SELECT
					                  hcaseno,
					                  hvtfincl,
					                  hvtrnkcd
				                  FROM
					                  common.pat_adm_vtan_rec
				                  WHERE
					                  hvtfincl = '2'
			                  ) t2 ON t1.caseno = t2.hcaseno
			                  INNER JOIN (
				                  SELECT
					                  caseno,
					                  fee_type,
					                  SUM (total_amt) AS payable_amt
				                  FROM
					                  bil_feedtl
				                  GROUP BY
					                  caseno,
					                  fee_type
			                  ) t3 ON t1.caseno = t3.caseno
			                  INNER JOIN (
				                  SELECT
					                  caseno,
					                  fee_type,
					                  total_amt AS subsidy_amt
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  pfincode like 'VT%'
					                  AND
					                  pfincode!='VTAN'
                                      AND
                                      total_amt != 0
			                  ) t4 ON t1.caseno = t4.caseno
			                          AND
			                          t3.fee_type = t4.fee_type
			                  LEFT JOIN common.pat_basic t5 ON t1.hpatnum = t5.hhisnum
		                  ORDER BY
			                  dischg_date,
			                  admit_date,
			                  caseno,
			                  fee_type;
	END;
	PROCEDURE get_njob_vtan_subsidy_list (
		p_start_dischg_date   IN    DATE,
		p_end_dischg_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.*,
			                  nvl ((t2.sum), 0) AS credit1,    -- 二人病床費差額50%
			                  nvl ((t3.sum), 0) AS credit2,    -- 就養榮民伙食費差額
			                  nvl ((t4.sum), 0) AS credit3,    -- 醫療必須健保不給付經本會核定項目
			                  nvl ((t2.sum), 0) + nvl ((t3.sum), 0) + nvl ((t4.sum), 0) AS credit_total -- 實際申請補助合計
		                  FROM
			                  (
				                  SELECT
					                  bil_feemst.caseno, -- 住院號
					                  bil_root.hcursvcl, -- 科別
					                  bil_root.id_no, -- 身份證
					                  bil_root.hpatnum, -- 索引號
					                  TRIM (bil_root.hnamec) AS hnamec, -- 姓名
					                  bil_root.admit_date, -- 住院日期
					                  bil_root.dischg_date, -- 出院日期
					                  round (bil_feemst.emg_exp_amt1) AS emg_exp_amt1, -- 健保總額
					                  pat_basic.hsex, -- 性別
					                  service_bill_pkg.get_code_desc ('Gender', pat_basic.hsex) AS hsex_desc
				                  FROM
					                  bil_feemst,
					                  bil_root,
					                  common.pat_adm_vtan_rec,
					                  common.pat_basic
				                  WHERE
					                  bil_feemst.caseno = bil_root.caseno
					                  AND
					                  bil_root.caseno = pat_adm_vtan_rec.hcaseno
					                  AND
					                  trunc (bil_root.dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
					                  AND
					                  pat_adm_vtan_rec.hvtfincl IN (
						                  '1',
						                  '3'
					                  )
					                  AND
					                  bil_root.hpatnum = pat_basic.hhisnum
			                  ) t1
			                  LEFT JOIN (
				                  SELECT
					                  caseno,
					                  SUM (total_amt) AS sum
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  fee_type = '01'
					                  AND
					                  pfincode IN (
						                  'VERT',
						                  'VERN'
					                  )
					                  AND
					                  total_amt <> 0
					                  AND
					                  caseno IN (
						                  SELECT
							                  caseno
						                  FROM
							                  bil_root
						                  WHERE
							                  trunc (bil_root.dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
					                  )
				                  GROUP BY
					                  caseno
			                  ) t2 ON t1.caseno = t2.caseno
			                  LEFT JOIN (
				                  SELECT
					                  caseno,
					                  SUM (total_amt) AS sum
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  fee_type = '02'
					                  AND
					                  pfincode IN (
						                  'VERT',
						                  'VERN'
					                  )
					                  AND
					                  total_amt <> 0
					                  AND
					                  caseno IN (
						                  SELECT
							                  caseno
						                  FROM
							                  bil_root
						                  WHERE
							                  trunc (bil_root.dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
					                  )
				                  GROUP BY
					                  caseno
			                  ) t3 ON t1.caseno = t3.caseno
			                  LEFT JOIN (
				                  SELECT
					                  caseno,
					                  SUM (total_amt) AS sum
				                  FROM
					                  bil_feedtl
				                  WHERE
					                  fee_type NOT IN (
						                  '01',
						                  '02'
					                  )
					                  AND
					                  pfincode IN (
						                  'VERT',
						                  'VERN'
					                  )
					                  AND
					                  total_amt <> 0
					                  AND
					                  caseno IN (
						                  SELECT
							                  caseno
						                  FROM
							                  bil_root
						                  WHERE
							                  trunc (bil_root.dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
					                  )
				                  GROUP BY
					                  caseno
			                  ) t4 ON t1.caseno = t4.caseno
		                  WHERE
			                  nvl ((t2.sum), 0) + nvl ((t3.sum), 0) + nvl ((t4.sum), 0) <> 0
		                  ORDER BY
			                  t1.dischg_date,
			                  t1.admit_date,
			                  t1.caseno;
	END;
        PROCEDURE get_vtan_payment_summary
                                      (
                                          p_start_dischg_date IN DATE,
                                          p_end_dischg_date   IN DATE,
                                          p_cursor OUT SYS_REFCURSOR
                                      )
    IS
    BEGIN
        OPEN p_cursor FOR
        WITH t1 AS(
                SELECT
                    pat_adm_vtan_rec.hvtfincl                                                              , -- 給付類別
                    pat_adm_vtan_rec.hvtrnkcd                                                              ,
                    service_bill_pkg.get_code_desc ('RankName', pat_adm_vtan_rec.hvtrnkcd) AS hvtrnkcd_desc, -- 官階
                    bil_root.hcursvcl                                                                      , -- 就診科別
                    bil_root.hvmdno                                                                        ,
                    (
                        SELECT
                            govenid
                        FROM
                            opdusr.basuser
                        WHERE
                            stampid = bil_root.hvmdno
                    )
                    AS doc_idno                                                      ,                                      -- 醫師身份證號
                    bil_root.hvdocnm                                                 ,                                      -- 醫師姓名
                    bil_root.caseno                                                  ,                                      -- 住院號
                    bil_root.id_no                                                   ,                                      -- 病患身份證字號
                    pat_basic.hsex                                                   ,                                      -- 病患性別
                    bil_root.hpatnum                                                 ,                                      -- 病歷號
                    TRIM (bil_root.hnamec)                                AS hnamec  ,                                      -- 病患姓名
                    CAST (pat_basic.hbirthdt - 19110000 AS VARCHAR2 (10)) AS hbirthdt,                                      -- 出生年月日
                    bil_root.admit_date                                              ,                                      -- 就診開始日期
                    bil_root.dischg_date                                             ,                                      -- 就診結束日期
                    service_bill_pkg.get_code_desc ('YesJobVtanRankSubsidyRate', pat_adm_vtan_rec.hvtrnkcd) AS subsidy_rate -- (有職榮) 部分負擔補助比率
                FROM
                    bil_root               ,
                    common.pat_adm_vtan_rec,
                    common.pat_basic
                WHERE
                    bil_root.caseno = pat_adm_vtan_rec.hcaseno
                    AND trunc (bil_root.dischg_date) BETWEEN trunc (p_start_dischg_date) AND trunc (p_end_dischg_date)
                    AND pat_adm_vtan_rec.hvtfincl IN ( '1', '3', '2' )
                    AND bil_root.hpatnum = pat_basic.hhisnum
            )
            ,
            t3 AS
            (
                SELECT
                    caseno  ,
                    fee_type,
                    SUM (total_amt) AS payable_amt
                FROM
                    bil_feedtl
                WHERE
                    fee_type   IN ( '41', '42', '43', '51', '52', '53', '54' )
                    AND caseno IN
                    (
                        SELECT
                            caseno
                        FROM
                            t1
                    )
                GROUP BY
                    caseno,
                    fee_type
            )
            ,
            t4 AS
            (
                SELECT
                    caseno  ,
                    fee_type,
                    total_amt AS subsidy_amt
                FROM
                    bil_feedtl
                WHERE
                    fee_type IN ( '41', '42', '43', '51', '52', '53', '54' )
                    AND pfincode LIKE 'VT%'
                    AND pfincode   != 'VTAN'
                    AND total_amt  != 0
                    AND caseno IN
                    (
                        SELECT
                            caseno
                        FROM
                            t1
                    )
            )
            ,
            t5 AS
            (
                SELECT
                    caseno,
                    SUM (total_amt) AS sum
                FROM
                    bil_feedtl
                WHERE
                    fee_type = '01'
                    AND pfincode IN ( 'VERT', 'VERN' )
                    AND total_amt <> 0
                    AND caseno IN
                    (
                        SELECT
                            caseno
                        FROM
                            t1
                    )
                GROUP BY
                    caseno
            )
            ,
            t6 AS
            (
                SELECT
                    caseno,
                    SUM (total_amt) AS sum
                FROM
                    bil_feedtl
                WHERE
                    fee_type = '02'
                    AND pfincode IN ( 'VERT', 'VERN' )
                    AND total_amt <> 0
                    AND caseno IN
                    (
                        SELECT
                            caseno
                        FROM
                            t1
                    )
                GROUP BY
                    caseno
            )
            ,
            t7 AS
            (
                SELECT
                    caseno,
                    SUM (total_amt) AS sum
                FROM
                    bil_feedtl
                WHERE
                    fee_type NOT IN ( '01'  , '02' )
                    AND pfincode IN ( 'VERT', 'VERN' )
                    AND total_amt <> 0
                    AND caseno IN
                    (
                        SELECT
                            caseno
                        FROM
                            t1
                    )
                GROUP BY
                    caseno
            )
        SELECT
            t1.*,
            CASE
                WHEN t1.hvtfincl = '2'
                    THEN t3.fee_type
                    ELSE NULL
            END AS fee_type,
            CASE
                WHEN t1.hvtfincl = '2'
                    THEN t3.payable_amt
                    ELSE NULL
            END                                                 AS payable_amt, -- 部分負擔合計
            t4.subsidy_amt                                      AS subsidy_amt, -- 部分負擔補助總金額(V*W), 總補助金額
            nvl (t5.sum, 0)                                     AS credit1    , -- 二人病床費差額50%
            nvl (t6.sum, 0)                                     AS credit2    , -- 就養榮民伙食費差額
            nvl (t7.sum, 0)                                     AS credit3    , -- 醫療必須健保不給付經本會核定項目
            nvl (t5.sum, 0) + nvl (t6.sum, 0) + nvl (t7.sum, 0) AS credit_total -- 實際申請補助合計
        FROM
            t1
            LEFT OUTER JOIN
                t3
                ON
                    t1.caseno = t3.caseno
            LEFT JOIN
                t4
                ON
                    t1.caseno       = t4.caseno
                    AND t3.fee_type = t4.fee_type
            LEFT JOIN
                t5
                ON
                    t1.caseno = t5.caseno
            LEFT JOIN
                t6
                ON
                    t1.caseno = t6.caseno
            LEFT JOIN
                t7
                ON
                    t1.caseno = t7.caseno
        WHERE
            (
                t1.hvtfincl                  = '2'
                AND t4.subsidy_amt IS NOT NULL
            )
            OR
            (
                t1.hvtfincl          IN ( '1', '3' )
                AND nvl ((t5.sum), 0) + nvl ((t6.sum), 0) + nvl ((t7.sum), 0) > 0
            )
        ORDER BY
            CASE t1.hvtfincl
                WHEN '2'
                    THEN 1
                    ELSE 2
            END           ,
            t1.dischg_date,
            t1.admit_date ,
            t1.caseno
        ;
    END;
    PROCEDURE get_vtan_payment_detail
                                      (
                                          p_start_dischg_date IN DATE,
                                          p_end_dischg_date   IN DATE,
                                          p_cursor OUT SYS_REFCURSOR
                                      )
    IS
    BEGIN
        OPEN p_cursor FOR																		   
        WITH t1 AS
            (
                SELECT
                    pat_adm_vtan_rec.hvtfincl                                                               ,-- 給付類別
                    pat_adm_vtan_rec.hvtrnkcd                                                               ,
                    service_bill_pkg.get_code_desc( 'RankName', pat_adm_vtan_rec.hvtrnkcd ) AS hvtrnkcd_desc,-- 官階
                    bil_root.hcursvcl                                                                       ,-- 就診科別
                    bil_root.hvmdno                                                                         ,
                    (
                        SELECT
                            govenid
                        FROM
                            opdusr.basuser
                        WHERE
                            stampid = bil_root.hvmdno
                    )
                    AS doc_idno                                                     ,                                        -- 醫師身份證號
                    bil_root.hvdocnm                                                ,                                        -- 醫師姓名
                    bil_root.caseno                                                 ,                                        -- 住院號
                    bil_root.id_no                                                  ,                                        -- 病患身份證字號
                    pat_basic.hsex                                                  ,                                        -- 病患性別
                    bil_root.hpatnum                                                ,                                        -- 病歷號
                    TRIM(bil_root.hnamec)                                AS hnamec  ,                                        -- 病患姓名
                    CAST(pat_basic.hbirthdt - 19110000 AS VARCHAR2(10) ) AS hbirthdt,                                        -- 出生年月日
                    bil_root.admit_date                                             ,                                        -- 就診開始日期
                    bil_root.dischg_date                                            ,                                        -- 就診結束日期
                    service_bill_pkg.get_code_desc( 'YesJobVtanRankSubsidyRate', pat_adm_vtan_rec.hvtrnkcd ) AS subsidy_rate -- (有職榮) 部分負擔補助比率
                FROM
                    bil_root               ,
                    common.pat_adm_vtan_rec,
                    common.pat_basic
                WHERE
                    bil_root.caseno = pat_adm_vtan_rec.hcaseno
                    AND trunc(bil_root.dischg_date) BETWEEN trunc(p_start_dischg_date) AND trunc(p_end_dischg_date)
                    AND pat_adm_vtan_rec.hvtfincl IN ( '1','3','2' )
                    AND bil_root.hpatnum = pat_basic.hhisnum
            )
            ,
            t3 AS
            (
                SELECT
                    caseno  ,
                    fee_type,
                    SUM(total_amt) AS payable_amt
                FROM
                    bil_feedtl
                WHERE
                    fee_type   IN ( '41','42','43','51','52','53','54' )
                    AND caseno IN
                    (
                        SELECT
                            caseno
                        FROM
                            t1
                    )
                GROUP BY
                    caseno,
                    fee_type
            )
            ,
            t4 AS
            (
                SELECT
                    caseno  ,
                    fee_type,
                    total_amt AS subsidy_amt
                FROM
                    bil_feedtl
                WHERE
                    fee_type IN ( '41','42','43','51','52','53','54' )
                    AND pfincode LIKE 'VT%'
                    AND pfincode   != 'VTAN'
                    AND total_amt  != 0
                    AND caseno IN
                    (
                        SELECT
                            caseno
                        FROM
                            t1
                    )
            )
            ,
            t5 AS
            (
                SELECT DISTINCT
                    bil_acnt_wk.caseno                                                               ,
                    bil_acnt_wk.price_code                                                           ,
                    bil_acnt_wk.fee_kind                                                             ,
                    service_bill_pkg.get_code_desc( 'PFTYPE', bil_acnt_wk.fee_kind ) AS fee_kind_desc,
                    bil_acnt_wk.pfincode                                                             , -- 身份別
                    bil_acnt_wk.start_date                                                           ,
                    CASE bil_acnt_wk.fee_kind
                        WHEN '06'
                            THEN udndrgoc.udnmftdgnm
                            ELSE dbpfile.orproced
                    END AS item_name_en
                FROM
                    (
                    (
                        SELECT *
                        FROM
                            bil_acnt_wk
                        WHERE
                            pfincode   IN ( 'VERT','VERN','VTAN' )
                            AND caseno IN
                            (
                                SELECT
                                    caseno
                                FROM
                                    t1
                            )
                    )
                    bil_acnt_wk
                    LEFT JOIN
                        (
                            SELECT
                                pfkey,
                                orproced
                            FROM
                                cpoe.dbpfile
                        )
                        dbpfile
                        ON
                            bil_acnt_wk.price_code = dbpfile.pfkey
                    LEFT JOIN
                        cpoe.udndrgoc
                        ON
                            udndrgoc.udndrgcode = substr( bil_acnt_wk.price_code, 4 )
                            AND
                            (
                                udndrgoc.udnenddate         >= bil_acnt_wk.end_date
                                OR udndrgoc.udnenddate IS NULL
                            )
                            AND
                            (
                                udndrgoc.udnbgndate <= bil_acnt_wk.start_date
                            )
                    )
            )
            ,
            t6 AS
            (
            (
                SELECT
                    bil_acnt_wk.caseno     ,
                    bil_acnt_wk.price_code ,
                    bil_acnt_wk.fee_kind   ,
                    '病房費差額' AS subsidy_type, -- 補助類別
                    bil_acnt_wk.start_date , -- 入住差價床起日
                    bil_acnt_wk.end_date   , -- 入住差價床迄日
                    bil_acnt_wk.ward
                        || '-'
                        || bil_acnt_wk.bed_no                                                                          AS note       , -- 病床號
                    bil_acnt_wk.qty                                                                                    AS number_note, -- 二人病房天數
                    (biling_common_pkg.f_getprice (bil_acnt_wk.price_code) - biling_common_pkg.f_getprice ('WARD3W4')) AS unit_price , -- 二人病房費差額(單價)
                    bil_acnt_wk.subsidy_amt                                                                                            -- 類別補助金額
                FROM
                    (
                        SELECT
                            caseno                       ,
                            ward                         ,
                            bed_no                       ,
                            price_code                   ,
                            fee_kind                     ,
                            MIN(start_date)                AS start_date,
                            MAX(start_date)                AS end_date  ,
                            SUM(tqty) / 2                  AS qty       ,
                            SUM(part_amt * emg_per * tqty) AS subsidy_amt
                        FROM
                            bil_acnt_wk
                        WHERE
                            fee_kind = '01'
                            AND pfincode IN ( 'VERT','VERN','VTAN' )
                            AND substr( price_code, 1, 5 ) = 'WARD2'
                            AND nvl( part_amt, 0 )        != 0
                            AND caseno IN
                            (
                                SELECT
                                    caseno
                                FROM
                                    t1
                            )
                        GROUP BY
                            caseno    ,
                            ward      ,
                            bed_no    ,
                            price_code,
                            fee_kind
                    )
                    bil_acnt_wk
                UNION
                SELECT
                    bil_acnt_wk_1.caseno          ,
                    bil_acnt_wk_3.price_code      ,
                    bil_acnt_wk_3.fee_kind        ,
                    '伙食費差額'                       , -- 補助類別
                    bil_acnt_wk_1.start_date      ,
                    bil_acnt_wk_3.end_date        , -- 計價日期
                    null                          ,
                    1                             , -- 伙食費數量
                    round(bil_acnt_wk_2.total_amt), -- 病人自付額
                    round(bil_acnt_wk_3.total_amt)  -- 類別補助金額
                FROM
                    (
                    (
                        SELECT DISTINCT
                            caseno,
                            start_date
                        FROM
                            bil_acnt_wk
                        WHERE
                            caseno in
                            (
                                SELECT
                                    caseno
                                FROM
                                    t1
                            )
                    )
                    ) bil_acnt_wk_1
                    LEFT JOIN
                        (
                            SELECT
                                caseno    ,
                                start_date,
                                SUM (self_amt * emg_per * tqty) AS total_amt -- 自付總金額
                            FROM
                                bil_acnt_wk
                            WHERE
                                fee_kind                       = '02'
                                AND pfincode                   = 'CIVC'
                                AND substr (price_code, 1, 4) != 'DITG'
                                AND caseno in
                                (
                                    SELECT
                                        caseno
                                    FROM
                                        t1
                                )
                            GROUP BY
                                caseno,
                                start_date
                        )
                        bil_acnt_wk_2
                        ON
                            bil_acnt_wk_1.caseno         = bil_acnt_wk_2.caseno
                            AND bil_acnt_wk_1.start_date = bil_acnt_wk_2.start_date
                    LEFT JOIN
                        (
                            SELECT
                                caseno    ,
                                start_date,
                                end_date  ,
                                price_code,
                                fee_kind  ,
                                SUM(part_amt * emg_per * tqty) AS total_amt -- 補助金額
                            FROM
                                bil_acnt_wk
                            WHERE
                                fee_kind = '02'
                                AND pfincode IN ( 'VERT','VERN','VTAN' )
                                AND substr( price_code, 1, 4 ) != 'DITG'
                                AND caseno in
                                (
                                    SELECT
                                        caseno
                                    FROM
                                        t1
                                )
                            GROUP BY
                                caseno    ,
                                start_date,
                                end_date  ,
                                price_code,
                                fee_kind
                        )
                        bil_acnt_wk_3
                        ON
                            bil_acnt_wk_1.caseno         = bil_acnt_wk_3.caseno
                            AND bil_acnt_wk_1.start_date = bil_acnt_wk_3.start_date
                WHERE
                    bil_acnt_wk_3.total_amt IS NOT NULL
                UNION
                    (
                        SELECT
                            bil_acnt_wk.caseno     ,
                            bil_acnt_wk.price_code , -- 本院計價碼
                            bil_acnt_wk.fee_kind   ,
                            '衛藥材'                  , -- 補助類別
                            bil_acnt_wk.start_date ,
                            bil_acnt_wk.end_date   , -- 計價日
                            CASE bil_acnt_wk.fee_kind
                                WHEN '06'
                                    THEN uddrugpf.pfcomcd
                                    ELSE pfclass.pfcomcd
                            END AS item_no               , -- 本院計價碼名稱
                            round (bil_acnt_wk.tqty)     , -- 衛藥材(醫療必須健保不給付經核定項目)數量
                            round (bil_acnt_wk.part_amt) , -- 健保差額單價
                            bil_acnt_wk.subsidy_amt        -- 類別補助金額
                        FROM
                            (
                                SELECT
                                    caseno                       ,
                                    price_code                   ,
                                    fee_kind                     ,
                                    start_date                   ,
                                    end_date                     ,
                                    round (part_amt)                       AS part_amt ,
                                    round (SUM(tqty))                      AS tqty     ,
                                    SUM(round (part_amt) * emg_per * tqty) AS subsidy_amt
                                FROM
                                    bil_acnt_wk
                                WHERE
                                    pfincode         IN ( 'VERT', 'VERN' )
                                    AND fee_kind NOT IN ( '01'  , '02' )
                                    AND caseno       IN
                                    (
                                        SELECT
                                            caseno
                                        FROM
                                            t1
                                    )
                                GROUP BY
                                    caseno     ,
                                    price_code ,
                                    fee_kind   ,
                                    start_date ,
                                    end_date   ,
                                    round (part_amt)
                            )
                            bil_acnt_wk
                            LEFT JOIN
                                (
                                    SELECT
                                        pfkey,
                                        pfcomcd
                                    FROM
                                        pfclass
                                    WHERE
                                        pfincode = 'VTAN'
                                )
                                pfclass
                                ON
                                    pfclass.pfkey = bil_acnt_wk.price_code
                            LEFT JOIN
                                (
                                    SELECT
                                        udddrgcode,
                                        pfcomcd
                                    FROM
                                        cpoe.uddrugpf
                                    WHERE
                                        uddpayself = 'V'
                                )
                                uddrugpf
                                ON
                                    uddrugpf.udddrgcode = substr( bil_acnt_wk.price_code, 4 )
                    )
            )
            )
        SELECT
            t1.*,
            CASE
                WHEN t1.hvtfincl = '2'
                    THEN '部分負擔'
                    ELSE t6.subsidy_type
            END AS subsidy_type_desc, -- 補助類別
            CASE
                WHEN t1.hvtfincl = '2'
                    THEN t3.payable_amt
                    ELSE NULL
            END            AS payable_amt      , -- 部分負擔合計
            t4.subsidy_amt AS total_subsidy_amt, -- 部分負擔補助總金額(V*W),總補助金額
            t5.fee_kind_desc                   , --無職榮 衛藥材 欄位
            t5.item_name_en                    , --無職榮 衛藥材 欄位
            t6.*                                 --無職榮 欄位
        FROM
            t1
            LEFT OUTER JOIN
                t3
                ON
                    t1.caseno = t3.caseno
            LEFT JOIN
                t4
                ON
                    t1.caseno       = t4.caseno
                    AND t3.fee_type = t4.fee_type
            LEFT JOIN
                t5
                ON
                    t1.caseno = t5.caseno
            LEFT JOIN
                t6
                ON
                    t1.caseno         = t6.caseno
                    AND t5.price_code = t6.price_code
                    AND t5.fee_kind   = t6.fee_kind
                    AND t5.start_date = t6.start_date
        WHERE
            (
                t1.hvtfincl IN ( '2' )
                AND t4.subsidy_amt IS NOT NULL
            )
            OR
            (
                t1.hvtfincl IN ( '1','3' )
                AND t6.subsidy_amt IS NOT NULL
            )
        ORDER BY
            CASE t1.hvtfincl
                WHEN '2'
                    THEN 1
                    ELSE 2
            END           ,
            t1.dischg_date,
            t1.admit_date ,
            t1.caseno     ,
            t5.fee_kind   ,
            t5.start_date
        ;
        
    END;
	PROCEDURE get_adm_med_income_list (
		p_start_report_date   IN    DATE,
		p_end_report_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.code_no     AS fee_type,
			                  t1.code_desc   AS fee_type_desc,
			                  t2.tot_amt     AS labi_amt,
			                  t3.tot_amt     AS civc_amt
		                  FROM
			                  (
				                  SELECT
					                  code_no,
					                  code_desc
				                  FROM
					                  bil_codedtl
				                  WHERE
					                  code_type = 'PFTYPE'
					                  AND
					                  code_no < '41'
			                  ) t1
			                  LEFT JOIN (
				                  SELECT
					                  fee_type,
					                  SUM (amt) AS tot_amt
				                  FROM
					                  bil_incommonth_report
				                  WHERE
					                  report_date BETWEEN p_start_report_date AND p_end_report_date
					                  AND
					                  fincl = 'LABI'
				                  GROUP BY
					                  fee_type
			                  ) t2 ON t1.code_no = t2.fee_type
			                  LEFT JOIN (
				                  SELECT
					                  fee_type,
					                  SUM (amt) AS tot_amt
				                  FROM
					                  bil_incommonth_report
				                  WHERE
					                  report_date BETWEEN p_start_report_date AND p_end_report_date
					                  AND
					                  fincl = 'CIVC'
				                  GROUP BY
					                  fee_type
			                  ) t3 ON t1.code_no = t3.fee_type
		                  ORDER BY
			                  fee_type;
	END;
	PROCEDURE get_adm_med_nor_deduct_list (
		p_start_report_date   IN    DATE,
		p_end_report_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.unit,
			                  t1.unit_desc,
			                  t2.tot_amt   AS labi_amt,
			                  t3.tot_amt   AS civc_amt
		                  FROM
			                  (
				                  SELECT DISTINCT
					                  bilkey     AS unit,
					                  bilnamec   AS unit_desc
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey IN (
						                  '6006',
						                  '9500',
						                  '9803',
						                  '9804',
						                  'EMPL',
						                  'HOSP',
						                  'VTAN'
					                  )
			                  ) t1
			                  LEFT JOIN (
				                  SELECT
					                  unit,
					                  SUM (amt) AS tot_amt
				                  FROM
					                  bil_incommonth_report
				                  WHERE
					                  report_date BETWEEN p_start_report_date AND p_end_report_date
					                  AND
					                  fincl = 'LABI'
				                  GROUP BY
					                  unit
			                  ) t2 ON t1.unit = t2.unit
			                  LEFT JOIN (
				                  SELECT
					                  unit,
					                  SUM (amt) AS tot_amt
				                  FROM
					                  bil_incommonth_report
				                  WHERE
					                  report_date BETWEEN p_start_report_date AND p_end_report_date
					                  AND
					                  fincl = 'CIVC'
				                  GROUP BY
					                  unit
			                  ) t3 ON t1.unit = t3.unit
		                  ORDER BY
			                  unit;
	END;
	PROCEDURE get_emg_med_income_list (
		p_start_report_date   IN    DATE,
		p_end_report_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.code_no     AS fee_type,
			                  t1.code_desc   AS fee_type_desc,
			                  t2.tot_amt     AS labi_amt,
			                  t3.tot_amt     AS civc_amt
		                  FROM
			                  (
				                  SELECT
					                  code_no,
					                  code_desc
				                  FROM
					                  bil_codedtl
				                  WHERE
					                  code_type = 'PFTYPE'
					                  AND
					                  code_no < '41'
			                  ) t1
			                  LEFT JOIN (
				                  SELECT
					                  fee_type,
					                  SUM (amt) AS tot_amt
				                  FROM
					                  emg_incommonth_report
				                  WHERE
					                  report_date BETWEEN p_start_report_date AND p_end_report_date
					                  AND
					                  fincl = 'LABI'
				                  GROUP BY
					                  fee_type
			                  ) t2 ON t1.code_no = t2.fee_type
			                  LEFT JOIN (
				                  SELECT
					                  fee_type,
					                  SUM (amt) AS tot_amt
				                  FROM
					                  emg_incommonth_report
				                  WHERE
					                  report_date BETWEEN p_start_report_date AND p_end_report_date
					                  AND
					                  fincl = 'CIVC'
				                  GROUP BY
					                  fee_type
			                  ) t3 ON t1.code_no = t3.fee_type
		                  ORDER BY
			                  fee_type;
	END;
	PROCEDURE get_emg_med_nor_deduct_list (
		p_start_report_date   IN    DATE,
		p_end_report_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.unit,
			                  t1.unit_desc,
			                  t2.tot_amt   AS labi_amt,
			                  t3.tot_amt   AS civc_amt
		                  FROM
			                  (
				                  SELECT DISTINCT
					                  bilkey     AS unit,
					                  bilnamec   AS unit_desc
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey IN (
						                  '6006',
						                  '9500',
						                  '9803',
						                  '9804',
						                  'EMPL',
						                  'HOSP',
						                  'VTAN'
					                  )
			                  ) t1
			                  LEFT JOIN (
				                  SELECT
					                  unit,
					                  SUM (amt) AS tot_amt
				                  FROM
					                  emg_incommonth_report
				                  WHERE
					                  report_date BETWEEN p_start_report_date AND p_end_report_date
					                  AND
					                  fincl = 'LABI'
				                  GROUP BY
					                  unit
			                  ) t2 ON t1.unit = t2.unit
			                  LEFT JOIN (
				                  SELECT
					                  unit,
					                  SUM (amt) AS tot_amt
				                  FROM
					                  emg_incommonth_report
				                  WHERE
					                  report_date BETWEEN p_start_report_date AND p_end_report_date
					                  AND
					                  fincl = 'CIVC'
				                  GROUP BY
					                  unit
			                  ) t3 ON t1.unit = t3.unit
		                  ORDER BY
			                  unit;
	END;
	PROCEDURE get_adm_cert_income_list (
		p_start_chargedate   IN    DATE,
		p_end_chargedate     IN    DATE,
		p_cursor             OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  hfinacl,
			                  service_bill_pkg.get_code_desc ('HFINACL1', hfinacl) AS hfinacl_desc,
			                  sum_amt
		                  FROM
			                  (
				                  SELECT
					                  bil_root.hfinacl,
					                  nvl (SUM (nvl (t1.total, 0)), 0) AS sum_amt
				                  FROM
					                  (
						                  SELECT
							                  caseno,
							                  total
						                  FROM
							                  abs_charge
						                  WHERE
							                  trunc (abs_charge.chargedate) BETWEEN p_start_chargedate AND p_end_chargedate
							                  AND
							                  abs_charge.in_billtemp = 'N'
					                  ) t1
					                  LEFT JOIN bil_root ON t1.caseno = bil_root.caseno
				                  GROUP BY
					                  bil_root.hfinacl
			                  )
		                  ORDER BY
			                  CASE
				                  WHEN substr (hfinacl, 1, 3) = 'NHI' THEN
					                  1
				                  ELSE
					                  2
			                  END,
			                  hfinacl;
	END;
	PROCEDURE get_emg_cert_income_list (
		p_start_create_time   IN    DATE,
		p_end_create_time     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  emg1fncl,
			                  service_bill_pkg.get_code_desc ('EMG1FNCL', emg1fncl) AS emg1fncl_desc,
			                  sum_amt
		                  FROM
			                  (
				                  SELECT
					                  pat_emg_casen.emg1fncl,
					                  nvl (SUM (nvl (t1.price, 0) * nvl (t1.amount, 0)), 0) AS sum_amt
				                  FROM
					                  (
						                  SELECT
							                  CASE
								                  WHEN abstype IN (
									                  'HC',
									                  'HE',
									                  'DV'
								                  ) THEN
									                  absno
								                  ELSE
									                  (
										                  SELECT
											                  MAX (ecaseno)
										                  FROM
											                  common.pat_emg_casen
										                  WHERE
											                  emghhist = absno
									                  )
							                  END AS caseno,
							                  price,
							                  amount
						                  FROM
							                  abs_emg_charge
						                  WHERE
							                  trunc (create_time) BETWEEN p_start_create_time AND p_end_create_time
							                  AND
							                  is_charge = 'Y'
					                  ) t1
					                  LEFT JOIN common.pat_emg_casen ON t1.caseno = pat_emg_casen.ecaseno
				                  GROUP BY
					                  pat_emg_casen.emg1fncl
			                  )
		                  ORDER BY
			                  CASE
				                  WHEN emg1fncl = '7' THEN
					                  1
				                  ELSE
					                  2
			                  END;
	END;
	PROCEDURE get_adm_med_spc_ded_dtl_list (
		p_start_creation_date   IN    DATE,
		p_end_creation_date     IN    DATE,
		p_cursor                OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.bltounit,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = t1.bltounit
					                  AND
					                  ROWNUM = 1
			                  ) AS bilnamec,
			                  nvl (t2.unit_amt, 0) AS unit_case_amt,
			                  bil_root.caseno,
			                  bil_root.hpatnum,
			                  bil_root.hnamec,
			                  bil_root.admit_date,
			                  bil_root.dischg_date,
			                  bil_root.hfinacl,
			                  service_bill_pkg.get_code_desc ('HFINACL1', hfinacl) AS hfinacl_desc
		                  FROM
			                  (
				                  SELECT DISTINCT
					                  bltounit
				                  FROM
					                  bil_adjst_mst
				                  WHERE
					                  bltounit IN (
						                  '9100',
						                  '9200',
						                  '9250',
						                  '9300'
					                  )
					                  AND
					                  trunc (creation_date) BETWEEN trunc (p_start_creation_date) AND trunc (p_end_creation_date)
			                  ) t1
			                  LEFT JOIN (
				                  SELECT
					                  bltounit,
					                  caseno,
					                  SUM (nvl (after_to_amt, 0)) AS unit_amt
				                  FROM
					                  bil_adjst_mst
				                  WHERE
					                  bltounit IN (
						                  '9100',
						                  '9200',
						                  '9250',
						                  '9300'
					                  )
					                  AND
					                  trunc (creation_date) BETWEEN trunc (p_start_creation_date) AND trunc (p_end_creation_date)
				                  GROUP BY
					                  bltounit,
					                  caseno
			                  ) t2 ON t1.bltounit = t2.bltounit
			                  LEFT JOIN bil_root ON t2.caseno = bil_root.caseno
		                  ORDER BY
			                  t1.bltounit,
			                  t2.caseno;
	END;
	PROCEDURE get_emg_med_spc_ded_dtl_list (
		p_start_created_date   IN    DATE,
		p_end_created_date     IN    DATE,
		p_cursor               OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  t1.bltounit,
			                  (
				                  SELECT
					                  bilnamec
				                  FROM
					                  bil_discmst
				                  WHERE
					                  bilkey = t1.bltounit
					                  AND
					                  ROWNUM = 1
			                  ) AS bilnamec,
			                  nvl (t2.unit_amt, 0) AS unit_case_amt,
			                  pat_emg_casen.ecaseno,
			                  pat_emg_casen.emghhist,
			                  service_bill_pkg.get_pat_name_ch (emghhist) AS pat_name_ch,
			                  pat_emg_casen.emgdt,
			                  pat_emg_casen.emglvdt,
			                  pat_emg_casen.emg1fncl,
			                  service_bill_pkg.get_code_desc ('EMG1FNCL', emg1fncl) AS emg1fncl_desc
		                  FROM
			                  (
				                  SELECT DISTINCT
					                  bltounit
				                  FROM
					                  emg_bil_adjst_mst
				                  WHERE
					                  bltounit IN (
						                  '9100',
						                  '9200',
						                  '9250',
						                  '9300'
					                  )
					                  AND
					                  trunc (created_date) BETWEEN trunc (p_start_created_date) AND trunc (p_end_created_date)
			                  ) t1
			                  LEFT JOIN (
				                  SELECT
					                  bltounit,
					                  caseno,
					                  SUM (nvl (after_to_amt, 0)) AS unit_amt
				                  FROM
					                  emg_bil_adjst_mst
				                  WHERE
					                  bltounit IN (
						                  '9100',
						                  '9200',
						                  '9250',
						                  '9300'
					                  )
					                  AND
					                  trunc (created_date) BETWEEN trunc (p_start_created_date) AND trunc (p_end_created_date)
				                  GROUP BY
					                  bltounit,
					                  caseno
			                  ) t2 ON t1.bltounit = t2.bltounit
			                  LEFT JOIN common.pat_emg_casen ON t2.caseno = pat_emg_casen.ecaseno
		                  ORDER BY
			                  t1.bltounit,
			                  t2.caseno;
	END;
	PROCEDURE get_dea_notify_cert_no_list (
		p_notify_date   IN    DATE,
		p_cursor        OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  absno
		                  FROM
			                  abs_root
		                  WHERE
			                  abstype = 'DC'
			                  AND
			                  (trunc (create_date) BETWEEN (p_notify_date - 7) AND (p_notify_date - 1)
			                   OR
			                   trunc (update_date) BETWEEN (p_notify_date - 7) AND (p_notify_date - 1)
			                   OR
			                   (dea IS NULL
			                    AND
			                    trunc (certprdt) BETWEEN (p_notify_date - 7) AND (p_notify_date - 1)
			                    AND
			                    trunc (create_date) >= add_months (p_notify_date, - 6)));
	END;
	PROCEDURE get_amb_cashier_dtl_list (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  caseno,
			                  chart_no AS hpatnum,
			                  (
				                  SELECT
					                  hnamec
				                  FROM
					                  common.pat_basic
				                  WHERE
					                  hhisnum = t1.chart_no
			                  ) AS hnamec,
			                  charge_type,
			                  service_bill_pkg.get_code_desc ('PayType', charge_type) AS charge_type_desc,
			                  charge_amt,
			                  operater_id,
			                  operater_name,
			                  operater_date,
			                  service_bill_pkg.get_emp_dept_no (operater_id) AS operater_dept_no,
			                  fee_kind
		                  FROM
			                  (
				                  SELECT
					                  caseno,
					                  chart_no,
					                  charge_type,
					                  charge_amt,
					                  operater_id,
					                  operater_name,
					                  operater_date,
					                  fee_kind
				                  FROM
					                  ambulance_charge
				                  WHERE
					                  trunc (operater_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  charge_type = '1'
				                  UNION ALL
				                  SELECT
					                  ambulance_charge.caseno,
					                  ambulance_charge.chart_no,
					                  ambulance_charge.charge_type,
					                  ambulance_charge.charge_amt,
					                  ambulance_charge.operater_id,
					                  ambulance_charge.operater_name,
					                  ambulance_charge.operater_date,
					                  ambulance_charge.fee_kind
				                  FROM
					                  ambulance_charge left
					                  JOIN bil_payservicenotice ON ambulance_charge.seqno = bil_payservicenotice.pr_key2
				                  WHERE
					                  bil_payservicenotice.valuedate BETWEEN TO_CHAR (p_start_charge_date, 'YYYYMMDD') AND TO_CHAR (p_end_charge_date
					                  , 'YYYYMMDD')
					                  AND
					                  ambulance_charge.charge_type = '3'
			                  ) t1
		                  ORDER BY
			                  operater_date;
	END;
	PROCEDURE get_amb_acct_info_list (
		p_cursor OUT SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  fee_kind,
			                  account_code,
			                  kind_desc
		                  FROM
			                  bil_feekindbas
		                  WHERE
			                  fee_kind LIKE 'AMBU5%'
			                  AND
			                  enabled = 'Y'
		                  ORDER BY
			                  fee_kind;
	END;

	-- 住院現金明細
	PROCEDURE get_adm_cash_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  CASE
				                  WHEN bil_root.dischg_date IS NULL
				                       OR
				                       trunc (bil_root.dischg_date, 'MM') >= trunc (t1.charge_date, 'MM')
				                       OR
				                       t1.sign_mark = '-'
				                       OR
				                       t1.source = 'ABS_CHARGE' THEN
					                  '1'
				                  WHEN trunc (bil_root.dischg_date, 'MM') < trunc (add_months (t1.charge_date, - 6), 'MM') THEN
					                  (
						                  CASE
							                  WHEN service_bill_report_pkg.check_has_been_bad_debt ('A', t1.caseno) = 'Y' THEN
								                  '4'
							                  ELSE
								                  '3'
						                  END
					                  )
				                  ELSE
					                  '2'
			                  END AS acc_type,
			                  t1.source,
			                  t1.caseno,
			                  t1.charge_date,
			                  t1.cashier_emp_id,
			                  service_bill_pkg.get_emp_name_ch (t1.cashier_emp_id) AS cashier_name,
			                  service_bill_pkg.get_emp_dept_no (t1.cashier_emp_id) AS cashier_dept_no,
			                  service_bill_pkg.get_emp_dept_name (t1.cashier_emp_id) AS cashier_dept_name,
			                  t1.charge_type,
			                  service_bill_pkg.get_code_desc ('PayType', t1.charge_type) AS charge_type_desc,
			                  t1.charge_amt,
			                  bil_root.hfinacl,
			                  service_bill_pkg.get_code_desc ('HFINACL1', bil_root.hfinacl) AS hfinacl_desc,
			                  bil_root.dischg_date,
			                  pat_basic.hhisnum,
			                  pat_basic.hnamec
		                  FROM
			                  (
				                  SELECT
					                  'BIL_BILLMST' AS source,
					                  caseno,
					                  last_update_date   AS charge_date,
					                  last_updated_by    AS cashier_emp_id,
					                  pat_kind           AS charge_type,
					                  CASE
						                  WHEN pat_paid_amt >= 0 THEN
							                  pat_paid_amt
						                  ELSE
							                  (pre_paid_amt + pat_paid_amt)
					                  END AS charge_amt,
					                  CASE
						                  WHEN pat_paid_amt >= 0 THEN
							                  '+'
						                  ELSE
							                  '-'
					                  END AS sign_mark
				                  FROM
					                  bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status = 'Y'
					                  AND
					                  pat_kind = '1'
				                  UNION ALL
				                  SELECT
					                  'BIL_BILLMST',
					                  caseno,
					                  last_update_date,
					                  last_updated_by,
					                  pat_kind AS charge_type,
					                  - 1 * pre_paid_amt,
					                  '-'
				                  FROM
					                  bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status = 'Y'
					                  AND
					                  pat_kind = '1'
					                  AND
					                  pat_paid_amt < 0
				                  UNION ALL
				                  SELECT
					                  'ABS_CHARGE',
					                  caseno,
					                  chargedate,
					                  chargeuser,
					                  '1',
					                  total,
					                  CASE
						                  WHEN total >= 0 THEN
							                  '+'
						                  ELSE
							                  '-'
					                  END
				                  FROM
					                  abs_charge
				                  WHERE
					                  trunc (chargedate) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  in_billtemp = 'N'
			                  ) t1
			                  LEFT JOIN common.pat_adm_case ON t1.caseno = pat_adm_case.hcaseno
			                  LEFT JOIN bil_root ON pat_adm_case.hcaseno = bil_root.caseno
			                  LEFT JOIN common.pat_basic ON pat_adm_case.hhisnum = pat_basic.hhisnum
		                  ORDER BY
			                  t1.charge_date;
	END;

	-- 住院電子交易明細
	PROCEDURE get_adm_epay_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  CASE
				                  WHEN bil_root.dischg_date IS NULL
				                       OR
				                       trunc (bil_root.dischg_date, 'MM') >= trunc (
					                       CASE
						                       WHEN t1.charge_type IN (
							                       '2', '3'
						                       ) THEN
							                       t1.value_date
						                       ELSE
							                       t1.charge_date
					                       END, 'MM')
				                       OR
				                       t1.sign_mark = '-' THEN
					                  '1'
				                  WHEN trunc (bil_root.dischg_date, 'MM') < trunc (add_months (t1.charge_date, - 6), 'MM') THEN
					                  (
						                  CASE
							                  WHEN service_bill_report_pkg.check_has_been_bad_debt ('A', t1.caseno) = 'Y' THEN
								                  '4'
							                  ELSE
								                  '3'
						                  END
					                  )
				                  ELSE
					                  '2'
			                  END AS acc_type,
			                  t1.source,
			                  t1.caseno,
			                  t1.charge_date,
			                  t1.cashier_emp_id,
			                  service_bill_pkg.get_emp_name_ch (t1.cashier_emp_id) AS cashier_name,
			                  service_bill_pkg.get_emp_dept_no (t1.cashier_emp_id) AS cashier_dept_no,
			                  service_bill_pkg.get_emp_dept_name (t1.cashier_emp_id) AS cashier_dept_name,
			                  t1.charge_type,
			                  service_bill_pkg.get_code_desc ('PayType', t1.charge_type) AS charge_type_desc,
			                  t1.charge_amt,
			                  bil_root.hfinacl,
			                  service_bill_pkg.get_code_desc ('HFINACL1', bil_root.hfinacl) AS hfinacl_desc,
			                  bil_root.dischg_date,
			                  pat_basic.hhisnum,
			                  pat_basic.hnamec
		                  FROM
			                  (
				                  SELECT
					                  'BIL_BILLMST' AS source,
					                  caseno,
					                  last_update_date   AS charge_date,
					                  last_update_date   AS value_date,
					                  last_updated_by    AS cashier_emp_id,
					                  pat_kind           AS charge_type,
					                  CASE
						                  WHEN pat_paid_amt >= 0 THEN
							                  pat_paid_amt
						                  ELSE
							                  (pre_paid_amt + pat_paid_amt)
					                  END AS charge_amt,
					                  CASE
						                  WHEN pat_paid_amt >= 0 THEN
							                  '+'
						                  ELSE
							                  '-'
					                  END AS sign_mark
				                  FROM
					                  bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status = 'Y'
					                  AND
					                  pat_kind IN (
						                  '4',
						                  '5'
					                  )
				                  UNION ALL
				                  SELECT
					                  'BIL_BILLMST',
					                  caseno,
					                  last_update_date,
					                  last_update_date,
					                  last_updated_by,
					                  pat_kind AS charge_type,
					                  - 1 * pre_paid_amt,
					                  '-'
				                  FROM
					                  bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status = 'Y'
					                  AND
					                  pat_kind IN (
						                  '4',
						                  '5'
					                  )
					                  AND
					                  pat_paid_amt < 0
				                  UNION ALL
				                  SELECT
					                  'BIL_PAYSERVICENOTICE',
					                  bil_epay_log.caseno,
					                  bil_epay_log.creation_date,
					                  TO_DATE (bil_payservicenotice.valuedate, 'YYYYMMDD'),
					                  bil_epay_log.created_by,
					                  bil_epay_log.pat_kind,
					                  CASE
						                  WHEN bil_epay_log.pat_kind = '3'
						                       AND
						                       (pos_emg IS NOT NULL
						                        OR
						                        pos_ambu IS NOT NULL) THEN
							                  bil_epay_log.pos_adm
						                  ELSE
							                  bil_payservicenotice.txamount * 0.01
					                  END,
					                  bil_payservicenotice.amtsign
				                  FROM
					                  bil_payservicenotice,
					                  bil_epay_log
				                  WHERE
					                  bil_payservicenotice.pr_key2 = bil_epay_log.seqno
					                  AND
					                  bil_payservicenotice.rec_status = 'Y'
					                  AND
					                  bil_payservicenotice.valuedate BETWEEN TO_CHAR (p_start_charge_date, 'YYYYMMDD') AND TO_CHAR (p_end_charge_date
					                  , 'YYYYMMDD')
					                  AND
					                  bil_epay_log.sysid = 'adm'
					                  AND
					                  bil_epay_log.pat_kind IN (
						                  '2',
						                  '3'
					                  )
			                  ) t1
			                  LEFT JOIN common.pat_adm_case ON t1.caseno = pat_adm_case.hcaseno
			                  LEFT JOIN bil_root ON pat_adm_case.hcaseno = bil_root.caseno
			                  LEFT JOIN common.pat_basic ON pat_adm_case.hhisnum = pat_basic.hhisnum
		                  ORDER BY
			                  t1.charge_date;
	END;

	-- 急診現金明細
	PROCEDURE get_emg_cash_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  CASE
				                  WHEN pat_emg_casen.emglvdt IS NULL
				                       OR
				                       trunc (pat_emg_casen.emglvdt, 'MM') >= trunc (t1.charge_date, 'MM')
				                       OR
				                       t1.sign_mark = '-' THEN
					                  '1'
				                  WHEN trunc (pat_emg_casen.emglvdt, 'MM') < trunc (add_months (t1.charge_date, - 6), 'MM') THEN
					                  (
						                  CASE
							                  WHEN service_bill_report_pkg.check_has_been_bad_debt ('E', t1.caseno) = 'Y' THEN
								                  '4'
							                  ELSE
								                  '3'
						                  END
					                  )
				                  ELSE
					                  '2'
			                  END AS acc_type,
			                  t1.source,
			                  t1.caseno,
			                  t1.charge_date,
			                  t1.cashier_emp_id,
			                  service_bill_pkg.get_emp_name_ch (t1.cashier_emp_id) AS cashier_name,
			                  service_bill_pkg.get_emp_dept_no (t1.cashier_emp_id) AS cashier_dept_no,
			                  service_bill_pkg.get_emp_dept_name (t1.cashier_emp_id) AS cashier_dept_name,
			                  t1.charge_type,
			                  service_bill_pkg.get_code_desc ('PayType', t1.charge_type) AS charge_type_desc,
			                  t1.charge_amt,
			                  pat_emg_casen.emg1fncl,
			                  service_bill_pkg.get_code_desc ('EMG1FNCL', pat_emg_casen.emg1fncl) AS emg1fncl_desc,
			                  pat_emg_casen.emglvdt,
			                  pat_basic.hhisnum,
			                  pat_basic.hnamec
		                  FROM
			                  (
				                  SELECT
					                  'EMG_BIL_BILLMST' AS source,
					                  caseno,
					                  last_update_date   AS charge_date,
					                  last_updated_by    AS cashier_emp_id,
					                  pat_kind           AS charge_type,
					                  pat_paid_amt       AS charge_amt,
					                  CASE
						                  WHEN refund_amt IS NULL
						                       OR
						                       refund_amt = 0 THEN
							                  '+'
						                  ELSE
							                  '-'
					                  END AS sign_mark
				                  FROM
					                  emg_bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status IN (
						                  'Y',
						                  'C'
					                  )
					                  AND
					                  pat_kind = '1'
				                  UNION ALL
				                  SELECT
					                  'EMG_BIL_BILLMST',
					                  caseno,
					                  last_update_date,
					                  last_updated_by,
					                  pat_kind,
					                  - 1 * (pat_paid_amt + refund_amt),
					                  '-'
				                  FROM
					                  emg_bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status IN (
						                  'Y',
						                  'C'
					                  )
					                  AND
					                  pat_kind = '1'
					                  AND
					                  refund_amt > 0
			                  ) t1
			                  LEFT JOIN common.pat_emg_casen ON t1.caseno = pat_emg_casen.ecaseno
			                  LEFT JOIN common.pat_basic ON pat_emg_casen.emghhist = pat_basic.hhisnum
		                  ORDER BY
			                  t1.charge_date;
	END;

     -- 急診電子交易明細
	PROCEDURE get_emg_epay_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  CASE
				                  WHEN pat_emg_casen.emglvdt IS NULL
				                       OR
				                       trunc (pat_emg_casen.emglvdt, 'MM') >= trunc (t1.charge_date, 'MM')
				                       OR
				                       t1.sign_mark = '-' THEN
					                  '1'
				                  WHEN trunc (pat_emg_casen.emglvdt, 'MM') < trunc (add_months (t1.charge_date, - 6), 'MM') THEN
					                  (
						                  CASE
							                  WHEN service_bill_report_pkg.check_has_been_bad_debt ('E', t1.caseno) = 'Y' THEN
								                  '4'
							                  ELSE
								                  '3'
						                  END
					                  )
				                  ELSE
					                  '2'
			                  END AS acc_type,
			                  t1.source,
			                  t1.caseno,
			                  t1.charge_date,
			                  t1.cashier_emp_id,
			                  service_bill_pkg.get_emp_name_ch (t1.cashier_emp_id) AS cashier_name,
			                  service_bill_pkg.get_emp_dept_no (t1.cashier_emp_id) AS cashier_dept_no,
			                  service_bill_pkg.get_emp_dept_name (t1.cashier_emp_id) AS cashier_dept_name,
			                  t1.charge_type,
			                  service_bill_pkg.get_code_desc ('PayType', t1.charge_type) AS charge_type_desc,
			                  t1.charge_amt,
			                  pat_emg_casen.emg1fncl,
			                  service_bill_pkg.get_code_desc ('EMG1FNCL', pat_emg_casen.emg1fncl) AS emg1fncl_desc,
			                  pat_emg_casen.emglvdt,
			                  pat_basic.hhisnum,
			                  pat_basic.hnamec
		                  FROM
			                  (
				                  SELECT
					                  'EMG_BIL_BILLMST' AS source,
					                  caseno,
					                  last_update_date   AS charge_date,
					                  last_updated_by    AS cashier_emp_id,
					                  pat_kind           AS charge_type,
					                  pat_paid_amt       AS charge_amt,
					                  '+' AS sign_mark
				                  FROM
					                  emg_bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status IN (
						                  'Y',
						                  'C'
					                  )
					                  AND
					                  pat_kind IN (
						                  '4',
						                  '5',
						                  '6',
						                  '7'
					                  )
					                  AND
					                  (refund_amt IS NULL
					                   OR
					                   refund_amt = 0)
				                  UNION ALL
				                  SELECT
					                  'EMG_BIL_BILLMST',
					                  caseno,
					                  last_update_date,
					                  last_updated_by,
					                  pat_kind,
					                  - 1 * refund_amt,
					                  '-'
				                  FROM
					                  emg_bil_billmst
				                  WHERE
					                  trunc (last_update_date) BETWEEN p_start_charge_date AND p_end_charge_date
					                  AND
					                  rec_status IN (
						                  'Y',
						                  'C'
					                  )
					                  AND
					                  pat_kind IN (
						                  '4',
						                  '5',
						                  '6',
						                  '7'
					                  )
					                  AND
					                  refund_amt > 0
				                  UNION ALL
				                  SELECT
					                  'BIL_PAYSERVICENOTICE',
					                  CASE
						                  WHEN bil_epay_log.sysid = 'adm' THEN
							                  (
								                  SELECT
									                  in_caseno
								                  FROM
									                  common.pat_adm_case
								                  WHERE
									                  hcaseno = bil_epay_log.caseno
							                  )
						                  ELSE
							                  bil_epay_log.caseno
					                  END,
					                  bil_epay_log.creation_date,
					                  bil_epay_log.created_by,
					                  bil_epay_log.pat_kind,
					                  CASE
						                  WHEN bil_epay_log.sysid = 'adm' THEN
							                  bil_epay_log.pos_emg
						                  ELSE
							                  bil_payservicenotice.txamount * 0.01
					                  END,
					                  bil_payservicenotice.amtsign
				                  FROM
					                  bil_payservicenotice,
					                  bil_epay_log
				                  WHERE
					                  bil_payservicenotice.pr_key2 = bil_epay_log.seqno
					                  AND
					                  bil_payservicenotice.rec_status = 'Y'
					                  AND
					                  bil_payservicenotice.valuedate BETWEEN TO_CHAR (p_start_charge_date, 'YYYYMMDD') AND TO_CHAR (p_end_charge_date
					                  , 'YYYYMMDD')
					                  AND
					                  (bil_epay_log.sysid = 'emg'
					                   OR
					                   bil_epay_log.sysid = 'adm'
					                   AND
					                   bil_epay_log.pos_emg IS NOT NULL)
					                  AND
					                  bil_epay_log.pat_kind IN (
						                  '2',
						                  '3'
					                  )
			                  ) t1
			                  LEFT JOIN common.pat_emg_casen ON t1.caseno = pat_emg_casen.ecaseno
			                  LEFT JOIN common.pat_basic ON pat_emg_casen.emghhist = pat_basic.hhisnum
		                  ORDER BY
			                  t1.charge_date;
	END;

	-- 急診證明書明細
	PROCEDURE get_emg_cert_dtl (
		p_start_charge_date   IN    DATE,
		p_end_charge_date     IN    DATE,
		p_cursor              OUT   SYS_REFCURSOR
	) IS
	BEGIN
		OPEN p_cursor FOR SELECT
			                  abstype,
			                  absno,
			                  absseq,
			                  create_time      AS charge_date,
			                  creator_cardid   AS cashier_emp_id,
			                  service_bill_pkg.get_emp_name_ch (creator_cardid) AS cashier_name,
			                  service_bill_pkg.get_emp_dept_no (creator_cardid) AS cashier_dept_no,
			                  service_bill_pkg.get_emp_dept_name (creator_cardid) AS cashier_dept_name,
			                  '1' AS charge_type,
			                  service_bill_pkg.get_code_desc ('PayType', '1') AS charge_type_desc,
			                  amount * price AS charge_amt
		                  FROM
			                  abs_emg_charge
		                  WHERE
			                  trunc (create_time) BETWEEN p_start_charge_date AND p_end_charge_date
			                  AND
			                  is_charge = 'Y'
		                  ORDER BY
			                  create_time;
	END;
END service_bill_report_pkg;
/
