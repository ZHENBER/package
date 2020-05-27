CREATE OR REPLACE PACKAGE biling_process_pkg IS
	-- 開立帳單
	PROCEDURE newbilingbil (
		pcaseno    IN    VARCHAR2,
		pstatus    IN    VARCHAR2,
		plogid     IN    VARCHAR2,
		pmessage   OUT   VARCHAR2
	);

	-- 開立帳單
	PROCEDURE create_adm_bill (
		p_caseno            IN    VARCHAR2,
		p_paid_type         IN    VARCHAR2,
		p_unitcode          IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_out_msg           OUT   VARCHAR2
	);

	-- 定期開立帳單
	PROCEDURE fivedaybilingbil (
		pbilldate IN DATE
	);

	-- 定期開立帳單
	PROCEDURE period_create_adm_bill (
		p_out_msg OUT VARCHAR2
	);

	-- 重入固定費用
	PROCEDURE changebildate (
		pcaseno   IN    VARCHAR2,
		pdate     IN    VARCHAR2,
		preturn   OUT   VARCHAR2
	);

	-- 重入固定費用
	PROCEDURE change_daily_fee (
		p_caseno     IN    VARCHAR2,
		p_bil_date   IN    DATE,
		p_out_msg    OUT   VARCHAR2
	);

	-- 出院通知
	PROCEDURE informbatch (
		pcaseno     IN   VARCHAR2,
		pdate       IN   VARCHAR2,
		pdiettype   IN   VARCHAR2
	);

	-- 出院通知
	PROCEDURE inform_batch (
		p_caseno            IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_out_msg           OUT   VARCHAR2
	);

	-- 14天再入院合併
	PROCEDURE comp14days (
		pcaseno IN VARCHAR2
	);

	-- 14天再入院合併
	PROCEDURE merge_admit_within_14days (
		p_caseno    IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	);

	-- 清除帳務
	PROCEDURE clearbillingdata (
		pcaseno       IN    VARCHAR2,
		poutmessage   OUT   VARCHAR2
	);

	-- 清除帳務
	PROCEDURE clean_billing_data (
		p_caseno    IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	);

	-- 取得印表機邏輯 ID
	FUNCTION getprtlogid (
		pcaseno VARCHAR2
	) RETURN VARCHAR2;

	-- 取得印表機邏輯 ID
	FUNCTION get_prt_logid (
		p_caseno VARCHAR2
	) RETURN VARCHAR2;

	-- 印單
	PROCEDURE print_informbill (
		pcaseno    IN    VARCHAR2,
		pmessage   OUT   VARCHAR2
	);

	-- 印單
	PROCEDURE inform_print (
		p_caseno    IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	);
END;

/


CREATE OR REPLACE PACKAGE BODY biling_process_pkg IS
	-- 開立帳單
	PROCEDURE newbilingbil (
		pcaseno    IN    VARCHAR2,
		pstatus    IN    VARCHAR2,
		plogid     IN    VARCHAR2,
		pmessage   OUT   VARCHAR2
	) IS
		rec_bil_billmst      bil_billmst%rowtype;
		rec_new_print_cpoe   shared.new_print_cpoe%rowtype;
	BEGIN
		create_adm_bill (pcaseno, pstatus, 'CIVC', 'billing', pmessage);

		-- 列印住院帳單
		SELECT
			*
		INTO rec_new_print_cpoe
		FROM
			shared.new_print_cpoe
		WHERE
			logid =
				CASE
					WHEN plogid = 'BR' THEN
						'W76'
					ELSE
						plogid
				END
			AND
			ROWNUM = 1;
		bil_call_report (pcaseno, 'http://oracleas.vghtc.gov.tw:7780/reports/rwservlet?' || 'userid=billing/billing@hissp1' || '&destype=MQPSC'
		|| '&desname=orderId@0.0.0.0@' || rec_new_print_cpoe.prtid || '@TRAY66@H@66@PSC' || '&report=BIL5110_txt.rdf' || '&arg_caseno='
		|| pcaseno, '住院帳單');
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (dbms_utility.format_error_backtrace || dbms_utility.format_error_stack);
	END;

	-- 開立帳單
	PROCEDURE create_adm_bill (
		p_caseno            IN    VARCHAR2,
		p_paid_type         IN    VARCHAR2,
		p_unitcode          IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_out_msg           OUT   VARCHAR2
	) IS
		CURSOR cur_bil_feemst (
			p_caseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_feemst
		WHERE
			caseno = p_caseno;
		CURSOR cur_bil_feedtl (
			p_caseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_feedtl
		WHERE
			caseno = p_caseno
		ORDER BY
			fee_type DESC;
		CURSOR cur_bil_billmst (
			p_caseno     VARCHAR2,
			p_unitcode   VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_billmst
		WHERE
			caseno = p_caseno
			AND
			unitcode = p_unitcode
		ORDER BY
			dischg_bill_no DESC;
		CURSOR cur_bil_debt_rec (
			p_caseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_debt_rec
		WHERE
			caseno = p_caseno;
		rec_pat_adm_case        common.pat_adm_case%rowtype;
		rec_bil_root            bil_root%rowtype;
		rec_bil_billmst         bil_billmst%rowtype;
		rec_bil_billdtl         bil_billdtl%rowtype;
		rec_bil_feemst          bil_feemst%rowtype;
		rec_bil_feedtl          bil_feedtl%rowtype;
		rec_bil_debt_rec        bil_debt_rec%rowtype;
		rec_biling_spl_errlog   biling_spl_errlog%rowtype;
		v_total_amt             bil_feedtl.total_amt%TYPE := 0;
		v_pre_paid_amt          bil_billmst.pre_paid_amt%TYPE := 0;
	BEGIN
		SELECT
			*
		INTO rec_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = p_caseno;
		SELECT
			*
		INTO rec_bil_root
		FROM
			bil_root
		WHERE
			caseno = p_caseno;

		-- 欠款註記不提示的 case 不執行重開帳單（不產生退費帳單）
		OPEN cur_bil_debt_rec (rec_pat_adm_case.hcaseno);
		FETCH cur_bil_debt_rec INTO rec_bil_debt_rec;
		CLOSE cur_bil_debt_rec;
		IF rec_bil_debt_rec.display_flag = 'N' THEN
			p_out_msg := '欠款註記不提示，不重開帳單';
			return;
		END IF;

		-- 重算帳款
		IF rec_bil_root.created_by NOT IN (
			'No_Calculate',
			'HIS'
		) THEN
			importtointpatadmcase (rec_pat_adm_case.hcaseno);
			biling_calculate_pkg.main_process (rec_pat_adm_case.hcaseno, p_operator_emp_id, p_out_msg);
			IF p_out_msg != '0' THEN
				return;
			END IF;
		END IF;

		-- 計算應繳總額
		OPEN cur_bil_feedtl (rec_pat_adm_case.hcaseno);
		LOOP
			FETCH cur_bil_feedtl INTO rec_bil_feedtl;
			EXIT WHEN cur_bil_feedtl%notfound;
			IF rec_bil_feedtl.pfincode = p_unitcode THEN
				v_total_amt := v_total_amt + rec_bil_feedtl.total_amt;
			END IF;
		END LOOP;
		CLOSE cur_bil_feedtl;

		-- 計算已繳總額
		OPEN cur_bil_billmst (rec_pat_adm_case.hcaseno, p_unitcode);
		LOOP
			FETCH cur_bil_billmst INTO rec_bil_billmst;
			EXIT WHEN cur_bil_billmst%notfound;
			IF rec_bil_billmst.rec_status = 'Y' THEN
				v_pre_paid_amt := v_pre_paid_amt + rec_bil_billmst.pat_paid_amt;
			END IF;
		END LOOP;
		CLOSE cur_bil_billmst;

		-- 取得帳款主檔
		OPEN cur_bil_feemst (rec_pat_adm_case.hcaseno);
		FETCH cur_bil_feemst INTO rec_bil_feemst;
		CLOSE cur_bil_feemst;

		-- 產生帳單主檔
		rec_bil_billmst                    := NULL;
		rec_bil_billmst.dischg_bill_no     := biling_seqno_pkg.getseqno ('BilListSeq', SYSDATE);
		rec_bil_billmst.caseno             := rec_pat_adm_case.hcaseno;
		rec_bil_billmst.hpatnum            := rec_pat_adm_case.hhisnum;
		rec_bil_billmst.issue_date         := SYSDATE;
		rec_bil_billmst.paid_flag          := 'N';
		rec_bil_billmst.paid_type          := p_paid_type;
		rec_bil_billmst.st_date            := rec_bil_feemst.st_date;
		rec_bil_billmst.end_date           := rec_bil_feemst.end_date;
		rec_bil_billmst.emg_bed_days       := rec_bil_feemst.emg_bed_days;
		rec_bil_billmst.emg_exp_amt1       := rec_bil_feemst.emg_exp_amt1;
		rec_bil_billmst.emg_pay_amt1       := rec_bil_feemst.emg_pay_amt1;
		rec_bil_billmst.emg_exp_amt2       := rec_bil_feemst.emg_exp_amt2;
		rec_bil_billmst.emg_pay_amt2       := rec_bil_feemst.emg_pay_amt2;
		rec_bil_billmst.emg_exp_amt3       := rec_bil_feemst.emg_exp_amt3;
		rec_bil_billmst.emg_pay_amt3       := rec_bil_feemst.emg_pay_amt3;
		rec_bil_billmst.emg_exp_amt4       := rec_bil_feemst.emg_exp_amt4;
		rec_bil_billmst.emg_pay_amt4       := rec_bil_feemst.emg_pay_amt4;
		rec_bil_billmst.chron_bed_days     := rec_bil_feemst.chron_bed_days;
		rec_bil_billmst.chron_exp_amt1     := rec_bil_feemst.chron_exp_amt1;
		rec_bil_billmst.chron_pay_amt1     := rec_bil_feemst.chron_pay_amt1;
		rec_bil_billmst.chron_exp_amt2     := rec_bil_feemst.chron_exp_amt2;
		rec_bil_billmst.chron_pay_amt2     := rec_bil_feemst.chron_pay_amt2;
		rec_bil_billmst.chron_exp_amt3     := rec_bil_feemst.chron_exp_amt3;
		rec_bil_billmst.chron_pay_amt3     := rec_bil_feemst.chron_pay_amt3;
		rec_bil_billmst.chron_exp_amt4     := rec_bil_feemst.chron_exp_amt4;
		rec_bil_billmst.chron_pay_amt4     := rec_bil_feemst.chron_pay_amt4;
		rec_bil_billmst.tot_self_amt       := rec_bil_feemst.tot_self_amt;
		rec_bil_billmst.tot_gl_amt         := rec_bil_feemst.tot_gl_amt;
		rec_bil_billmst.credit_amt         := rec_bil_feemst.credit_amt;
		rec_bil_billmst.pre_paid_amt       := v_pre_paid_amt;
		rec_bil_billmst.total_amt          := round (v_total_amt - v_pre_paid_amt);
		rec_bil_billmst.created_by         := p_operator_emp_id;
		rec_bil_billmst.creation_date      := SYSDATE;
		rec_bil_billmst.last_updated_by    := p_operator_emp_id;
		rec_bil_billmst.last_update_date   := SYSDATE;
		rec_bil_billmst.rec_status         := 'N';
		rec_bil_billmst.fncl               := rec_pat_adm_case.hfinancl;
		rec_bil_billmst.unitcode           := p_unitcode;
		UPDATE bil_billmst
		SET
			rec_status = 'C'
		WHERE
			caseno = rec_pat_adm_case.hcaseno
			AND
			rec_status = 'N'
			AND
			unitcode = p_unitcode;
		INSERT INTO bil_billmst VALUES rec_bil_billmst;

		-- 產生帳單明細檔
		OPEN cur_bil_feedtl (rec_pat_adm_case.hcaseno);
		LOOP
			FETCH cur_bil_feedtl INTO rec_bil_feedtl;
			EXIT WHEN cur_bil_feedtl%notfound;
			rec_bil_billdtl                       := NULL;
			rec_bil_billdtl.bil_seqno             := rec_bil_billmst.dischg_bill_no;
			rec_bil_billdtl.caseno                := rec_bil_billmst.caseno;
			rec_bil_billdtl.fee_type              := rec_bil_feedtl.fee_type;
			rec_bil_billdtl.unitcode              := rec_bil_feedtl.pfincode;
			rec_bil_billdtl.total_amt             := rec_bil_feedtl.total_amt;
			rec_bil_billdtl.created_by            := rec_bil_billmst.created_by;
			rec_bil_billdtl.creation_date         := rec_bil_billmst.creation_date;
			rec_bil_billdtl.last_updated_by       := rec_bil_billmst.last_updated_by;
			rec_bil_billdtl.last_updateion_date   := rec_bil_billmst.last_update_date;
			INSERT INTO bil_billdtl VALUES rec_bil_billdtl;
		END LOOP;
		CLOSE cur_bil_feedtl;
		COMMIT;
		p_out_msg                          := '0';

		-- 寫入欠款中繼檔
		insert_vghtran (rec_pat_adm_case.hcaseno, p_out_msg);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			rec_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			rec_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'create_adm_bill';
			rec_biling_spl_errlog.sys_date     := SYSDATE;
			rec_biling_spl_errlog.err_code     := sqlcode;
			rec_biling_spl_errlog.err_msg      := sqlerrm;
			rec_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			rec_biling_spl_errlog.source_seq   := p_caseno;
			INSERT INTO biling_spl_errlog VALUES rec_biling_spl_errlog;
			COMMIT;
			p_out_msg                          := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
	END;

	-- 定期開立帳單
	PROCEDURE fivedaybilingbil (
		pbilldate IN DATE
	) IS
		v_out_msg biling_spl_errlog.err_info%TYPE;
	BEGIN
		period_create_adm_bill (v_out_msg);
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (dbms_utility.format_error_backtrace || dbms_utility.format_error_stack);
	END;

	-- 定期開立帳單
	PROCEDURE period_create_adm_bill (
		p_out_msg OUT VARCHAR2
	) IS
		CURSOR cur_pat_adm_case IS
		SELECT
			pat_adm_case.*
		FROM
			common.pat_adm_case
			INNER JOIN common.adm_bed ON pat_adm_case.hcaseno = adm_bed.hcaseno;
		rec_pat_adm_case        common.pat_adm_case%rowtype;
		rec_biling_spl_errlog   biling_spl_errlog%rowtype;
		v_out_msg               biling_spl_errlog.err_info%TYPE;
	BEGIN
		OPEN cur_pat_adm_case;
		LOOP
			FETCH cur_pat_adm_case INTO rec_pat_adm_case;
			EXIT WHEN cur_pat_adm_case%notfound;
			create_adm_bill (rec_pat_adm_case.hcaseno, '4', 'CIVC', 'billing', p_out_msg);
		END LOOP;
		CLOSE cur_pat_adm_case;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			rec_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			rec_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'period_create_adm_bill';
			rec_biling_spl_errlog.sys_date     := SYSDATE;
			rec_biling_spl_errlog.err_code     := sqlcode;
			rec_biling_spl_errlog.err_msg      := sqlerrm;
			rec_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			rec_biling_spl_errlog.source_seq   := rec_pat_adm_case.hcaseno;
			INSERT INTO biling_spl_errlog VALUES rec_biling_spl_errlog;
			COMMIT;
			p_out_msg                          := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
	END;

	-- 重入固定費用
	PROCEDURE changebildate (
		pcaseno   IN    VARCHAR2,
		pdate     IN    VARCHAR2,
		preturn   OUT   VARCHAR2
	) IS
	BEGIN
		change_daily_fee (pcaseno, pdate, preturn);
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (dbms_utility.format_error_backtrace || dbms_utility.format_error_stack);
	END;

	-- 重入固定費用
	PROCEDURE change_daily_fee (
		p_caseno     IN    VARCHAR2,
		p_bil_date   IN    DATE,
		p_out_msg    OUT   VARCHAR2
	) IS
		CURSOR cur_bil_occur (
			p_caseno     VARCHAR2,
			p_bil_date   DATE
		) IS
		SELECT
			*
		FROM
			bil_occur
		WHERE
			bil_occur.caseno = p_caseno
			AND
			bil_occur.bil_date = p_bil_date
			AND
			fee_kind IN (
				'01',
				'03',
				'05'
			);
		rec_bil_occur           bil_occur%rowtype;
		rec_biling_spl_errlog   biling_spl_errlog%rowtype;
		v_acnt_seq              INTEGER;
	BEGIN
		-- 沖銷原有帳款                     
		OPEN cur_bil_occur (p_caseno, p_bil_date);
		LOOP
			FETCH cur_bil_occur INTO rec_bil_occur;
			EXIT WHEN cur_bil_occur%notfound;
			SELECT
				nvl (MAX (acnt_seq), 0) + 1
			INTO v_acnt_seq
			FROM
				bil_occur
			WHERE
				bil_occur.caseno = p_caseno;
			rec_bil_occur.acnt_seq       := v_acnt_seq;
			rec_bil_occur.credit_debit   := '-';
			rec_bil_occur.create_dt      := SYSDATE;
			INSERT INTO bil_occur VALUES rec_bil_occur;
		END LOOP;
		CLOSE cur_bil_occur;

		-- Reset flag
		UPDATE bil_date
		SET
			bil_date.diet_flag = 'N',
			bil_date.daily_flag = 'N',
			bil_date.pdw_flag = 'N',
			bil_date.last_update_date = SYSDATE
		WHERE
			caseno = p_caseno
			AND
			bil_date = p_bil_date;

		-- 重入固定費用
		biling_daily_pkg.adddailyservicefeeforcase (p_caseno, p_bil_date);
		p_out_msg := '0';
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			rec_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			rec_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'change_daily_fee';
			rec_biling_spl_errlog.sys_date     := SYSDATE;
			rec_biling_spl_errlog.err_code     := sqlcode;
			rec_biling_spl_errlog.err_msg      := sqlerrm;
			rec_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			rec_biling_spl_errlog.source_seq   := p_caseno;
			INSERT INTO biling_spl_errlog VALUES rec_biling_spl_errlog;
			COMMIT;
			p_out_msg                          := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
	END;

	-- 出院通知
	PROCEDURE informbatch (
		pcaseno     IN   VARCHAR2,
		pdate       IN   VARCHAR2,
		pdiettype   IN   VARCHAR2
	) IS
		v_out_msg biling_spl_errlog.err_info%TYPE;
	BEGIN
		inform_batch (pcaseno, 'billing', v_out_msg);

		-- 列印帳單、領藥單、電子收費通知單
		print_informbill (pcaseno, v_out_msg);
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (dbms_utility.format_error_backtrace || dbms_utility.format_error_stack);
	END;

	-- 出院通知
	PROCEDURE inform_batch (
		p_caseno            IN    VARCHAR2,
		p_operator_emp_id   IN    VARCHAR2,
		p_out_msg           OUT   VARCHAR2
	) IS
		CURSOR cur_pat_adm_discharge (
			p_caseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			common.pat_adm_discharge
		WHERE
			hcaseno = p_caseno
			AND
			hdisstat IN (
				'I',
				'L'
			)
		ORDER BY
			hdisdate DESC,
			hdistime DESC;
		rec_pat_adm_case        common.pat_adm_case%rowtype;
		rec_bil_root            bil_root%rowtype;
		rec_pat_adm_discharge   common.pat_adm_discharge%rowtype;
		rec_biling_spl_errlog   biling_spl_errlog%rowtype;
	BEGIN
		SELECT
			*
		INTO rec_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = p_caseno;
		SELECT
			*
		INTO rec_bil_root
		FROM
			bil_root
		WHERE
			caseno = rec_pat_adm_case.hcaseno;

		-- 更新 bil_root 出院資訊 
		OPEN cur_pat_adm_discharge (p_caseno);
		FETCH cur_pat_adm_discharge INTO rec_pat_adm_discharge;
		IF cur_pat_adm_discharge%found THEN
			IF rec_bil_root.dischg_date IS NULL OR (
				CASE
					WHEN rec_pat_adm_discharge.hdisstat = 'L' THEN
						'D'
					ELSE rec_pat_adm_discharge.hdisstat
				END
			) != rec_bil_root.pat_state THEN
				UPDATE bil_root
				SET
					pat_state = DECODE (rec_pat_adm_discharge.hdisstat, 'L', 'D', rec_pat_adm_discharge.hdisstat),
					dischg_date = TO_DATE (rec_pat_adm_discharge.hdisdate || rec_pat_adm_discharge.hdistime, 'YYYYMMDDHH24MI')
				WHERE
					caseno = rec_pat_adm_case.hcaseno;
			END IF;
		END IF;
		CLOSE cur_pat_adm_discharge;
		IF rec_pat_adm_case.hpatstat = 'I' THEN
			-- 新膳食，設定開始日期 by kuo 1010626, update to 0701
			IF trunc (SYSDATE) >= TO_DATE ('20120701', 'YYYYMMDD') THEN
				biling_daily_pkg.p_diet_inadm_bycase (rec_pat_adm_case.hcaseno);
			END IF;

			-- 由 p_billtemp_leave_bycase 改到這裡 by kuo 1020115
			poverdueorder2templeave (rec_pat_adm_case.hcaseno);
		END IF;

		-- 開立出院帳單
		create_adm_bill (rec_pat_adm_case.hcaseno, '1', 'CIVC', p_operator_emp_id, p_out_msg);
		COMMIT;
		p_out_msg := '0';
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			rec_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			rec_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'inform_batch';
			rec_biling_spl_errlog.sys_date     := SYSDATE;
			rec_biling_spl_errlog.err_code     := sqlcode;
			rec_biling_spl_errlog.err_msg      := sqlerrm;
			rec_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			rec_biling_spl_errlog.source_seq   := p_caseno;
			INSERT INTO biling_spl_errlog VALUES rec_biling_spl_errlog;
			COMMIT;
			p_out_msg                          := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			bil_sendmail (NULL, 'jhchen@vghtc.gov.tw', '【PLSQL Exception】inform_batch', p_out_msg);
	END;

	-- 14天再入院合併
	PROCEDURE comp14days (
		pcaseno VARCHAR2
	) IS
		v_out_msg biling_spl_errlog.err_info%TYPE;
	BEGIN
		merge_admit_within_14days (pcaseno, v_out_msg);
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (dbms_utility.format_error_backtrace || dbms_utility.format_error_stack);
	END;

	-- 14天再入院合併
	PROCEDURE merge_admit_within_14days (
		p_caseno    IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	) IS
		CURSOR cur_bil_date (
			p_caseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_date
		WHERE
			caseno = p_caseno
		ORDER BY
			bil_date;
		rec_bil_date            bil_date%rowtype;
		rec_biling_spl_errlog   biling_spl_errlog%rowtype;
		v_bl14days              bil_root.bl14days%TYPE := 0;
		v_bl14c1                bil_root.bl14c1%TYPE := 0;
		v_cnt                   INTEGER := 0;
	BEGIN
		p_get14days (p_caseno, v_bl14days, v_bl14c1);           

		-- 帳務更新14天再入院天數及金額
		-- 需確認為14天再入院且長期結報尚未更新過
		UPDATE bil_root
		SET
			bl14days = v_bl14days,
			bl14c1 = v_bl14c1
		WHERE
			caseno = p_caseno
			AND
			inhdate IS NULL
			AND
			admit_again_flag = 'Y';
		OPEN cur_bil_date (p_caseno);
		LOOP
			FETCH cur_bil_date INTO rec_bil_date;
			EXIT WHEN cur_bil_date%notfound;
			v_cnt               := v_cnt + 1;
			rec_bil_date.days   := v_bl14days + v_cnt;
			UPDATE bil_date
			SET
				days = rec_bil_date.days
			WHERE
				caseno = rec_bil_date.caseno
				AND
				bil_date = rec_bil_date.bil_date;
		END LOOP;
		CLOSE cur_bil_date;
		p_out_msg := '0';
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			rec_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			rec_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'merge_admit_within_14days';
			rec_biling_spl_errlog.sys_date     := SYSDATE;
			rec_biling_spl_errlog.err_code     := sqlcode;
			rec_biling_spl_errlog.err_msg      := sqlerrm;
			rec_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			rec_biling_spl_errlog.source_seq   := p_caseno;
			INSERT INTO biling_spl_errlog VALUES rec_biling_spl_errlog;
			COMMIT;
			p_out_msg                          := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
	END;

	--清除帳務
	PROCEDURE clearbillingdata (
		pcaseno       IN    VARCHAR2,
		poutmessage   OUT   VARCHAR2
	) IS
	BEGIN
		clean_billing_data (pcaseno, poutmessage);
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (dbms_utility.format_error_backtrace || dbms_utility.format_error_stack);
	END;

	-- 清除帳務
	PROCEDURE clean_billing_data (
		p_caseno    IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	) IS
		rec_biling_spl_errlog biling_spl_errlog%rowtype;
	BEGIN
		-- 計價記錄
		DELETE FROM billtemp1
		WHERE
			caseno = p_caseno;
		-- 帳務主檔記錄
		DELETE FROM bil_root
		WHERE
			caseno = p_caseno;
		-- 帳款明細記錄
		DELETE FROM bil_occur
		WHERE
			caseno = p_caseno;
		-- 會計帳明細記錄
		DELETE FROM bil_acnt_wk
		WHERE
			caseno = p_caseno;
		-- 每日固定帳記錄
		DELETE FROM bil_date
		WHERE
			caseno = p_caseno;
		-- 費用明細檔記錄
		DELETE FROM bil_feedtl
		WHERE
			caseno = p_caseno;
		-- 費用主檔記錄
		DELETE FROM bil_feemst
		WHERE
			caseno = p_caseno;
		-- 帳單明細檔記錄
		DELETE FROM bil_billdtl
		WHERE
			bil_seqno IN (
				SELECT
					dischg_bill_no
				FROM
					bil_billmst
				WHERE
					caseno = p_caseno
			);
		-- 帳單主檔記錄
		DELETE FROM bil_billmst
		WHERE
			caseno = p_caseno;
		-- 帳單取消記錄
		DELETE FROM bil_billchgrec
		WHERE
			caseno = p_caseno;
		-- 切帳入帳記錄
		DELETE FROM bil_split_charge
		WHERE
			caseno = p_caseno;
		-- 切帳明細記錄
		DELETE FROM bil_split_dtl
		WHERE
			caseno = p_caseno;
		-- 切帳主檔記錄
		DELETE FROM bil_split_mst
		WHERE
			caseno = p_caseno;
		-- 欠款記錄
		DELETE FROM bil_debt_rec
		WHERE
			caseno = p_caseno;
		-- 欠款歷史記錄
		DELETE FROM bil_debt_rec_log
		WHERE
			caseno = p_caseno;
		-- 票據記錄
		DELETE FROM bil_check_bill
		WHERE
			caseno = p_caseno;
		-- 帳款調整明細檔記錄
		DELETE FROM bil_adjst_dtl
		WHERE
			caseno = p_caseno;
		-- 帳款調整主檔記錄
		DELETE FROM bil_adjst_mst
		WHERE
			caseno = p_caseno;
		-- 惠康帳單明細檔記錄
		DELETE FROM bil_adjstbil_dtl
		WHERE
			caseno = p_caseno;
		-- 惠康帳單主檔記錄
		DELETE FROM bil_adjstbil_mst
		WHERE
			caseno = p_caseno;
		-- 特約身分記錄
		DELETE FROM bil_contr
		WHERE
			caseno = p_caseno;
		-- 健保轉換項目記錄
		DELETE FROM bil_occur_trans
		WHERE
			caseno = p_caseno;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			rec_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			rec_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'clean_billing_data';
			rec_biling_spl_errlog.sys_date     := SYSDATE;
			rec_biling_spl_errlog.err_code     := sqlcode;
			rec_biling_spl_errlog.err_msg      := sqlerrm;
			rec_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			rec_biling_spl_errlog.source_seq   := p_caseno;
			INSERT INTO biling_spl_errlog VALUES rec_biling_spl_errlog;
			COMMIT;
			p_out_msg                          := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
	END;

	-- 取得印表機邏輯 ID
	FUNCTION getprtlogid (
		pcaseno VARCHAR2
	) RETURN VARCHAR2 IS
	BEGIN
		RETURN get_prt_logid (pcaseno);
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (dbms_utility.format_error_backtrace || dbms_utility.format_error_stack);
	END;

	-- 取得印表機邏輯 ID
	FUNCTION get_prt_logid (
		p_caseno VARCHAR2
	) RETURN VARCHAR2 IS
		v_logid            cpoe.cpoe_ns_printset.logid%TYPE;
		rec_pat_adm_case   common.pat_adm_case%rowtype;
	BEGIN
		SELECT
			*
		INTO rec_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = p_caseno;
		SELECT
			logid
		INTO v_logid
		FROM
			cpoe.cpoe_ns_printset
		WHERE
			hnurstat = rec_pat_adm_case.hnursta
			AND
			(hbedno = rec_pat_adm_case.hbed
			 OR
			 hbedno = 'ALL');
		IF v_logid = 'BR' THEN
			v_logid := 'W76';
		END IF;
		RETURN v_logid;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN v_logid;
	END;

	-- 印單
	PROCEDURE print_informbill (
		pcaseno    IN    VARCHAR2,
		pmessage   OUT   VARCHAR2
	) IS
	BEGIN
		inform_print (pcaseno, pmessage);
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line (dbms_utility.format_error_backtrace || dbms_utility.format_error_stack);
	END;

	-- 印單
	PROCEDURE inform_print (
		p_caseno    IN    VARCHAR2,
		p_out_msg   OUT   VARCHAR2
	) IS
		CURSOR cur_bil_bankservicelist (
			p_patid VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_bankservicelist
		WHERE
			patid = p_patid
			AND
			TO_CHAR (SYSDATE, 'YYYYMMDD') BETWEEN patbegdt AND patenddt;
		rec_pat_adm_case          common.pat_adm_case%rowtype;
		rec_new_print_cpoe        shared.new_print_cpoe%rowtype;
		rec_bil_bankservicelist   bil_bankservicelist%rowtype;
		rec_biling_spl_errlog     biling_spl_errlog%rowtype;
	BEGIN
		SELECT
			*
		INTO rec_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = p_caseno;
		SELECT
			*
		INTO rec_new_print_cpoe
		FROM
			shared.new_print_cpoe
		WHERE
			logid = get_prt_logid (rec_pat_adm_case.hcaseno)
			AND
			ROWNUM = 1;
		bil_call_report (rec_pat_adm_case.hcaseno, 'http://oracleas.vghtc.gov.tw:7780/reports/rwservlet?' || 'userid=billing/billing@hissp1'
		|| '&destype=MQPSC' || '&desname=orderId@0.0.0.0@' || rec_new_print_cpoe.prtid || '@TRAY66@H@66@PSC' || '&report=BIL5110_txt.rdf'
		|| '&arg_caseno=' || rec_pat_adm_case.hcaseno, '住院帳單');
		IF (service_bill_pkg.get_adm_owed_amt (rec_pat_adm_case.hcaseno, 'CIVC') > 0) THEN
			OPEN cur_bil_bankservicelist (service_bill_pkg.get_pat_nat_no (rec_pat_adm_case.hhisnum));
			FETCH cur_bil_bankservicelist INTO rec_bil_bankservicelist;
			IF cur_bil_bankservicelist%found THEN
				bil_call_report (rec_pat_adm_case.hcaseno, 'http://oracleas.vghtc.gov.tw:7780/reports/rwservlet?' || 'userid=billing/billing@hissp1'
				|| '&destype=MQPSC' || '&desname=orderId@0.0.0.0@' || rec_new_print_cpoe.prtid || '@TRAY22@H@22@PSC' || '&report=BIL5170_txt.rdf'
				|| '&arg_caseno=' || rec_pat_adm_case.hcaseno, '電子收費通知單');
			END IF;
			CLOSE cur_bil_bankservicelist;
		ELSE
			bil_call_report (rec_pat_adm_case.hcaseno, 'http://oracleas.vghtc.gov.tw:7780/reports/rwservlet?' || 'userid=billing/billing@hissp1'
			|| '&destype=MQPSC' || '&desname=orderId@0.0.0.0@' || rec_new_print_cpoe.prtid || '@TRAY22@H@22@PSC' || '&report=ATM_takeMedicine.rdf'
			|| '&arg_caseno=' || rec_pat_adm_case.hcaseno, '領藥單');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			rec_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			rec_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'clean_billing_data';
			rec_biling_spl_errlog.sys_date     := SYSDATE;
			rec_biling_spl_errlog.err_code     := sqlcode;
			rec_biling_spl_errlog.err_msg      := sqlerrm;
			rec_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			rec_biling_spl_errlog.source_seq   := p_caseno;
			INSERT INTO biling_spl_errlog VALUES rec_biling_spl_errlog;
			COMMIT;
			p_out_msg                          := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
	END;
END;

/
