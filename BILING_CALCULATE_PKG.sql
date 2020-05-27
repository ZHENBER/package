CREATE OR REPLACE PACKAGE "BILING_CALCULATE_PKG" IS
	PROCEDURE main_process (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2,
		pcalculate    VARCHAR2 DEFAULT 'N'
	);

      --展開bildate
	PROCEDURE expandbildate (
		pcaseno VARCHAR2
	);

      --清除計算程式
	PROCEDURE initdata (
		pcaseno VARCHAR2
	);

      --展開身份別至身份暫存檔
	PROCEDURE extandfin (
		pcaseno VARCHAR2
	);

      --計算醫令明細
	PROCEDURE acntwkcalculate (
		pcaseno VARCHAR2
	);

      --整理帳款
	PROCEDURE compacntwk (
		pcaseno VARCHAR2
	);
	PROCEDURE checkbildate (
		i_hcaseno VARCHAR2
	);
	PROCEDURE checkbildate_new (
		pcaseno VARCHAR2
	);

      --計算單價
	PROCEDURE getprice (
		ppfkey       VARCHAR2,
		pselfprice   OUT   NUMBER,
		pnhprice     OUT   NUMBER
	);

      --計算乘數
	FUNCTION getemgper (
		pcaseno    VARCHAR2,  --住院序
		ppfkey     VARCHAR2,   --計價碼
		pfeekind   VARCHAR2, --帳檔計價類別
		pbldate    DATE,--計價日 new add by kuo 20140731
		pemgflag   VARCHAR2, --急作否
		ptype      VARCHAR2
	) --回傳成數
	 RETURN NUMBER;

        -- 計算乘數 for history 
        -- add by 陳如軒 2017-08-16
        /* 
            原 getEmgPer 的 CUR_1 修正，WHERE 加上 PFINCODE = 'LABI'，並 UNION PFHISCLS
            但不溯及既往，故新增 getEmgPerHist 給 2017-08-16 以前計價的記錄使用
         */
	FUNCTION getemgperhist (
		pcaseno    VARCHAR2,  --住院序號
		ppfkey     VARCHAR2,   --計價碼
		pfeekind   VARCHAR2, --帳檔計價類別
		pbldate    DATE,--計價日 new add by kuo 20140731
		pemgflag   VARCHAR2, --急作否
		ptype      VARCHAR2
	) --回傳成數
	 RETURN NUMBER;

       --調整應收帳款
	PROCEDURE p_receivablecomp (
		pcaseno VARCHAR2
	);

       --榮民資料檔優待身份別處理
	PROCEDURE get_discfin (
		i_hcaseno   VARCHAR2,
		i_pfinacl   VARCHAR2,
		o_discfin   OUT VARCHAR2
	);

       --新生兒健保內含項check
	FUNCTION f_checkbabynh (
		ppfkey VARCHAR2
	) RETURN VARCHAR2;

       --健保規則調整
	PROCEDURE p_transnhrule (
		pcaseno VARCHAR2
	);
	PROCEDURE p_deleteacntwk (
		pcaseno         VARCHAR2,
		pacntseq        NUMBER,
		pdeletereason   VARCHAR2
	);
	PROCEDURE p_insertacntwk (
		pcaseno         VARCHAR2,
		pacntseq        NUMBER,
		pinsfeecode     VARCHAR2,
		pdeletereason   VARCHAR2
	);
	FUNCTION f_checkbabyflag (
		pcaseno   VARCHAR2,
		pdate     DATE
	) RETURN VARCHAR2;

       --判斷是否為就養榮民
	FUNCTION f_checknhdiet (
		pcaseno VARCHAR2
	) RETURN VARCHAR2;
	PROCEDURE p_modifityselfpay (
		pcaseno          VARCHAR2,
		pfinacl          VARCHAR2,
		pdischargedate   DATE
	);

       --取得當日身份別
	FUNCTION f_getnhrangeflag (
		pcaseno    VARCHAR2,
		pdate      DATE,
		pfinflag   VARCHAR2
	) RETURN VARCHAR2;
       --計算乘數,新版本for兒童加成依計價日起算
	FUNCTION getemgpernew (
		pcaseno    VARCHAR2, --住院序
		ppfkey     VARCHAR2, --計價碼
		pfeekind   VARCHAR2, --帳檔計價類別
		pemgflag   VARCHAR2, --急作否
		bldate     DATE,     --計價日
		ptype      VARCHAR2
	) --回傳成數
	 RETURN NUMBER;

       --國際醫療計算用，整個翻新 BY KUO 20121108
	PROCEDURE contract_as999 (
		pcaseno VARCHAR2
	);

       --膳食for職,福,榮調整 BY KUO 20121114
	PROCEDURE diet_nhi346_adjust (
		pcaseno VARCHAR2
	);

       --高危險妊娠註記 by Kuo 20131104
	PROCEDURE diag_2024 (
		pcaseno VARCHAR2
	);

       --膳食for 1046調整，比照福 by kuo 20171026
	PROCEDURE diet_1046 (
		pcaseno VARCHAR2
	);

	-- 設定 1060 算帳身分
	PROCEDURE set_1060_financial (
		i_caseno VARCHAR2
	);

	-- 調整 1060 帳款分攤
	PROCEDURE adjust_1060_acnt_wk (
		i_caseno VARCHAR2
	);

	-- 重整費用明細檔
	PROCEDURE recalculate_feedtl (
		i_caseno VARCHAR2
	);

	-- 重整部分負擔
	PROCEDURE recalculate_copay (
		i_hcaseno VARCHAR2
	);

	-- 重整費用主檔
	PROCEDURE recalculate_feemst (
		i_hcaseno    VARCHAR2,
		i_end_date   DATE
	);
END;

/


CREATE OR REPLACE PACKAGE BODY "BILING_CALCULATE_PKG" IS
  --住院帳款計算主程式段
	PROCEDURE main_process (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2,
		pcalculate    VARCHAR2 DEFAULT 'N'
	) --Y=強制重算
	 IS
    --取出病人基本資料[住院號]
		CURSOR cur_bilroot IS
		SELECT
			*
		FROM
			bil_root
		WHERE
			bil_root.caseno = TRIM (pcaseno);

    --取出出院通知或離院病人[住院號]
		CURSOR cur_discharge IS
		SELECT
			*
		FROM
			common.pat_adm_discharge
		WHERE
			common.pat_adm_discharge.hcaseno = TRIM (pcaseno)
			AND
			common.pat_adm_discharge.hdisstat IN (
				'I',
				'L'
			)
		ORDER BY
			common.pat_adm_discharge.hdisdate DESC,
			common.pat_adm_discharge.hdistime DESC;
		bilrootrec           bil_root%rowtype;
		bilsplerrlogrec      biling_spl_errlog%rowtype;
		patadmdischargerec   common.pat_adm_discharge%rowtype;
		patadmcaserec        common.pat_adm_case%rowtype;
		patbasicrec          common.pat_basic%rowtype;
		v_cnt                INTEGER;
		v_dischg_date        DATE;
		CURSOR cur_splerrlog (
			v_session_id NUMBER
		) IS
		SELECT
			*
		FROM
			biling_spl_errlog
		WHERE
			source_seq = pcaseno
			AND
			biling_spl_errlog.session_id = v_session_id;

    --錯誤訊息用途
		v_program_name       VARCHAR2 (80);
		v_session_id         NUMBER (10);
		v_error_code         VARCHAR2 (20);
		v_error_msg          VARCHAR2 (400);
		v_error_info         VARCHAR2 (600);
		v_source_seq         VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.main_process';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := trim (pcaseno);

    --防範case cancel 未取消 bil_root by kuo 20140717
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			common.pat_adm_cancel
		WHERE
			caseno = pcaseno;
		IF v_cnt > 0 THEN
			pmessageout := pcaseno || ':已經取消';
			return;
		END IF;
		INSERT INTO bil_procedule_temp (
			caseno,
			record_date,
			status,
			message,
			pro_name,
			session_id
		) VALUES (
			pcaseno,
			SYSDATE,
			'',
			'執行main_process開始',
			'main_process',
			v_session_id
		);
		COMMIT WORK;
    --測試結束
		OPEN cur_bilroot;
		FETCH cur_bilroot INTO bilrootrec;
		CLOSE cur_bilroot;
    --000000000A 不算帳!
    --IF BILROOTREC.HPATNUM='000000000A' THEN
       --PMESSAGEOUT := '000000000A不重算';
       --RETURN;
    --END IF;
		SELECT
			*
		INTO patbasicrec
		FROM
			common.pat_basic
		WHERE
			hhisnum = bilrootrec.hpatnum;
		IF length (patbasicrec.hbirthdt) = 8 AND patbasicrec.hbirthdt NOT LIKE '0%' THEN
			UPDATE bil_root
			SET
				birth_date = TO_DATE (patbasicrec.hbirthdt, 'YYYYMMDD')
			WHERE
				caseno = bilrootrec.caseno;
			bilrootrec.birth_date := TO_DATE (patbasicrec.hbirthdt, 'YYYYMMDD');
			COMMIT WORK;
		END IF;
		IF substr (bilrootrec.created_by, 1, 3) = 'HIS' THEN
      --HIS長期欠款不重算帳單 chinyu 99.11.22
			INSERT INTO bil_procedule_temp (
				caseno,
				record_date,
				status,
				message,
				pro_name,
				session_id
			) VALUES (
				pcaseno,
				SYSDATE,
				'',
				'執行main_process結束，HIS長期欠款不重算',
				'main_process',
				v_session_id
			);
			COMMIT WORK;
			pmessageout := 'HIS長期欠款不重算';
			return;
		END IF;
		IF (pcalculate = 'N') AND (trim (bilrootrec.created_by) = 'No_Calculate') THEN
      --帳單鎖控不能重算 chinyu 99.12.16
			INSERT INTO bil_procedule_temp (
				caseno,
				record_date,
				status,
				message,
				pro_name,
				session_id
			) VALUES (
				pcaseno,
				SYSDATE,
				'',
				'執行main_process結束，帳單鎖控不能重算',
				'main_process',
				v_session_id
			);
			COMMIT WORK;
			pmessageout := '帳單鎖控不能重算*';
			return;
		END IF;

    --取得出院日期
		OPEN cur_discharge;
		FETCH cur_discharge INTO patadmdischargerec;
		IF cur_discharge%found THEN
			IF bilrootrec.dischg_date IS NULL OR (patadmdischargerec.hdisstat <> bilrootrec.pat_state AND bilrootrec.pat_state <> 'D') THEN
				v_dischg_date := TO_DATE (patadmdischargerec.hdisdate || patadmdischargerec.hdistime, 'yyyymmddhh24mi');
				UPDATE bil_root
				SET
					bil_root.pat_state = patadmdischargerec.hdisstat,
					bil_root.dischg_date = v_dischg_date
				WHERE
					caseno = TRIM (pcaseno);
			END IF;
		ELSE
			IF bilrootrec.dischg_date IS NOT NULL THEN
				SELECT
					*
				INTO patadmcaserec
				FROM
					common.pat_adm_case
				WHERE
					hcaseno = TRIM (pcaseno);
				UPDATE bil_root
				SET
					bil_root.pat_state = patadmcaserec.hpatstat,
					bil_root.dischg_date = NULL
				WHERE
					caseno = TRIM (pcaseno);
			END IF;
      --ADD FOR PROJECTCODE 901 BY KUO 1000907
			IF patadmcaserec.projectcode = '901' THEN
				UPDATE bil_root
				SET
					bil_root.pay_code = patadmcaserec.projectcode
				WHERE
					caseno = TRIM (pcaseno);
			END IF;
		END IF;
		CLOSE cur_discharge;
		initdata (trim (pcaseno));
		OPEN cur_splerrlog (v_session_id);
		FETCH cur_splerrlog INTO bilsplerrlogrec;
		IF cur_splerrlog%found AND trunc (bilsplerrlogrec.sys_date) = trunc (SYSDATE) THEN
			pmessageout := bilsplerrlogrec.prog_name || '-' || bilsplerrlogrec.err_info;
		ELSE
			pmessageout := '0';
		END IF;
		CLOSE cur_splerrlog;
		p_biloccurbycase (pcaseno => TRIM (pcaseno)); --考量合併項主項，把合併項的細項取定價及費用類別逐一新增入bil_occur，再將合併項主項刪除
		OPEN cur_splerrlog (v_session_id);
		FETCH cur_splerrlog INTO bilsplerrlogrec;
		IF cur_splerrlog%found AND trunc (bilsplerrlogrec.sys_date) = trunc (SYSDATE) THEN
			pmessageout := bilsplerrlogrec.prog_name || '-' || bilsplerrlogrec.err_info;
		ELSE
			pmessageout := '0';
		END IF;
		CLOSE cur_splerrlog;
		checkbildate (trim (pcaseno));
		OPEN cur_splerrlog (v_session_id);
		FETCH cur_splerrlog INTO bilsplerrlogrec;
		IF cur_splerrlog%found AND trunc (bilsplerrlogrec.sys_date) = trunc (SYSDATE) THEN
			pmessageout := bilsplerrlogrec.prog_name || '-' || bilsplerrlogrec.err_info;
		ELSE
			pmessageout := '0';
		END IF;
		CLOSE cur_splerrlog;
		SELECT
			*
		INTO patadmcaserec
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = TRIM (pcaseno);
		UPDATE bil_root
		SET
			bil_root.hfinacl = patadmcaserec.hfinancl,
			bil_root.hfinacl2 = patadmcaserec.hfincl2,
			bil_root.hmrcase = TRIM (patadmcaserec.hmrcase),
			bil_root.admit_again_flag = patadmcaserec.hreadmit
		WHERE
			caseno = TRIM (pcaseno);
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			billtemp1
		WHERE
			caseno = TRIM (pcaseno)
			AND
			trn_flag = 'N';
		IF v_cnt > 0 THEN
			p_billtempbycase (trim (pcaseno));
		END IF;
		v_cnt            := 0;
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			billtemp_leave
		WHERE
			caseno = TRIM (pcaseno)
			AND
			trunc (billtemp_leave.upload_date) = trunc (SYSDATE);
		IF v_cnt > 0 AND poper <> 'bildailyBatch' THEN
      --避免過帳時重複計價kuo 980122
      --把出院當日帳先都清掉
			UPDATE billtemp_leave
			SET
				billtemp_leave.trn_flag = 'Y'
			WHERE
				billtemp_leave.caseno = pcaseno;

      --只留當天下載的帳
			UPDATE billtemp_leave
			SET
				billtemp_leave.trn_flag = 'N',
				billtemp_leave.trn_date = NULL
			WHERE
				billtemp_leave.caseno = pcaseno
				AND
				trunc (billtemp_leave.upload_date) = trunc (SYSDATE);
			p_billtempbycase_leave (trim (pcaseno));
		END IF;

    --展開身份別
		OPEN cur_splerrlog (v_session_id);
		FETCH cur_splerrlog INTO bilsplerrlogrec;
		IF cur_splerrlog%found AND trunc (bilsplerrlogrec.sys_date) = trunc (SYSDATE) THEN
			pmessageout := bilsplerrlogrec.prog_name || '-' || bilsplerrlogrec.err_info;
		ELSE
			pmessageout := '0';
		END IF;
		CLOSE cur_splerrlog;
/*     --20200410 for '1031','1034','1033','1194'
		FOR r_bil_contr IN (
			SELECT
				bilcunit
			FROM
				bil_contr
			WHERE
				bilcunit IN (
					'1031',
					'1034',
					'1033',
					'1194'
				)
				AND
				caseno = pcaseno
		) LOOP
			l_b103x :=r_bil_contr.bilcunit;
			EXIT;
		END LOOP;
		IF l_b103x IS NOT NULL THEN --強制都為LABI
			INSERT INTO tmp_fincal (
				caseno,
				fincalcode,
				st_date,
				end_date
			) VALUES (
				pcaseno,
				'LABI',
				trunc (bilrootrec.admit_date),
				trunc (nvl (bilrootrec.dischg_date, SYSDATE))
			);
         --再加 103X for 膳食 by kuo 20170818
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					l_b103x,
					trunc (bilrootrec.admit_date),
					trunc (nvl (bilrootrec.dischg_date, SYSDATE))
				);
			COMMIT WORK;
		ELSE */
		extandfin (trim (pcaseno));
		-- END IF;

    --針對case 02925683 調整 by kuo 20160802
    --case 02925683 20160623-20160731 都是有職榮，20160801-20160802 改為無職榮,
    --目前COMMON.PAT_ADM_VTAN_REC 只有一筆無職榮紀錄，無法有效知道期有職榮期間,
    --因此帳務先針對此case hard code in program
		IF pcaseno = '02925683' THEN
			UPDATE tmp_fincal
			SET
				fincalcode = 'VT11'
			WHERE
				caseno = '02925683'
				AND
				st_date = TO_DATE ('20160623', 'YYYYMMDD')
				AND
				end_date = TO_DATE ('20160731', 'YYYYMMDD')
				AND
				fincalcode = 'VTAN';
			COMMIT WORK;
		END IF;
		OPEN cur_splerrlog (v_session_id);
		FETCH cur_splerrlog INTO bilsplerrlogrec;
		IF cur_splerrlog%found AND trunc (bilsplerrlogrec.sys_date) = trunc (SYSDATE) THEN
			pmessageout := bilsplerrlogrec.prog_name || '-' || bilsplerrlogrec.err_info;
		ELSE
			pmessageout := '0';
		END IF;
		CLOSE cur_splerrlog;

		-- 高危險妊娠註記 start at 20131127 by kuo
		IF patadmcaserec.hadmdt >= '20131127' THEN
			diag_2024 (trim (pcaseno));
		END IF;

		-- 計算計價項目明細檔
		compacntwk (trim (pcaseno));

		-- 重整費用明細檔
		recalculate_feedtl (pcaseno);

    	-- 帳調整
		bil_adjst_trn (pcaseno, '');
		p_receivablecomp (pcaseno => TRIM (pcaseno));

		-- 重整費用主檔
		recalculate_feemst (pcaseno, SYSDATE);

    	-- 刪掉 BIL_OCCUR
		DELETE bil_occur
		WHERE
			bil_occur.caseno = TRIM (pcaseno)
			AND
			bil_occur.last_updated_by = 'InformBatch';
		UPDATE bil_root
		SET
			bil_root.last_calcu_date = SYSDATE
		WHERE
			bil_root.caseno = TRIM (pcaseno);

		-- 確認無錯誤訊息
		OPEN cur_splerrlog (v_session_id);
		FETCH cur_splerrlog INTO bilsplerrlogrec;
		IF cur_splerrlog%found AND trunc (bilsplerrlogrec.sys_date) = trunc (SYSDATE) THEN
			pmessageout := bilsplerrlogrec.prog_name || '-' || bilsplerrlogrec.err_info;
		ELSE
			pmessageout := '0';
		END IF;
		CLOSE cur_splerrlog;
		COMMIT WORK;

    	-- 處理吳鳳美 18類自費金額重算後會爆增的問題
		IF pcaseno = '01207481' THEN
			UPDATE billing.bil_feedtl
			SET
				total_amt = nvl ((
					SELECT
						SUM (self_amt)
					FROM
						billing.bil_acnt_wk
					WHERE
						caseno = '01207481'
						AND
						fee_kind = '18'
						AND
						bildate < trunc (SYSDATE)
						AND
						bildate >= (
							SELECT
								*
							FROM
								(
									SELECT
										trunc (creation_date)
									FROM
										billing.bil_adjst_mst
									WHERE
										caseno = '01207481'
										AND
										hpatnum = '000725942J'
										AND
										blfrunit = 'CIVC'
										AND
										bltounit = '9250'
									ORDER BY
										creation_date DESC
								)
							WHERE
								ROWNUM = 1
						)
					GROUP BY
						caseno
				), 0)
			WHERE
				caseno = '01207481'
				AND
				fee_type = '18'
				AND
				pfincode = 'CIVC';

       		-- 處理吳鳳美 05 類金額有負帳
			UPDATE billing.bil_feedtl
			SET
				total_amt = nvl ((
					SELECT
						SUM (self_amt)
					FROM
						billing.bil_acnt_wk
					WHERE
						caseno = '01207481'
						AND
						fee_kind = '05'
						AND
						bildate < trunc (SYSDATE)
						AND
						bildate >= (
							SELECT
								*
							FROM
								(
									SELECT
										trunc (creation_date)
									FROM
										billing.bil_adjst_mst
									WHERE
										caseno = '01207481'
										AND
										hpatnum = '000725942J'
										AND
										blfrunit = 'CIVC'
										AND
										bltounit = '9250'
									ORDER BY
										creation_date DESC
								)
							WHERE
								ROWNUM = 1
						)
					GROUP BY
						caseno
				), 0)
			WHERE
				caseno = '01207481'
				AND
				fee_type = '05'
				AND
				pfincode = 'CIVC';

       		-- 處理吳鳳美 21 類金額有負帳
			UPDATE billing.bil_feedtl
			SET
				total_amt = nvl ((
					SELECT
						SUM (self_amt)
					FROM
						billing.bil_acnt_wk
					WHERE
						caseno = '01207481'
						AND
						fee_kind = '21'
						AND
						bildate < trunc (SYSDATE)
						AND
						bildate >= (
							SELECT
								*
							FROM
								(
									SELECT
										trunc (creation_date)
									FROM
										billing.bil_adjst_mst
									WHERE
										caseno = '01207481'
										AND
										hpatnum = '000725942J'
										AND
										blfrunit = 'CIVC'
										AND
										bltounit = '9250'
									ORDER BY
										creation_date DESC
								)
							WHERE
								ROWNUM = 1
						)
					GROUP BY
						caseno
				), 0)
			WHERE
				caseno = '01207481'
				AND
				fee_type = '21'
				AND
				pfincode = 'CIVC';
			UPDATE billing.bil_feemst
			SET
				tot_gl_amt = nvl ((
					SELECT
						SUM (total_amt)
					FROM
						billing.bil_feedtl
					WHERE
						caseno = '01207481'
						AND
						pfincode = 'CIVC'
						AND
						fee_type NOT IN (
							'41', '42', '43'
						)
				), 0)
			WHERE
				caseno = '01207481';
			COMMIT WORK;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := trim (pcaseno);
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			pmessageout    := '1';
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq,
				sys_date
			) VALUES (
				v_session_id,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq,
				SYSDATE
			);
			COMMIT WORK;
	END;

  --展開bildate
	PROCEDURE expandbildate (
		pcaseno VARCHAR2
	) IS
		v_date               DATE;
		v_enddate            DATE;
		bilrootrec           bil_root%rowtype;
		bildaterec           bil_date%rowtype;
		patadmfinancialrec   common.pat_adm_financial%rowtype;
		v_max_date           DATE;
		v_day                INTEGER;
		v_cnt                INTEGER;
		yy                   VARCHAR2 (03);
		mmdd                 VARCHAR2 (04);
		rsbeddge             VARCHAR2 (04);
    --錯誤訊息用途
		v_program_name       VARCHAR2 (80);
		v_session_id         NUMBER (10);
		v_error_code         VARCHAR2 (20);
		v_error_msg          VARCHAR2 (400);
		v_error_info         VARCHAR2 (600);
		v_source_seq         VARCHAR2 (20);
		e_user_exception EXCEPTION;
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			common.pat_adm_financial
		WHERE
			pat_adm_financial.hcaseno = pcaseno
			AND
			TO_DATE (TRIM (pat_adm_financial.hfindate), 'yyyymmdd') <= v_max_date;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.expandBilDate';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		BEGIN
      --取出住院日期
			SELECT
				bil_root.*
			INTO bilrootrec
			FROM
				bil_root
			WHERE
				bil_root.caseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				v_error_code   := sqlcode;
				v_error_info   := sqlerrm;
		END;
		IF bilrootrec.dischg_date IS NULL THEN
			v_enddate := SYSDATE;
		ELSE
			v_enddate := bilrootrec.dischg_date;
		END IF;
		v_date           := TO_DATE (TO_CHAR (bilrootrec.admit_date, 'yyyymmdd'), 'yyyymmdd');
		v_day            := bilrootrec.blnhidt;
		IF v_day IS NULL THEN
			v_day := 0;
		END IF;
		LOOP
			EXIT WHEN v_date > v_enddate;
			v_day                         := v_day + 1;
			bildaterec.caseno             := pcaseno;
			bildaterec.hpatnum            := bilrootrec.hpatnum;
      --取出本日最後一張床的位置
      --取出最接近現在日期的轉床日期
			SELECT
				MAX (TO_DATE (hbeddt || hbedtm, 'yyyymmddhh24mi'))
			INTO v_max_date
			FROM
				common.pat_adm_bed
			WHERE
				hcaseno = pcaseno
				AND
				hbeddt <= TO_CHAR (v_date, 'yyyymmdd')
				AND
				TRIM (hbeddt) IS NOT NULL;

      --取出最後一次轉床記錄
			SELECT
				hbed,
				pat_adm_bed.hnursta
			INTO
					bildaterec
				.bed_no,
				bildaterec.wardno
			FROM
				common.pat_adm_bed
			WHERE
				hcaseno = pcaseno
				AND
				hbeddt || hbedtm = TO_CHAR (v_max_date, 'yyyymmddhh24mi')
				AND
				TRIM (hbeddt) IS NOT NULL;

      --計算急慢性天數
			bildaterec.ec_flag            := 'E';
			bildaterec.days               := v_day;
			bildaterec.bil_date           := v_date;
			bildaterec.pat_state          := bilrootrec.pat_state;
			bildaterec.pay_code           := bilrootrec.pay_code;

      --取出該日身份別
			SELECT
				MAX (TO_DATE (TRIM (hfindate), 'yyyymmdd'))
			INTO v_max_date
			FROM
				common.pat_adm_financial
			WHERE
				hcaseno = pcaseno
				AND
				TO_DATE (TRIM (hfindate), 'yyyymmdd') <= v_date;
			OPEN cur_1;
			FETCH cur_1 INTO patadmfinancialrec;
			CLOSE cur_1;
			bildaterec.hfinacl            := patadmfinancialrec.hfinancl;
			bildaterec.hnhi1typ           := patadmfinancialrec.hnhi1typ;
			bildaterec.htraffic           := patadmfinancialrec.htraffic;
			bildaterec.hpaytype           := patadmfinancialrec.hpaytype;
			bildaterec.hfinacl2           := bilrootrec.hfinacl2;
			bildaterec.created_by         := 'biling';
			bildaterec.creation_date      := SYSDATE;
			bildaterec.last_updated_by    := 'biling';
			bildaterec.last_update_date   := SYSDATE;

      --特等病房保留查詢 BY KUO 980826 AND SPCIAL CASE 981020
			BEGIN
				yy                   := lpad (to_number (TO_CHAR (v_date, 'YYYY')) - 1911, 3, '0');
				mmdd                 := TO_CHAR (v_date, 'MMDD');
				bildaterec.blordge   := '';
				SELECT
					rtrim (rbbeddge)
				INTO rsbeddge
				FROM
					common.reservebed
				WHERE
					rtrim (rbcaseno) = pcaseno
					AND
					rtrim (rbbegdt) <= yy || mmdd
					AND
					rtrim (rbenddt) > yy || mmdd;
				IF rsbeddge = '12AA' THEN
					bildaterec.blordge := 'A';
				ELSIF rsbeddge = '12AB' THEN
					bildaterec.blordge := 'B';
				ELSIF rsbeddge IS NOT NULL THEN
					bildaterec.blordge := substr (rsbeddge, 1, 1);
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					bildaterec.blordge := '';
			END;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				bil_date
			WHERE
				bil_date.caseno = pcaseno
				AND
				bil_date.bil_date = v_date;

      --判斷是否已有當日BILDATE資料
			IF v_cnt = 0 THEN
				BEGIN
					INSERT INTO bil_date VALUES bildaterec;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
			ELSE
				BEGIN
					UPDATE bil_date
					SET
						bil_date.hfinacl = bildaterec.hfinacl,
						bil_date.hfinacl2 = bildaterec.hfinacl2,
						bil_date.ec_flag = bildaterec.ec_flag,
						bil_date.days = bildaterec.days,
						bil_date.wardno = bildaterec.wardno,
						bil_date.hnhi1typ = bildaterec.hnhi1typ,
						bil_date.htraffic = bildaterec.htraffic,
						bil_date.hpaytype = bildaterec.hpaytype
					WHERE
						bil_date.caseno = pcaseno
						AND
						bil_date.bil_date = v_date;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
			END IF;
			v_date                        := v_date + 1;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --清除計算程式
	PROCEDURE initdata (
		pcaseno VARCHAR2
	) IS
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_cnt            INTEGER;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.initData';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		DELETE FROM bil_feedtl
		WHERE
			caseno = pcaseno;
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			bil_feemst
		WHERE
			caseno = pcaseno;
		DELETE FROM bil_feemst
		WHERE
			caseno = pcaseno;
		DELETE FROM bil_acntdet
		WHERE
			caseno = pcaseno;
		DELETE FROM tmp_fincal
		WHERE
			caseno = pcaseno;
		DELETE FROM bil_acnt_wk
		WHERE
			caseno = pcaseno;
		DELETE FROM bil_occur_trans
		WHERE
			caseno = pcaseno;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --展開身份別至身份暫存檔
	PROCEDURE extandfin (
		pcaseno VARCHAR2
	) IS
    --錯誤訊息用途
		v_program_name       VARCHAR2 (80);
		v_session_id         NUMBER (10);
		v_error_code         VARCHAR2 (20);
		v_error_msg          VARCHAR2 (400);
		v_error_info         VARCHAR2 (600);
		v_source_seq         VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_finacl1            VARCHAR2 (10);
		v_finacl2            VARCHAR2 (10);
		v_hpatnum            VARCHAR2 (10);
		v_other_fincal       VARCHAR2 (10);
		bilcontrrec          bil_contr%rowtype;
		v_dischg_date        bil_root.dischg_date%TYPE;
    --IGNORE 1059 FOR TRANFER BY KUO 980821
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			bil_contr
		WHERE
			bil_contr.caseno = pcaseno
			AND
			bil_contr.bilcunit <> '1059'
			AND
			(bil_contr.stop_flag = 'N'
			 OR
			 bil_contr.stop_flag IS NULL);
		CURSOR cur_2 IS
    --取出身份變更日期
		SELECT
			hfindate
		FROM
			common.pat_adm_financial
		WHERE
			hcaseno = pcaseno
		GROUP BY
			hfindate
		ORDER BY
			hfindate;

    --取出當日最後一個身份
		CURSOR cur_3 (
			pdate VARCHAR2
		) IS
		SELECT
			*
		FROM
			common.pat_adm_financial
		WHERE
			hcaseno = pcaseno
			AND
			hfindate = pdate
		ORDER BY
			hfininf DESC,
			common.pat_adm_financial.ins_date DESC;
		v_admit_date         DATE;
		v_st_date            DATE;
		v_date               VARCHAR2 (08);
		v_cnt                INTEGER;
		patadmfinancialrec   common.pat_adm_financial%rowtype;
    --v_CSflag varchar2(01) := 'N';
		v_hcasepay           VARCHAR2 (04);
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.extandFin';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		SELECT
			hfinancl,
			hfincl2,
			hhisnum,
			TO_DATE (hadmdt, 'yyyymmdd'),
			hcasepay
		INTO
			v_finacl1,
			v_finacl2,
			v_hpatnum,
			v_admit_date,
			v_hcasepay
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = pcaseno;
    /*
            SELECT bil_root.blcsfg
              INTO v_CSflag
              FROM bil_root
             WHERE bil_root.caseno = pCaseNo ;
    */

		--20200413兵役複檢相關特約'1031','1034','1033','1194'
		FOR r_bil_contr IN (
			SELECT
				*
			FROM
				bil_contr
			WHERE
				bilcunit IN (
					'1031',
					'1034',
					'1033',
					'1194'
				)
				AND
				caseno = pcaseno
		) LOOP
			--強制都為LABI
			INSERT INTO tmp_fincal (
				caseno,
				fincalcode,
				st_date,
				end_date
			) VALUES (
				pcaseno,
				'LABI',
				r_bil_contr.bilcbgdt,
				r_bil_contr.bilcendt
			);
			--再加 103X for 膳食
			INSERT INTO tmp_fincal (
				caseno,
				fincalcode,
				st_date,
				end_date
			) VALUES (
				pcaseno,
				r_bil_contr.bilcunit,
				r_bil_contr.bilcbgdt,
				r_bil_contr.bilcendt
			);
		END LOOP;
		FOR r_tmp_fincal IN (
			SELECT
				*
			FROM
				tmp_fincal
			WHERE
				fincalcode IN (
					'1031',
					'1034',
					'1033',
					'1194'
				)
				AND
				caseno = pcaseno
		) LOOP
			COMMIT WORK;
			return;
		END LOOP;
		v_cnt            := 0;
		OPEN cur_2;
		LOOP
			FETCH cur_2 INTO v_date;
			EXIT WHEN cur_2%notfound;
			v_cnt       := v_cnt + 1;

      --取出該日期最後的身份
			OPEN cur_3 (v_date);
			FETCH cur_3 INTO patadmfinancialrec;
			CLOSE cur_3;
			v_st_date   := TO_DATE (patadmfinancialrec.hfindate, 'yyyymmdd');
			IF patadmfinancialrec.hfinancl LIKE 'NHI%' THEN
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					'LABI',
					v_st_date,
					trunc (SYSDATE)
				);
				IF patadmfinancialrec.hfinancl = 'NHI4' THEN
					--p_disfin (pcaseno => pcaseno, pfinacl => 'VTAN', pdiscfin => v_other_fincal);
					get_discfin (pcaseno, 'VTAN', v_other_fincal);
					IF v_other_fincal = 'VTAN' THEN
						INSERT INTO tmp_fincal (
							caseno,
							fincalcode,
							st_date,
							end_date
						) VALUES (
							pcaseno,
							'VTAN',
							v_st_date,
							trunc (SYSDATE)
						);
					ELSE
						INSERT INTO tmp_fincal (
							caseno,
							fincalcode,
							st_date,
							end_date
						) VALUES (
							pcaseno,
							v_other_fincal,
							v_st_date,
							SYSDATE
						);
					END IF;
				END IF;
			ELSIF patadmfinancialrec.hfinancl = 'CIVC' THEN
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					'CIVC',
					v_st_date,
					trunc (SYSDATE)
				);
			END IF;
			IF patadmfinancialrec.hfincl2 IS NOT NULL THEN
				IF patadmfinancialrec.hfincl2 = 'VTAN' THEN
					--p_disfin (pcaseno => pcaseno, pfinacl => 'VTAN', pdiscfin => v_other_fincal);
					get_discfin (pcaseno, v_finacl2, v_other_fincal);
					INSERT INTO tmp_fincal (
						caseno,
						fincalcode,
						st_date,
						end_date
					) VALUES (
						pcaseno,
						v_other_fincal,
						v_st_date,
						trunc (SYSDATE)
					);
				ELSE
					INSERT INTO tmp_fincal (
						caseno,
						fincalcode,
						st_date,
						end_date
					) VALUES (
						pcaseno,
						patadmfinancialrec.hfincl2,
						v_st_date,
						trunc (SYSDATE)
					);
				END IF;
			END IF;

      --第二筆身份資料
			IF v_cnt > 1 THEN
				UPDATE tmp_fincal
				SET
					end_date = v_st_date - 1
				WHERE
					caseno = pcaseno
					AND
					st_date < v_st_date
					AND
					end_date = trunc (SYSDATE);
			END IF;
		END LOOP;
		CLOSE cur_2;

    --如果上面的迴圈都沒抓到資料的話
		IF v_cnt = 0 THEN
			IF v_finacl1 LIKE 'NHI%' THEN
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					'LABI',
					v_admit_date,
					SYSDATE
				);
				IF v_finacl1 = 'NHI4' THEN
					--p_disfin (pcaseno => pcaseno, pfinacl => 'VTAN', pdiscfin => v_other_fincal);
					get_discfin (pcaseno, 'VTAN', v_other_fincal);
					IF v_other_fincal = 'VTAN' THEN
						INSERT INTO tmp_fincal (
							caseno,
							fincalcode,
							st_date,
							end_date
						) VALUES (
							pcaseno,
							'VTAN',
							v_admit_date,
							SYSDATE
						);
					ELSE
						INSERT INTO tmp_fincal (
							caseno,
							fincalcode,
							st_date,
							end_date
						) VALUES (
							pcaseno,
							v_other_fincal,
							v_admit_date,
							SYSDATE
						);
					END IF;
				END IF;
			ELSIF v_finacl1 = 'CIVC' THEN
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					'CIVC',
					v_admit_date,
					SYSDATE
				);
			END IF;
		END IF;
		IF TRIM (v_finacl2) IS NOT NULL THEN
			IF v_finacl2 = 'VTAN' THEN
				-- p_disfin (pcaseno => pcaseno, pfinacl => 'VTAN', pdiscfin => v_other_fincal);
				get_discfin (pcaseno, v_finacl2, v_other_fincal);
				IF v_other_fincal = 'VTAN' THEN
					INSERT INTO tmp_fincal (
						caseno,
						fincalcode,
						st_date,
						end_date
					) VALUES (
						pcaseno,
						'VTAN',
						v_admit_date,
						SYSDATE
					);
				ELSE
					INSERT INTO tmp_fincal (
						caseno,
						fincalcode,
						st_date,
						end_date
					) VALUES (
						pcaseno,
						v_other_fincal,
						v_admit_date,
						SYSDATE
					);
				END IF;
			ELSE
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					v_finacl2,
					v_admit_date,
					SYSDATE
				);
			END IF;
		END IF;
		OPEN cur_1;
		LOOP
			FETCH cur_1 INTO bilcontrrec;
			EXIT WHEN cur_1%notfound;
			INSERT INTO tmp_fincal (
				caseno,
				fincalcode,
				st_date,
				end_date
			) VALUES (
				pcaseno,
				bilcontrrec.bilcunit,
				bilcontrrec.bilcbgdt,
				bilcontrrec.bilcendt
			);

      --1046 AND CIVC IS LIKE LABI
			IF bilcontrrec.bilcunit = '1046' AND patadmfinancialrec.hfinancl = 'CIVC' THEN
				DELETE FROM tmp_fincal
				WHERE
					caseno = pcaseno
					AND
					fincalcode = 'CIVC';
				COMMIT WORK;
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					'LABI',
					bilcontrrec.bilcbgdt,
					bilcontrrec.bilcendt
				);
        --add for 1046 not for all adm by kuo 20170818  
				SELECT
					nvl (dischg_date, SYSDATE)
				INTO v_dischg_date
				FROM
					bil_root
				WHERE
					caseno = pcaseno;
				IF v_dischg_date > bilcontrrec.bilcendt THEN
					INSERT INTO tmp_fincal (
						caseno,
						fincalcode,
						st_date,
						end_date
					) VALUES
              --(pCaseNo, 'LABI', v_st_date, TRUNC(sysdate));
					 (
						pcaseno,
						'CIVC',
						bilcontrrec.bilcendt + 1,
						(
							SELECT
								nvl (dischg_date, SYSDATE)
							FROM
								bil_root
							WHERE
								caseno = pcaseno
						)
					);
				END IF;
				COMMIT WORK;
			END IF;
		END LOOP;
		CLOSE cur_1;
		set_1060_financial (pcaseno);
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --帳款計算
	PROCEDURE compacntwk (
		pcaseno VARCHAR2
	) IS
		biloccurrec          bil_occur%rowtype;
		bilrootrec           bil_root%rowtype;

    --找數量大於0的BIL_OCCUR
    --ADD ELF_FLAG=D FOR DRG 不入帳 BY KUO 1000831
    --Add '74799940','74799941','74799942','74799943' for 帳務不算 by kuo 20190701
		CURSOR cur_occur IS
		SELECT
			*
		FROM
			bil_occur
		WHERE
			caseno = pcaseno
			AND
			qty != 0
			AND
			(elf_flag != 'D'
			 OR
			 biling_calculate_pkg.f_getnhrangeflag (caseno, bildate, '2') = 'CIVC')
         --AND PF_KEY <> '74701694'  --add by kuo 20190610 for 帳務不算
			AND
			pf_key NOT IN (
				'74701694',
				'74799940',
				'74799941',
				'74799942',
				'74799943'
			)
      --and bil_occur.PF_KEY in ('55101030')
		ORDER BY
			fee_kind,
			bil_date;

    --找特殊收費檔PFCLASS+tmp_fincal(含歷史檔)有無"LABI資料"
		CURSOR cur_pfclass_fincal_labi (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			*
		FROM
			(
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100,
					to_number (pfchild),
					pfaemep,
					pfopfg,
					pfspexam,
					pfinnseq
				FROM
					pfclass,
					tmp_fincal
				WHERE
					tmp_fincal.caseno = pcaseno
                    --                AND pfinbdt <= biling_common_pkg.f_return_date(pBildate)
                    --                AND pfinedt >= biling_common_pkg.f_return_date(pBildate)
					AND
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					tmp_fincal.fincalcode = 'LABI'
					AND
					tmp_fincal.st_date <= pbildate
					AND
					tmp_fincal.end_date >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'LABI'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
				ORDER BY
					pfinbdt DESC
			)
		UNION
		SELECT
			*
		FROM
			(
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100,
					to_number (pfchild),
					pfaemep,
					pfopfg,
					pfspexam,
					pfinnseq
				FROM
					pfhiscls,
					tmp_fincal
				WHERE
					tmp_fincal.caseno = pcaseno
                    --                AND pfinbdt <= biling_common_pkg.f_return_date(pBildate)
                    --                AND pfinedt >= biling_common_pkg.f_return_date(pBildate)
					AND
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					tmp_fincal.fincalcode = 'LABI'
					AND
					tmp_fincal.st_date <= pbildate
					AND
					tmp_fincal.end_date >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'LABI'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
				ORDER BY
					pfinbdt DESC
			);

    --找特殊收費檔PFCLASS+tmp_fincal(含歷史檔)有無"非LABI資料"
		CURSOR cur_pfclass_fincal_notlabi (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfincode
		FROM
			pfclass,
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
            --        AND pfinbdt <= biling_common_pkg.f_return_date(pBildate)
            --        AND pfinedt >= biling_common_pkg.f_return_date(pBildate)
			AND
			pfbegindate <= pbildate
			AND
			pfenddate >= pbildate
			AND
			tmp_fincal.fincalcode = pfincode
			AND
			tmp_fincal.st_date <= pbildate
			AND
			tmp_fincal.end_date >= pbildate
			AND
			pfkey = ppfkey
			AND
			pfincode <> 'LABI'
			AND
			(pfinoea = 'A'
			 OR
			 pfinoea = '@')
		UNION
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfincode
		FROM
			pfhiscls,
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
            --        AND biling_common_pkg.f_get_chdate(pfhiscls.pfinbdt) <= pBildate
            --        AND biling_common_pkg.f_get_chdate(pfhiscls.pfinedt) >= pBildate
			AND
			pfbegindate <= pbildate
			AND
			pfenddate >= pbildate
			AND
			tmp_fincal.fincalcode = pfincode
			AND
			tmp_fincal.st_date <= pbildate
			AND
			tmp_fincal.end_date >= pbildate
			AND
			pfkey = ppfkey
			AND
			pfincode <> 'LABI'
			AND
			(pfinoea = 'A'
			 OR
			 pfinoea = '@');

    --找特殊收費檔PFCLASS+tmp_fincal(含歷史檔)有無"VTAN資料"
		CURSOR cur_pfclass_fincal_vtan (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			*
		FROM
			(
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100,
					to_number (pfchild),
					pfincode
				FROM
					pfclass,
					tmp_fincal
				WHERE
					tmp_fincal.caseno = pcaseno
                    --                AND pfinbdt <= biling_common_pkg.f_return_date(pBildate)
                    --                AND pfinedt >= biling_common_pkg.f_return_date(pBildate)
					AND
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					tmp_fincal.fincalcode = pfincode
					AND
					tmp_fincal.st_date <= pbildate
					AND
					tmp_fincal.end_date >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'VTAN'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
				ORDER BY
					pfinnseq DESC,
					to_number (pfselpay) ASC
			)
		UNION
		SELECT
			*
		FROM
			(
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100,
					to_number (pfchild),
					pfincode
				FROM
					pfhiscls,
					tmp_fincal
				WHERE
					tmp_fincal.caseno = pcaseno
                    --                AND pfinbdt <= biling_common_pkg.f_return_date(pBildate)
                    --                AND pfinedt >= biling_common_pkg.f_return_date(pBildate)
					AND
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					tmp_fincal.fincalcode = pfincode
					AND
					tmp_fincal.st_date <= pbildate
					AND
					tmp_fincal.end_date >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'VTAN'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
				ORDER BY
					pfinnseq DESC,
					to_number (pfselpay) ASC
			);

    --找pflabi(含歷史檔)有無"LABI資料"
		CURSOR cur_pflabi_labi (
			ppfkey      VARCHAR2,
			vpfinnseq   VARCHAR2
		) IS
		SELECT DISTINCT
			rtrim (pflabcd),
			pflabqy
		FROM
			pflabi
		WHERE
			pfkey = ppfkey
			AND
			pfincode = 'LABI'
			AND
			pfinnseq = vpfinnseq
			AND
			(pfinoea = 'A'
			 OR
			 pfinoea = '@')
		UNION
		SELECT DISTINCT
			rtrim (pflabcd),
			pflabqy
		FROM
			pfhislab
		WHERE
			pfkey = ppfkey
			AND
			pfincode = 'LABI'
			AND
			pfinnseq = vpfinnseq
			AND
			(pfinoea = 'A'
			 OR
			 pfinoea = '@');

    --找pfmlog
		CURSOR cur_pfmlog (
			ppfkey   VARCHAR2,
			pdate    DATE,
			pamt     NUMBER
		) IS
		SELECT
			*
		FROM
			pfmlog
		WHERE
			pfmlog.pfkey = ppfkey
			AND
			pfmlog.enddatetime IN (
				SELECT
					MIN (pfmlog.enddatetime) --modify by kuo 981221
				FROM
					pfmlog
				WHERE
					pfmlog.pfkey = ppfkey
					AND
					substr (pfmlog.enddatetime, 1, 8) >= TO_CHAR (pdate, 'yyyymmdd') --MODIFY BY kUO 970616
					AND
					pfmlog.pflprice <> pamt
                 --AND pfmlog.pflprice <> 0 --mark BY kUO 20140717 因應材料有0元的
					AND
					pfmlog.pfldbtyp = 'A'
			) --modify by tenya 990923)
			AND
			pfmlog.pfldbtyp = 'A'; --modify by kuo 981221

    --找折扣檔discdtl有無"非LABI資料"
		CURSOR cur_discount_notlabi (
			pbiltype VARCHAR2
		) IS
		SELECT
			bil_discdtl.salf_per,
			bil_discdtl.bilkey,
			bil_discdtl.insu_per
		FROM
			bil_discdtl,
			tmp_fincal
		WHERE
			bil_discdtl.pftype = biloccurrec.fee_kind
			AND
			bil_discdtl.bilkind = pbiltype
			AND
			(bil_discdtl.bilkey LIKE tmp_fincal.fincalcode || '%'
			 OR
			 bil_discdtl.bilkey = tmp_fincal.fincalcode)
			AND
			(substr (bil_discdtl.bilkey, 5, 1) <> 'M'
			 OR
			 length (bil_discdtl.bilkey) = 4)
			AND
			bil_discdtl.begymd <= biloccurrec.bil_date
			AND
			bil_discdtl.endymd >= biloccurrec.bil_date
			AND
			tmp_fincal.st_date <= biloccurrec.bil_date
			AND
			tmp_fincal.end_date >= biloccurrec.bil_date
			AND
			tmp_fincal.caseno = pcaseno
			AND
			tmp_fincal.fincalcode <> 'LABI'
		ORDER BY
			salf_per;

    --找特殊收費檔PFCLASS(不含歷史檔)有無"LABI資料"
		CURSOR cur_pfclass_labi (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfaemep,
			pfopfg,
			pfspexam,
			pfinnseq
		FROM
			pfclass
		WHERE
			pfclass.pfkey = ppfkey
            --        AND pfclass.pfinbdt <= biling_common_pkg.f_return_date(pBildate)
            --        AND pfclass.pfinedt >= biling_common_pkg.f_return_date(pBildate)
			AND
			pfbegindate <= pbildate
			AND
			pfenddate >= pbildate
			AND
			pfclass.pfincode = 'LABI'
			AND
			(pfclass.pfinoea = 'A'
			 OR
			 pfclass.pfinoea = '@')
		ORDER BY
			pfclass.pfinbdt DESC;

    --找特殊收費檔PFCLASS(不含歷史檔)有無"非LABI資料"
		CURSOR cur_pfclass_notlabi (
			ppfkey VARCHAR2
		) IS
		SELECT
			pfclass.*
		FROM
			pfclass,
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
			AND
			pfclass.pfincode || pfinoea = '0' || tmp_fincal.fincalcode
			AND
			pfclass.pfkey = ppfkey
			AND
			tmp_fincal.fincalcode <> 'LABI';

    --找特殊收費檔PFCLASS(不含歷史檔)有無特約身份 by kuo 20151103
		CURSOR cur_pfclass_contr (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			pfclass.*
		FROM
			pfclass,
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
			AND
			pfincode = tmp_fincal.fincalcode
			AND
			pfbegindate <= pbildate
			AND
			pfenddate >= pbildate
			AND
			pfkey = ppfkey
			AND
			(tmp_fincal.fincalcode NOT IN (
				'LABI',
				'CIVC'
			)
			 AND
			 tmp_fincal.fincalcode NOT LIKE 'VT%');

    --尋找可以兒童專科加成60%的醫生名單 by kuo, SQL Provided by 以婷 20140306
    --20171006根據育誠將中文調成代碼更動
    --20171108 依總局答覆:次專科小兒外科與兒童青少年精神科不屬於小兒專科醫師,故不符小兒科專科醫師診察費加 by 巫俊卿,只留專科類別 IN ('MAIN0004')
		CURSOR ped_cardno (
			pdocno VARCHAR2
		) IS
		SELECT
			cardno
		FROM
			common.psbasic_vghtc
       --WHERE ((專科類別='兒專' AND 專科效期迄>='1030201' AND TITLE IN ('2014','7074')) OR
		WHERE
			((專科類別 = 'MAIN0004'
			  AND
			  專科效期迄 >= '1030201'
			  AND
			  title IN (
				  '2014',
				  '7074'
			  )) --OR
              --(次專科類別 IN('兒牙專','兒青精專','小兒外科','兒青','兒童青少年精神科') AND TITLE NOT  IN  ('2004') ) OR
              --(次專科類別 IN ('SUB0005','SUB0047','SUB0048') AND TITLE NOT  IN  ('2004') ) OR
              --(CARDNO='C397')  OR             
              --(CARDNO='3763') OR  
              --(CARDNO='A288'))
			  )
			AND
			nvl (pslvflag, 'N') NOT IN (
				'Y',
				'1'
			)
			AND
			醫師章號 = pdocno;

    --錯誤訊息用途
		v_program_name       VARCHAR2 (80);
		v_session_id         NUMBER (10);
		v_error_code         VARCHAR2 (20);
		v_error_msg          VARCHAR2 (400);
		v_error_info         VARCHAR2 (600);
		v_source_seq         VARCHAR2 (20);
		e_user_exception EXCEPTION;
		subject              VARCHAR (120);
		message              VARCHAR2 (32767);
		v_babyflag           VARCHAR2 (01) := 'N'; --母嬰關係
		v_yy                 INTEGER; --病患年齡
		ls_date              VARCHAR2 (10);
		v_child_flag_1       VARCHAR2 (01); --兒童加乘
		v_child_flag_2       VARCHAR2 (01); --兒童加乘
		v_child_flag_3       VARCHAR2 (01); --兒童加乘
		v_labchild_inc       VARCHAR2 (01); --提升兒童加成急做 add by kuo 20140128
		v_lab_qty            INTEGER := 0;
		i_count              INTEGER := 0; --計數器
		v_lab_disc_pert      NUMBER (5, 2); --檢驗折扣數
		pfclassrec           pfclass%rowtype;
		bilacntwkrec         bil_acnt_wk%rowtype;
		bilfeedtlrec         bil_feedtl%rowtype;
		bilfeemstrec         bil_feemst%rowtype;
		pfmlogrec            pfmlog%rowtype;
		v_self_price         NUMBER (10, 2);
		v_nh_price           NUMBER (10, 2);
		v_other_price        NUMBER (10, 2);
		v_other_fincal       VARCHAR2 (10);
		v_price              NUMBER (10, 2);
		v_salf_per           NUMBER (5, 2);
		v_fincal             VARCHAR2 (10);
		v_ud_qty             NUMBER (10, 2);
		v_ud_mstdcl          VARCHAR2 (20);
		v_udd_payself        VARCHAR2 (01);
		v_other_amt          NUMBER (10, 2);
		v_nh_amt             NUMBER (10, 2);
		v_self_amt           NUMBER (10, 2);
		v_emg_per            NUMBER (5, 2);
		v_fee_type           VARCHAR2 (10);
		v_day                INTEGER;
		v_labprice           NUMBER (10, 1);
		v_nh_amt1            NUMBER (10, 1);
		v_cnt                INTEGER;
		v_pf_self_pay        NUMBER (10, 1);
		v_pf_nh_pay          NUMBER (10, 1);
		v_pf_child_pay       NUMBER (10, 1);
		v_labchild           VARCHAR2 (01);
		v_ins_fee_code       VARCHAR2 (20) := NULL;
		v_pfemep             NUMBER (5, 2);
		v_fee_kind           VARCHAR2 (10); --院內計價類別
		v_nhipric            NUMBER (10, 2);
		v_limit_amt          NUMBER (10, 0);
		v_faemep_flag        VARCHAR2 (01) := 'N'; --住診是否可計急作flag
		v_pfopfg_flag        VARCHAR2 (01) := 'N'; --手術否
		v_pfspexam           VARCHAR2 (01) := 'N'; --特殊檢查否
		v_acnt_seq           NUMBER (5, 0) := 0;
		v_e_level            VARCHAR2 (01) := '1';
		v_babyselfdate       DATE;
		v_pricety1           VARCHAR2 (02); --費用類別
		v_labi_qty           INTEGER;
		v_dietselfprice      NUMBER (8, 2);
		v_dietnhprice        NUMBER (8, 2);
		v_dietunit           VARCHAR2 (10);
		v_nh_diet_flag       VARCHAR2 (01) := 'N';
		v_fincode            VARCHAR2 (10);
		v_keep_amount_flag   VARCHAR2 (01) := 'N'; --記錄是否保持billtemp中的價格之註記,註記為'Y'者,不再重新計算 amount
		v_days               INTEGER;
		v_lastdate           DATE;
		v_disctype           VARCHAR2 (01);
		v_insu_per           NUMBER (5, 2);
		v_breakflag          VARCHAR2 (01) := 'N';
		v_breaktime          VARCHAR2 (20);
		vpfinseq             VARCHAR2 (04);
		v0921                INTEGER := 0; --add by kuo for 0921
		v_exception_flag     VARCHAR2 (01) := 'N';
		prj901               NUMBER; --ADD BY KUO 1010111 FOR 油症患者免部份負擔
		adt1                 DATE;
		adt2                 DATE;
		vcardno              VARCHAR2 (8); --Add by kuo for 兒童專科加成60%的醫生名單 20140306
	BEGIN
    --設定程式名稱及session_id
		v_program_name                  := 'biling_calculate_PKG.CompAcntWk';
		v_session_id                    := userenv ('SESSIONID');
		v_source_seq                    := pcaseno;
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			bil_root.caseno = pcaseno;

    --【檢查*兒童加乘:取出病患年齡,判斷是否符合兒童加乘(6歲以下 , 二歲以下 ,六個月以下)
    /*
    ls_date := biling_common_pkg.f_datebetween(b_date => bilRootRec.Birth_Date,
                                               e_date => bilRootRec.Admit_Date);
    v_yy    := TO_NUMBER(to_char(bilRootRec.Admit_Date, 'yyyy')) -
               TO_NUMBER(to_char(bilRootRec.Birth_Date, 'yyyy'));
    IF v_yy > 6 THEN
      --年齡大於6歲,沒有兒童加乘
      v_child_flag_1 := 'N';
      v_child_flag_2 := 'N';
      v_child_flag_3 := 'N';
    ELSE
      --小於六歲大於二歲者
      IF v_yy <= 6 AND v_yy > 2 THEN
        v_child_flag_1 := 'Y';
      ELSE
        --年齡小於一歲,月份又小於六個月
        IF substr(ls_date, 1, 2) = '00' AND
           TO_NUMBER(substr(ls_date, 4, 2)) < 6 THEN
          v_child_flag_3 := 'Y';
        ELSE
          --小於二歲大於六個月
          v_child_flag_2 := 'Y';
        END IF;
      END IF;
    END IF;
    */
		v_child_flag_1                  := 'N';
		v_child_flag_2                  := 'N';
		v_child_flag_3                  := 'N';
		IF bilrootrec.birth_date IS NOT NULL THEN
			adt1      := TO_DATE (TO_CHAR (bilrootrec.birth_date, 'YYYYMM') || '01', 'YYYYMMDD');
			adt2      := TO_DATE (TO_CHAR (bilrootrec.admit_date, 'YYYYMM') || '01', 'YYYYMMDD');
			ls_date   := round (months_between (adt2, adt1), 0);
			IF ls_date < 6 THEN --小於六個月
				v_child_flag_3 := 'Y';
			END IF;
			IF ls_date <= 23 AND ls_date >= 6 THEN ---二歲到六個月之間
				v_child_flag_2 := 'Y';
			END IF;
			IF ls_date >= 24 AND ls_date <= 83 THEN --六歲以下
				v_child_flag_1 := 'Y';
			END IF;
		END IF;
    --檢查*兒童加乘】

    --【新增*費用清單主檔
		bilfeemstrec.caseno             := pcaseno;
		bilfeemstrec.st_date            := trunc (bilrootrec.admit_date);
    --找出帳檔中最大的入帳日期
		SELECT
			MAX (bil_occur.bil_date)
		INTO
			bilfeemstrec
		.end_date
		FROM
			bil_occur
		WHERE
			bil_occur.caseno = pcaseno;
    --找出急性病床天數
		bilfeemstrec.emg_bed_days       := trunc (bilfeemstrec.end_date) - trunc (bilfeemstrec.st_date);
		IF bilfeemstrec.emg_bed_days = 0 THEN
			bilfeemstrec.emg_bed_days := 1;
		END IF;
		bilfeemstrec.emg_exp_amt1       := 0; --急性第一階段費用
		bilfeemstrec.emg_pay_amt1       := 0; --急性第一階段部份負擔
		bilfeemstrec.emg_exp_amt2       := 0; --急性第二階段費用
		bilfeemstrec.emg_pay_amt2       := 0; --急性第二階段部份負擔
		bilfeemstrec.emg_exp_amt3       := 0; --急性第三階段費用
		bilfeemstrec.emg_pay_amt3       := 0; --急性第三階段部份負擔
		bilfeemstrec.tot_self_amt       := 0; --部份負擔總額
		bilfeemstrec.tot_gl_amt         := 0; --自付總額
		bilfeemstrec.credit_amt         := 0; --其他特約金額
		bilfeemstrec.created_by         := 'biling'; --建立者
		bilfeemstrec.creation_date      := SYSDATE; --建立日期
		bilfeemstrec.last_updated_by    := 'biling'; --最後更新日期
		bilfeemstrec.last_update_date   := SYSDATE; --最後更新者
		INSERT INTO bil_feemst VALUES bilfeemstrec;
    --新增*費用清單主檔】

    --【更新*檢驗折扣數
		IF v_lab_qty <= 40 THEN
			v_lab_disc_pert := 1;
		ELSIF v_lab_qty >= 40 AND v_lab_qty <= 60 THEN
			v_lab_disc_pert := 0.9;
		ELSE
			v_lab_disc_pert := 0.8;
		END IF;
		UPDATE bil_root
		SET
			bil_root.lab_disc_pert = v_lab_disc_pert
		WHERE
			bil_root.caseno = pcaseno;
    --更新*檢驗折扣數】

    --找數量大於0的BIL_OCCUR
		OPEN cur_occur;
		LOOP
      --【檢查*v_breakFlag
			BEGIN
				SELECT
					bil_codedtl.code_desc
				INTO v_breakflag
				FROM
					bil_codedtl
				WHERE
					bil_codedtl.code_type = 'BREAKPOINT'
					AND
					bil_codedtl.code_no = 'BREAKFLAG';
			EXCEPTION
				WHEN OTHERS THEN
					v_breakflag := 'N';
			END;
			IF v_breakflag = 'Y' THEN
				BEGIN
					SELECT
						bil_codedtl.code_desc
					INTO v_breaktime
					FROM
						bil_codedtl
					WHERE
						bil_codedtl.code_type = 'BREAKPOINT'
						AND
						bil_codedtl.code_no = 'BREAKTIME';
					IF TO_CHAR (SYSDATE, 'YYYYMMDDHH24MI') > v_breaktime THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
						ROLLBACK WORK;
						DELETE FROM biling_spl_errlog
						WHERE
							session_id = v_session_id
							AND
							prog_name = v_program_name;
						INSERT INTO biling_spl_errlog (
							session_id,
							sys_date,
							prog_name,
							err_code,
							err_msg,
							err_info,
							source_seq
						) VALUES (
							v_session_id,
							SYSDATE,
							v_program_name,
							v_error_code,
							v_error_msg,
							v_error_info,
							v_source_seq
						);
						COMMIT WORK;
						return;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
			END IF;
      --檢查*v_breakFlag 】
			FETCH cur_occur INTO biloccurrec;
			EXIT WHEN cur_occur%notfound;
			IF biloccurrec.qty IS NULL THEN
				biloccurrec.qty := 1;
			END IF;

      --【初使值設定
			v_nh_diet_flag              := 'N';
			v_fincal                    := '';
			v_other_fincal              := '';
			v_keep_amount_flag          := 'N';
			v_other_amt                 := 0;
			v_other_price               := 0;
			v_pf_self_pay               := 0;
      --初使值設定】

      --先抓出dbpfile中的計價類別v_pricety1
			BEGIN
				SELECT
					pricety1 --dbpfile之費用類別
				INTO v_pricety1
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = biloccurrec.pf_key;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
			END;
			IF v_pricety1 IS NULL THEN
				v_pricety1 := biloccurrec.fee_kind;
			END IF;
			v_fee_kind                  := v_pricety1;
      --若費用類別為:10一般材料費、14特殊材料費
			IF biloccurrec.fee_kind IN (
				'10',
				'14'
			) THEN
				IF biloccurrec.fee_kind <> v_pricety1 THEN
					v_fee_kind := v_pricety1;
				END IF;

        --若費用類別為:11手術材料費、
			ELSIF biloccurrec.fee_kind IN (
				'11',
				'48',
				'58',
				'59',
				'68'
			) THEN
				IF v_pricety1 = '07' THEN
					v_fee_kind := '11';
				END IF;
        --若費用類別為:12麻醉材料費、
			ELSIF biloccurrec.fee_kind IN (
				'12',
				'88'
			) THEN
				v_fee_kind := '12';
        --若費用類別為:13接生材料費
			ELSIF biloccurrec.fee_kind = '13' THEN
				IF v_pricety1 = '08' THEN
					v_fee_kind := '13';
				END IF;
        --若費用類別為:06藥費
			ELSIF biloccurrec.fee_kind = '06' THEN
				v_fee_kind := biloccurrec.fee_kind;
			ELSE
				v_fee_kind := v_pricety1;
			END IF;

      --【檢查*是否為需保留billtemp之價格(40電話費、02膳食費、38證書費)
      --新增拷貝片需看部門保留價格
      --IF BILOCCURREC.FEE_KIND IN ('40', '02', '38') OR
      --02類回歸dbpfile與pfmlog價錢
			IF biloccurrec.fee_kind IN (
				'40',
				'38'
			) OR (biloccurrec.income_dept = 'RAD' AND biloccurrec.pf_key = 'F01150100221') THEN
				v_keep_amount_flag := 'Y';
			ELSE
				v_keep_amount_flag := 'N';
			END IF;
			IF f_getnhrangeflag (pcaseno => pcaseno, pdate => biloccurrec.bil_date, pfinflag => '1') = 'CIVC' THEN
				IF biloccurrec.fee_kind NOT IN (
					'01',
					'03',
					'04',
					'05'
				) THEN
          --非固定費用，才需檢查要不要保留原始單價
					IF trim (biloccurrec.order_seqno) <> '0000' OR rtrim (biloccurrec.combination_item) = 'N' THEN
						v_keep_amount_flag := 'N';
					ELSE
						v_keep_amount_flag := 'Y';
					END IF;
				END IF;
			END IF;
      --檢查*是否為需保留billtemp之價格】

      --【急作乘數設定
			bilacntwkrec.emg_flag       := biloccurrec.emergency; --急作乘數
			IF v_keep_amount_flag = 'Y' THEN
				IF biloccurrec.bil_date >= TO_DATE ('2017-08-16', 'YYYY-MM-DD') THEN
					bilacntwkrec.emg_per := getemgper (pcaseno => biloccurrec.caseno, ppfkey => biloccurrec.pf_key, pfeekind => v_fee_kind, pbldate
					=> biloccurrec.bil_date, pemgflag => biloccurrec.emergency, ptype => '2');
				ELSE
					bilacntwkrec.emg_per := getemgperhist (pcaseno => biloccurrec.caseno, ppfkey => biloccurrec.pf_key, pfeekind => v_fee_kind, pbldate
					=> biloccurrec.bil_date, pemgflag => biloccurrec.emergency, ptype => '2');
				END IF;
			ELSE
				IF biloccurrec.bil_date >= TO_DATE ('2017-08-16', 'YYYY-MM-DD') THEN
					bilacntwkrec.emg_per := getemgper (pcaseno => biloccurrec.caseno, ppfkey => biloccurrec.pf_key, pfeekind => v_fee_kind, pbldate
					=> biloccurrec.bil_date, pemgflag => biloccurrec.emergency, ptype => '1');
				ELSE
					bilacntwkrec.emg_per := getemgperhist (pcaseno => biloccurrec.caseno, ppfkey => biloccurrec.pf_key, pfeekind => v_fee_kind, pbldate
					=> biloccurrec.bil_date, pemgflag => biloccurrec.emergency, ptype => '1');
				END IF;
			END IF;
      --DBMS_OUTPUT.put_line(bilOccurRec.Pf_Key||','||bilAcntWkRec.Emg_Per);
			IF bilrootrec.hfinacl = 'CIVC' AND --避免多包胎命名 by kuo 20140509
			 v_fee_kind IN (
				'01',
				'03',
				'04',
				'05',
				'30',
				'21',
				'18'
			) AND (bilrootrec.hnamec LIKE '%之%' OR bilrootrec.hnamec LIKE '%女一%' OR bilrootrec.hnamec LIKE '%女二%' OR bilrootrec.hnamec LIKE
			'%女三%' OR bilrootrec.hnamec LIKE '%男一%' OR bilrootrec.hnamec LIKE '%男二%' OR bilrootrec.hnamec LIKE '%男三%') THEN
				bilacntwkrec.emg_per := 1;
			END IF;
      --update 20101230將此二個計價碼開放 by amber
      /*IF bilOccurRec.Pf_Key = '90212608'
      OR bilOccurRec.Pf_Key = '90212609' THEN
      bilAcntWkRec.Emg_Per := 0;*/
			IF biloccurrec.pf_key = '60413200' --2008-01-01以後計價費碼60413200基本就加 0.65,至少為1.65  by Kuo 970505
			 AND biloccurrec.bil_date >= TO_DATE ('2008-01-01', 'yyyy-mm-dd') THEN
				bilacntwkrec.emg_per := bilacntwkrec.emg_per + 0.65;
			END IF;

      --add 74701623,74701624 成數為0 by kuo 20180301
			IF biloccurrec.pf_key IN (
				'74701623',
				'74701624'
			) THEN
				bilacntwkrec.emg_per := 0;
			END IF;   
      --急作乘數設定】

      --若計價日期大於出院日期,則計價日期為出院日期
			IF biloccurrec.bil_date > bilrootrec.dischg_date THEN
				biloccurrec.bil_date := trunc (bilrootrec.dischg_date);
			END IF;

      --費用代碼前補0
			IF length (v_fee_kind) = 1 THEN
				v_fee_kind := '0' || v_fee_kind;
			END IF;
			bilacntwkrec.fee_kind       := v_fee_kind;
			bilacntwkrec.order_seq      := biloccurrec.order_seqno;
			bilacntwkrec.ordseq         := biloccurrec.ordseq; -- add by kuo 20150309
      --【取出藥費單價*若費用類別為:06藥費且計價碼為006開頭
			IF biloccurrec.fee_kind = '06' AND biloccurrec.pf_key LIKE '006%' THEN
				BEGIN
          --藥品健保檔, udnsalprice:售價,udnnhiprice:健保價
					SELECT
						nvl (udnsalprice, 0),
						nvl (udnnhiprice, 0),
						udnnhicode,
						udnpayself
					INTO
						v_self_price,
						v_nh_price,
						v_ins_fee_code,
						v_udd_payself
					FROM
						cpoe.udndrgoc
					WHERE
						(udnenddate > biloccurrec.bil_date
						 OR
						 udnenddate IS NULL)
						AND
						udnbgndate <= biloccurrec.bil_date
						AND
						udndrgcode = substr (biloccurrec.pf_key, 4, 5);
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
				BEGIN
					SELECT
						udddspupi,
						uddmstdcl
					INTO
						v_ud_qty,
						v_ud_mstdcl
					FROM
						cpoe.uddrugpf
					WHERE
						udddrgcode = substr (biloccurrec.pf_key, 4, 5);
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
				IF rtrim (biloccurrec.log_location) = 'OR' OR rtrim (biloccurrec.log_location) = 'DR' OR rtrim (biloccurrec.log_location) = 'PAIN'
				OR rtrim (biloccurrec.log_location) = 'PED' OR rtrim (biloccurrec.log_location) = 'POR' OR rtrim (biloccurrec.log_location) =
				'ANE' OR rtrim (biloccurrec.log_location) = 'ANE1' OR rtrim (biloccurrec.log_location) = 'ENT' OR rtrim (biloccurrec.log_location
				) = 'NEPH' OR rtrim (biloccurrec.log_location) = 'ORC' --增加此科別 wang 2010/1/14
				 OR rtrim (biloccurrec.log_location) = 'ANEC' --增加此科別 wang 2010/1/14
				 OR rtrim (biloccurrec.log_location) = 'PORC' --增加此科別 wang 2010/1/14
				 THEN
          --特殊藥品計價設定檔,如有資料需再讀藥品主檔轉換係數
					SELECT
						COUNT (*)
					INTO v_cnt
					FROM
						bil_spec_medlist
					WHERE
						pfkey = substr (biloccurrec.pf_key, 4, 5);
					IF v_cnt > 0 THEN
						IF biloccurrec.pf_key IN (
							'006AH090',
							'006AH100'
						) THEN
							v_ud_qty := 5;
						END IF;
						v_self_price   := v_self_price / v_ud_qty;
						v_nh_price     := v_nh_price / v_ud_qty;
					END IF;
				END IF;
				v_fee_type := '13';
				IF v_udd_payself = 'Y' AND f_getnhrangeflag (pcaseno, biloccurrec.bil_date, '1') <> 'CIVC' AND biloccurrec.elf_flag <> 'Y' THEN
					v_self_price    := 0;
					v_other_price   := 0;
				END IF;
				IF v_udd_payself = 'N' --自付
				 OR f_getnhrangeflag (pcaseno, biloccurrec.bil_date, '1') = 'CIVC' OR biloccurrec.elf_flag = 'Y' THEN
					v_nh_price      := 0;
					v_other_price   := 0;
					IF v_self_price > 0 THEN
						IF biloccurrec.elf_flag = 'Y' THEN
							v_disctype := 'P';
						ELSE
							v_disctype := 'B';
						END IF;
					ELSE
						v_disctype := 'B';
					END IF;

          --找折扣檔discdtl有無"非LABI資料"
					OPEN cur_discount_notlabi (v_disctype);
					FETCH cur_discount_notlabi INTO
						v_salf_per,
						v_fincal,
						v_insu_per;
					IF cur_discount_notlabi%found THEN
						v_other_price    := v_self_price * (1 - v_salf_per);
						v_self_price     := v_self_price * v_salf_per;
						v_nh_price       := 0;
						v_other_fincal   := v_fincal;
					END IF;
					CLOSE cur_discount_notlabi;
				END IF;

        --民眾身份,藥費若是H1N1，非自費，將費用轉到健保 BY KUO 981014
				IF f_getnhrangeflag (pcaseno, biloccurrec.bil_date, '1') = 'CIVC' AND biloccurrec.elf_flag = 'N' AND biloccurrec.pf_key IN (
					'006DO400',
					'006AO300'
				) AND biloccurrec.bil_date >= TO_DATE ('20090921', 'YYYYMMDD') AND biloccurrec.bil_date <= TO_DATE ('20100331', 'YYYYMMDD') THEN
					v_nh_price      := v_self_price;
					v_self_price    := 0;
					v_other_price   := 0;
				END IF;
				IF v_udd_payself = 'V' THEN
          -- 榮民身份
					IF bilrootrec.hfinacl = 'NHI4' OR bilrootrec.hfinacl2 = 'VTAN' THEN
						i_count := 0;
						SELECT
							COUNT (*)
						INTO i_count
						FROM
							tmp_fincal
						WHERE
							caseno = bilrootrec.caseno
							AND
							fincalcode = 'VTAN';
						IF i_count > 0 THEN
              --新增* 檢查藥檔裡的藥碼是否有輔導會補助
							i_count := 0;
							SELECT
								COUNT (*)
							INTO i_count
							FROM
								cpoe.uddrugpf
							WHERE
								uddpayself = 'V' --輔導會補助
								AND
								udddrgcode = substr (biloccurrec.pf_key, 4); --藥碼為計價碼的後5碼(不含006)
						END IF;
						IF i_count > 0 THEN
							v_other_price    := v_self_price;
							v_nh_price       := 0;
							v_self_price     := 0;
							v_other_fincal   := 'VERT';
						ELSE
							v_nh_price      := 0;
							v_other_price   := 0;
						END IF;
					ELSE --榮民身份
            --v_nh_price    := 0;
            --V_OTHER_PRICE := 0; 
            --above marked by kuo 20150824 for non-nhi4 using vtan and have a discount
            --add by kuo 20150824 for non-nhi4 using vtan and have a discount
						IF v_self_price > 0 THEN
               --若自付套用PR折扣檔，非自付套用新折扣檔
							IF biloccurrec.elf_flag = 'Y' THEN
								v_disctype := 'P';
							ELSE
								v_disctype := 'B';
							END IF;
							OPEN cur_discount_notlabi (v_disctype);
							FETCH cur_discount_notlabi INTO
								v_salf_per,
								v_fincal,
								v_insu_per;
							IF cur_discount_notlabi%found THEN
								v_other_price    := v_self_price * (1 - v_salf_per);
								v_self_price     := v_self_price * v_salf_per;
								v_nh_price       := 0;
								v_other_fincal   := v_fincal;
							END IF;
							CLOSE cur_discount_notlabi;
						END IF; --v_self_price > 0
					END IF;
				END IF;
        --本段搬到前面IF裡面 by kuo 20150824
        --IF v_self_price > 0 THEN
          --若自付套用PR折扣檔，非自付套用新折扣檔
        --  IF bilOccurRec.Elf_Flag = 'Y' THEN
        --    v_discType := 'P';
        --  ELSE
        --    v_discType := 'B';
        --  END IF;
        --END IF;
        --取出藥費單價】
			ELSE

        --【取出非藥費單價*從cpoe.dbpfile
				BEGIN
					SELECT
						pfprice1, --單價
						nvl (pfemep, 0)
					INTO
						v_price,
						v_pfemep
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = biloccurrec.pf_key;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;

        --檢查歷史檔,若有在區間找到則以歷史檔單價作設定
				OPEN cur_pfmlog (biloccurrec.pf_key, biloccurrec.bil_date, v_price);
				FETCH cur_pfmlog INTO pfmlogrec;
				IF cur_pfmlog%found THEN
					v_price := pfmlogrec.pflprice;
				END IF;
				CLOSE cur_pfmlog;

        --檢查特殊計價碼 by kuo 971217
				IF biloccurrec.pf_key IN (
					'92000010',
					'92000020'
				) THEN
					v_price := biloccurrec.charge_amount / biloccurrec.qty;
				END IF;

        --計算健保價
        --【檢查*母嬰關係:是否有母親的住院號,若有則健保帳合併於母親申報
				IF TRIM (bilrootrec.hmrcase) IS NOT NULL THEN
					v_babyflag := 'Y'; --是母嬰關係,以新生兒自付設定切割健保/自付日期區間
					BEGIN
            --抓出自費起始日期
						SELECT
							bil_baby_set.effective_date
						INTO v_babyselfdate
						FROM
							bil_baby_set
						WHERE
							bil_baby_set.caseno = pcaseno;
					EXCEPTION
						WHEN OTHERS THEN
							v_babyselfdate := SYSDATE;
					END;
				ELSE
					v_babyflag       := 'N'; --非母嬰關係
					v_babyselfdate   := NULL;
				END IF;
        --檢查*母嬰關係】
				IF v_babyflag = 'Y' --是母嬰關係
				 AND f_checkbabynh (biloccurrec.pf_key) = 'Y' AND biloccurrec.bil_date <= v_babyselfdate THEN
          --找特殊收費檔PFCLASS(不含歷史檔)有無"LABI資料"
					OPEN cur_pfclass_labi (biloccurrec.pf_key, biloccurrec.bil_date);
					FETCH cur_pfclass_labi INTO
						v_pf_self_pay,
						v_pf_nh_pay,
						v_pf_child_pay,
						v_faemep_flag,
						v_pfopfg_flag,
						v_pfspexam,
						vpfinseq;
					IF cur_pfclass_labi%notfound THEN
						v_pf_self_pay    := v_price;
						v_pf_nh_pay      := 0;
						v_pf_child_pay   := 0;
						v_faemep_flag    := 'N';
						v_pfopfg_flag    := 'N';
						v_pfspexam       := 'N';
            --如果健保已算出成數以健保成數為主
						IF bilacntwkrec.emg_flag = 'E' AND bilacntwkrec.emg_per = 1 THEN
							bilacntwkrec.emg_per := 1 + (v_pfemep / 100);
						END IF;
					END IF;
					CLOSE cur_pfclass_labi;
				ELSE
          --非母嬰關係
          --找特殊收費檔PFCLASS+tmp_fincal(含歷史檔)有無"LABI資料"
					OPEN cur_pfclass_fincal_labi (biloccurrec.pf_key, biloccurrec.bil_date);
					FETCH cur_pfclass_fincal_labi INTO
						v_pf_self_pay,
						v_pf_nh_pay,
						v_pf_child_pay,
						v_faemep_flag,
						v_pfopfg_flag,
						v_pfspexam,
						vpfinseq;
					IF cur_pfclass_fincal_labi%found THEN
            --修正原程式,若有PR,但特殊收費檔的自費價為0,則不可抓取健保價格(UPDATE 20110307 Amber)
            --【手術套餐不計價
						IF biloccurrec.id = '1' THEN
							v_keep_amount_flag := 'Y';
						END IF;
            --手術套餐不計價】
            /*if bilOccurRec.Pf_Key in
               ('25110280','25110700') then
              v_exception_flag := 'Y';
            end if;*/
						IF (biloccurrec.elf_flag = 'Y' AND v_pf_self_pay = 0 AND v_keep_amount_flag = 'N' AND v_exception_flag = 'N') THEN
							v_pf_self_pay    := v_price;
							v_pf_nh_pay      := 0;
							v_pf_child_pay   := 0;
							v_faemep_flag    := 'N';
							v_pfopfg_flag    := 'N';
							v_pfspexam       := 'N';
							IF bilacntwkrec.emg_flag = 'E' AND bilacntwkrec.emg_per = 1 THEN
								bilacntwkrec.emg_per := 1 + (v_pfemep / 100);
							END IF;
              --遇到此種情形,將資料填入log檔,因此段有增加帳務處理的部份做log檔
							BEGIN
								INSERT INTO bil_test_log VALUES (
									'Amber-Check',
									'PR自費檢查1:pfkey:' || biloccurrec.pf_key || ',PR價格:' || v_pf_self_pay || ',健保價格:' || v_pf_nh_pay,
									TO_CHAR (SYSDATE, 'yyyymmdd hh24miss'),
									biloccurrec.caseno
								);
							EXCEPTION
								WHEN OTHERS THEN
									NULL;
							END;
						END IF;
					ELSE
						v_pf_self_pay    := v_price;
						v_pf_nh_pay      := 0;
						v_pf_child_pay   := 0;
						v_faemep_flag    := 'N';
						v_pfopfg_flag    := 'N';
						v_pfspexam       := 'N';
						IF bilacntwkrec.emg_flag = 'E' AND bilacntwkrec.emg_per = 1 THEN
							bilacntwkrec.emg_per := 1 + (v_pfemep / 100);
						END IF;
					END IF;
					CLOSE cur_pfclass_fincal_labi;
				END IF;

        --【找出最初單價:
        --  根據pfclass + pfhisclass找出健保價
        --  根據cpoe.dbpfile + pfmlog找出自費價
				v_self_price    := v_pf_self_pay;
				v_nh_price      := v_pf_nh_pay;
				v_other_price   := 0;
        --找出最初單價】

        --【費用類別:02膳食費判斷
        --適用日期到20130101 by kuo 1011114
				IF (biloccurrec.bil_date < TO_DATE ('20130101', 'YYYYMMDD')) AND ((bilrootrec.hfinacl IN (
					'NHI3',
					'NHI6'
				) OR
        --IF (BILROOTREC.HFINACL IN ('NHI3', 'NHI6') OR
				 (f_checknhdiet (bilrootrec.caseno) = 'Y') AND bilrootrec.hfinacl <> 'CIVC') AND v_fee_kind = '02' AND
           --ADD BY KUO 1010420 排除陪客餐,add new 陪客餐 DITG% by kuo 1010626
				 (substr (biloccurrec.pf_key, 5, 3) NOT IN (
					'TCM'
				) OR substr (biloccurrec.pf_key, 1, 4) NOT IN (
					'DITG'
				))) THEN
					v_keep_amount_flag   := 'N';
					v_nh_diet_flag       := 'Y';
					IF f_checknhdiet (bilrootrec.caseno) = 'Y' THEN
						v_lastdate   := last_day (biloccurrec.bil_date);
						v_day        := to_number (TO_CHAR (v_lastdate, 'dd'));
						IF v_day = 28 THEN
							v_fincode := 'A1';
						ELSIF v_day = 29 THEN
							v_fincode := 'A2';
						ELSIF v_day = 30 THEN
							v_fincode := 'A3';
						ELSIF v_day = 31 THEN
							v_fincode := 'A4';
						END IF;
					ELSE
						v_fincode := bilrootrec.hfinacl;
					END IF;
					BEGIN
            --計價日期等於出院日期
						IF trunc (biloccurrec.bil_date) = trunc (bilrootrec.dischg_date) THEN
							v_self_price    := 0;
							v_nh_price      := 0;
							v_other_price   := 0;
						ELSE
							SELECT
								bil_dietset.nhprice,
								bil_dietset.selfprice,
								bil_dietset.nhunitcode
							INTO
								v_dietnhprice,
								v_dietselfprice,
								v_dietunit
							FROM
								bil_dietset
							WHERE
								bil_dietset.pfincode = v_fincode
								AND
								bil_dietset.pfkey = biloccurrec.pf_key;
							IF v_dietunit = 'LABI' THEN
								v_nh_price       := v_dietnhprice;
								v_nh_diet_flag   := 'Y';
								IF biloccurrec.diet_other_price <> 0 THEN
									v_dietselfprice := v_dietselfprice + biloccurrec.diet_other_price;
								END IF;
							ELSE
								v_other_price    := v_dietnhprice;
								v_other_fincal   := v_dietunit;
								IF biloccurrec.diet_other_price <> 0 THEN
									v_other_price := v_other_price + biloccurrec.diet_other_price;
								END IF;
							END IF;
							v_self_price := v_dietselfprice;
						END IF;
					EXCEPTION
						WHEN OTHERS THEN
							v_error_code   := sqlcode;
							v_error_info   := sqlerrm;
					END;
				END IF;
        --費用類別:02膳食費判斷】

        --【有自費，且不為膳食費
				IF v_self_price > 0 AND v_nh_diet_flag <> 'Y' THEN
          --找特殊收費檔PFCLASS+tmp_fincal(含歷史檔)有無"非LABI資料"
					OPEN cur_pfclass_fincal_notlabi (biloccurrec.pf_key, biloccurrec.bil_date);
					FETCH cur_pfclass_fincal_notlabi INTO
						v_pf_self_pay,
						v_pf_nh_pay,
						v_pf_child_pay,
						v_fincal;
					IF cur_pfclass_fincal_notlabi%found THEN

            --檢查*是否為自費項且有PR@@@
						i_count := 0;
						SELECT
							COUNT (*)
						INTO i_count
						FROM
							pfclass
						WHERE
							pfkey = biloccurrec.pf_key
                  --AND pfclass.pfinbdt <= biling_common_pkg.f_return_date(bilOccurRec.Bil_Date)
                  --AND pfclass.pfinedt >= biling_common_pkg.f_return_date(bilOccurRec.Bil_Date)
							AND
							pfbegindate <= biloccurrec.bil_date
							AND
							pfenddate >= biloccurrec.bil_date
							AND
							pfincode || pfinoea = 'PR@@@'
							AND
							pfeemep = '1';
						IF NOT (biloccurrec.elf_flag = 'Y' AND i_count = 1) THEN
							v_other_price   := v_self_price - v_pf_self_pay;
							v_self_price    := v_pf_self_pay;
							IF v_fincal = 'VTAN' AND v_fee_kind NOT IN (
								'01'
							) THEN
								v_other_fincal := 'VERT'; --轉輔導會
							ELSE
								v_other_fincal := v_fincal;
							END IF;
						END IF;
					ELSE
						SELECT
							COUNT (*)
						INTO v0921
						FROM
							tmp_fincal
						WHERE
							caseno = pcaseno
							AND
							fincalcode = '0921';
            --for 0921 膳食判斷 by Kuo 980813, add new 陪客餐 by kuo 1010626
						IF (v0921 > 0) AND (biloccurrec.fee_kind = '02') THEN
							IF (substr (biloccurrec.pf_key, 5, 1) NOT IN (
								'@',
								'$',
								'*',
								'1'
							) AND (substr (biloccurrec.pf_key, 5, 3) NOT IN (
								'TCM'
							) OR substr (biloccurrec.pf_key, 1, 4) NOT IN (
								'DITG'
							))) THEN
								v_other_price   := v_self_price * (1 - v_salf_per);
								v_self_price    := v_self_price - v_other_price;
							END IF;
						ELSE
							v_disctype       := 'B'; --新折扣檔
              --找折扣檔discdtl有無"非LABI資料"
							OPEN cur_discount_notlabi (v_disctype);
							FETCH cur_discount_notlabi INTO
								v_salf_per,
								v_fincal,
								v_insu_per;
							IF cur_discount_notlabi%found THEN
								IF length (v_fincal) > 4 THEN
									v_fincal := substr (v_fincal, 1, 4);
								END IF;
								IF v_fee_kind = '01' THEN
                  --病房費優減
                  --單人房優減
									IF substr (biloccurrec.pf_key, 1, 5) = 'WARD1' THEN
										IF v_fincal = 'EMPL' THEN
                      --計價日2010/05/10以前者七折優待，以後者不打折
											IF biloccurrec.bil_date >= TO_DATE ('2010/05/10', 'yyyy/mm/dd') THEN
												v_salf_per := 1; --不打折
											ELSE
												v_salf_per := 0.7; --七折
											END IF;
                      --將官病房費優減關於 Bil_Acnt_wk BY KUO 970430 ,MODIFITY BY JEAN 2008/05/06
                      --將官可優減單人房
                    --ELSIF v_fincal <> 'VTAM' THEN
                    --changed by kuo 1010731
                    --特約2開頭才有優惠 20140605
                    --讓特約都可以用 by kuo 20140609,有問題再調回來
                    --ELSIF v_fincal <>'VTAM' AND v_fincal not like '2%' THEN
                    --  v_salf_per := 1; --不打折
										END IF;
                    --雙人房優減
									ELSIF substr (biloccurrec.pf_key, 1, 5) = 'WARD2' THEN
										IF v_fincal = 'EMPL' THEN
                      --員工
											v_salf_per := 0.5; --五折
										ELSIF v_fincal IN (
											'1054',
											'1083'
										) THEN
                      --成功嶺役男+成功嶺研發役男
											v_salf_per := 0; --全額打折
										END IF;
									END IF;
								END IF;

                --身份是榮民，檢查特殊收費檔中該計價碼是否設定為自付
								IF v_fincal = 'VTAN' THEN
									i_count := 0;
									SELECT
										COUNT (*)
									INTO i_count
									FROM
										pfclass
									WHERE
										pfkey = biloccurrec.pf_key
										AND
										pfclass.pfinbdt <= biling_common_pkg.f_return_date (biloccurrec.bil_date)
										AND
										pfclass.pfinedt >= biling_common_pkg.f_return_date (biloccurrec.bil_date)
                        --and PFBEGINDATE <= bilOccurRec.Bil_Date
                        --and PFBENDDATE >= bilOccurRec.Bil_Date
										AND
										pfincode || pfinoea = 'PR@@@'
										AND
										pfeemep = '1';
									IF i_count = 1 THEN
                    --自付,不可申報輔導會
										v_other_price   := 0;
										v_self_price    := v_self_price - v_other_price;
									ELSE
										IF bilrootrec.dischg_date IS NULL OR bilrootrec.dischg_date >= TO_DATE ('2010/03/01', 'yyyy/mm/dd') THEN
                      --新增*檢查在pfclass中，該計價碼有核准文號才可申報輔導會(2010/3之後才套用此規則)
											i_count := 0;
											SELECT
												COUNT (*)
											INTO i_count
											FROM
												pfclass
											WHERE
												pfkey = biloccurrec.pf_key
												AND
												pfincode = 'VTAN';
											IF i_count = 1 THEN
                        --申報輔導會
												v_other_price   := v_self_price * (1 - v_salf_per);
												v_self_price    := v_self_price - v_other_price;
											END IF;
										ELSE
                      --申報輔導會
											v_other_price   := v_self_price * (1 - v_salf_per);
											v_self_price    := v_self_price - v_other_price;
										END IF;
									END IF;
								ELSE

                  --身份不是榮民，參考折扣檔
									v_other_price   := v_self_price * (1 - v_salf_per);
									v_self_price    := v_self_price - v_other_price;
								END IF;
							END IF;
							IF v_fincal = 'VTAN' AND v_insu_per > 0 THEN
								v_fincal := 'VERT';
							END IF;
							v_other_fincal   := v_fincal;
							CLOSE cur_discount_notlabi;
						END IF;
					END IF;
					CLOSE cur_pfclass_fincal_notlabi;
				END IF;
        ----有自費，且不為膳食費】

        --【是否為自費項
        --  是-->若為榮民看有無特殊收費檔可折扣)
        --  否-->單人房，榮民或員工有折扣
				IF biloccurrec.elf_flag = 'Y' THEN
          --榮民
          --找特殊收費檔PFCLASS+tmp_fincal(含歷史檔)有無"VTAN資料"
					OPEN cur_pfclass_fincal_vtan (biloccurrec.pf_key, biloccurrec.bil_date);
					FETCH cur_pfclass_fincal_vtan INTO
						v_pf_self_pay,
						v_pf_nh_pay,
						v_pf_child_pay,
						v_fincal;
					IF cur_pfclass_fincal_vtan%found THEN
						i_count := 0;
						SELECT
							COUNT (*)
						INTO i_count
						FROM
							pfclass
						WHERE
							pfkey = biloccurrec.pf_key
                  --AND pfclass.pfinbdt <= biling_common_pkg.f_return_date(bilOccurRec.Bil_Date)
                  --AND pfclass.pfinedt >= biling_common_pkg.f_return_date(bilOccurRec.Bil_Date)
							AND
							pfbegindate <= biloccurrec.bil_date
							AND
							pfenddate >= biloccurrec.bil_date
							AND
							pfincode || pfinoea = 'PR@@@'
							AND
							pfeemep = '1';

             --特殊計價碼需由輔導會申報(update by amber)
						IF i_count = 0 OR biloccurrec.pf_key IN (
							'30082500',
							'30082510',
							'30082530',
							'30087260',
							'30088030',
							'30088080',
							'30088460'
						) THEN
							v_nh_price       := 0;
							v_other_price    := v_pf_nh_pay;
							v_self_price     := v_pf_self_pay;
							v_other_fincal   := v_fincal;
							IF v_fincal = 'VTAN' AND v_other_price > 0 THEN
								v_other_fincal := 'VERT';
							END IF;
						END IF;

            --以自費計
					ELSE
						v_self_price    := v_price;
						v_nh_price      := 0;
						v_other_price   := 0;

            --判斷是否折扣身份
						IF biloccurrec.elf_flag = 'Y' THEN
							v_disctype := 'P';
						ELSE
							v_disctype := 'B';
						END IF;

            --判斷是否為榮民
            --找折扣檔discdtl有無"非LABI資料"
						OPEN cur_discount_notlabi (v_disctype);
						FETCH cur_discount_notlabi INTO
							v_salf_per,
							v_fincal,
							v_insu_per;
						IF cur_discount_notlabi%found THEN
							IF biloccurrec.pf_key = 'WARD1' THEN
								IF v_fincal = 'EMPL' THEN
                  --計價日2010/05/10以前者七折優待，以後者不打折
									IF biloccurrec.bil_date >= TO_DATE ('2010/05/10', 'yyyy/mm/dd') THEN
										v_salf_per := 1;
									ELSE
										v_salf_per := 0.7;
									END IF;
								ELSIF v_fincal = 'VTAN' THEN
									v_salf_per := 0.7;
								ELSE
									v_salf_per := 1;
								END IF;
							END IF;
              --v_self_price   := v_price * v_salf_per;
              --v_nh_price     := 0;
              --v_other_price  := v_price - v_self_price;
              --V_OTHER_FINCAL := V_FINCAL;
              --核醫部份計價碼不走員工折扣 by kuo 20150630
              --自費營養品NUT%部份不走員工折扣 by kuo 20161123
							IF NOT (v_fincal = 'EMPL' AND (biloccurrec.pf_key IN (
								'92000010',
								'92000020'
							) OR biloccurrec.pf_key LIKE 'NUT%')) THEN
								v_self_price     := v_price * v_salf_per;
								v_nh_price       := 0;
								v_other_price    := v_price - v_self_price;
								v_other_fincal   := v_fincal;
              --ELSE 
                 --V_OTHER_PRICE := 0 ;
                 --V_SELF_PRICE  := V_SELF_PRICE ;
                 --DBMS_OUTPUT.PUT_LINE('92000010 + EMPL');
							END IF;
						END IF;
						CLOSE cur_discount_notlabi;
					END IF;
					CLOSE cur_pfclass_fincal_vtan;
				END IF;
        --是否為自費項】
			END IF;

      --【費用類別:07手術單價計算
      --                     第一刀     第二刀     第三刀
      --同一刀口,多項          100        50        x
      --不同刀口,同類          100        50       20
      --不同刀口,不同類        100       100       33
      --同一刀口,多項
      --健保身份才要依循
			IF biloccurrec.fee_kind = '07' THEN
        --手術費
				IF f_getnhrangeflag (pcaseno => pcaseno, pdate => biloccurrec.bil_date, pfinflag => '1') IN (
					'LABI',
					'CIVC'
				) THEN
					IF biloccurrec.complication = 'Y' THEN
            --併發症,只看第一刀
						IF biloccurrec.or_order_item_no = '1' THEN
							bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0.5;
						ELSE
							bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0;
						END IF;
					ELSE
            --非併發症
						IF biloccurrec.or_order_catalog = '1' THEN
							IF biloccurrec.or_order_item_no = '1' THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 1;
							ELSE
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0;
							END IF;
						ELSIF biloccurrec.or_order_catalog = '2' THEN
            --IF bilOccurRec.Or_Order_Catalog = '2' THEN
							IF biloccurrec.or_order_item_no = '1' THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 1;
							ELSIF biloccurrec.or_order_item_no = '2' THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0.5;
							ELSE
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0;
							END IF;
              --不同刀口,同類
						ELSIF biloccurrec.or_order_catalog = '3' THEN
							IF biloccurrec.or_order_item_no = '1' THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 1;
							ELSIF biloccurrec.or_order_item_no = '2' THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0.5;
							ELSE
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0.2;
							END IF;
              --不同刀口,不同類
						ELSIF biloccurrec.or_order_catalog = '4' THEN
							IF biloccurrec.or_order_item_no = '1' THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 1;
							ELSIF biloccurrec.or_order_item_no = '2' THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 1;
							ELSE
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 1 / 3;
							END IF;
						ELSIF biloccurrec.or_order_catalog = '7' THEN  --7_多項同類或兩側性手術(1+0.5+0.5+0) 20171018 by kuo
							IF biloccurrec.or_order_item_no = '1' THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 1;
							ELSIF biloccurrec.or_order_item_no IN (
								'2',
								'3'
							) THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0.5;
							ELSE
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0;
							END IF;
						ELSIF biloccurrec.or_order_catalog = '8' THEN  --8_多項不同類手術(1+1+0.5+0) 20171018 by kuo
							IF biloccurrec.or_order_item_no IN (
								'1',
								'2'
							) THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 1;
							ELSIF biloccurrec.or_order_item_no = '3' THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0.5;
							ELSE
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 0;
							END IF;
						ELSIF biloccurrec.or_order_catalog = '9' THEN  --9_多重創傷(ISS>=16)並施行多項胸腹手術(1+1+1+1) 20171018 by kuo
							IF biloccurrec.or_order_item_no IN (
								'1',
								'2',
								'3',
								'4'
							) THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per * 1;
							END IF;
						END IF;
					END IF;
				END IF;
        --IF bilOccurRec.PF_KEY='80009722' THEN
        --   dbms_output.put_line('0.80009722:'||BILACNTWKREC.EMG_PER);
        --END IF;
			END IF;
      --費用類別:07手術單價計算】

      --【手術套餐不計價980303 BY KUO
			IF biloccurrec.id = '1' THEN
				v_keep_amount_flag          := 'Y';
				biloccurrec.charge_amount   := 0;
			END IF;

      --手術套餐不計價】
			IF v_nh_price > 0 THEN
        --健保金額大於0
				v_keep_amount_flag := 'N';
			END IF;

      --以billtemp金額為主不重取dbpfile金額
			IF v_keep_amount_flag = 'Y' AND v_self_price <> 0 AND v_other_price = 0 THEN
				v_self_price   := biloccurrec.charge_amount / biloccurrec.qty;
				v_self_amt     := biloccurrec.charge_amount;

        --因為回歸原價,所以要把手材費用歸回手術費中
				IF bilacntwkrec.fee_kind = '11' THEN
					bilacntwkrec.fee_kind   := '07';
					v_fee_kind              := '07';
					v_self_price            := 0;
					v_self_amt              := 0;
				END IF;
			ELSE
				IF bilacntwkrec.fee_kind = '11' THEN
					v_fee_kind      := '07';
					v_other_price   := 0;
					v_self_amt      := 0;
				END IF;
        --IF V_FEE_KIND = '12' THEN
        --  bilOccurRec.Qty := 1;
        --END IF;
			END IF;

      --【處理新生兒費用轉到NHI
			IF f_checkbabyflag (pcaseno => pcaseno, pdate => biloccurrec.bil_date) = 'Y' AND f_checkbabynh (ppfkey => biloccurrec.pf_key) =
			'Y' THEN
				IF v_self_price <> 0 THEN
					v_other_price    := v_self_price;
					v_other_fincal   := 'LABI';
					v_self_price     := 0;
				END IF;
				IF v_nh_price <> 0 THEN
					v_other_price    := v_nh_price;
					v_other_fincal   := 'LABI';
					v_nh_price       := 0;
				END IF;
			END IF;
      --處理新生兒費用轉到NHI】
			IF v_self_price > 0 THEN
        --找特殊收費檔PFCLASS(不含歷史檔)有無"非LABI資料"
				OPEN cur_pfclass_notlabi (biloccurrec.pf_key);
				FETCH cur_pfclass_notlabi INTO pfclassrec;
				IF cur_pfclass_notlabi%found THEN
					IF substr (pfclassrec.pfselpay, 6, 3) || substr (pfclassrec.pfreqpay, 1, 1) = 'LABI' THEN

            --找特殊收費檔PFCLASS+tmp_fincal(含歷史檔)有無"LABI資料"
						OPEN cur_pfclass_fincal_labi (biloccurrec.pf_key, biloccurrec.bil_date);
						FETCH cur_pfclass_fincal_labi INTO
							v_pf_self_pay,
							v_pf_nh_pay,
							v_pf_child_pay,
							v_faemep_flag,
							v_pfopfg_flag,
							v_pfspexam,
							vpfinseq;
						IF cur_pfclass_fincal_labi%notfound THEN
							v_pf_self_pay    := v_price;
							v_pf_nh_pay      := 0;
							v_pf_child_pay   := 0;
							IF bilacntwkrec.emg_flag = 'E' AND bilacntwkrec.emg_per = 1 THEN
								bilacntwkrec.emg_per := 1 + (v_pfemep / 100);
							END IF;
							v_faemep_flag    := 'N';
							v_pfopfg_flag    := 'N';
							v_pfspexam       := 'N';
						END IF;
						CLOSE cur_pfclass_fincal_labi;
						v_self_price   := v_pf_self_pay;
						v_nh_price     := v_pf_nh_pay;
					END IF;
				END IF;
				CLOSE cur_pfclass_notlabi;

        --Add new for 計價碼特約設定 by kuo 20151103
				OPEN cur_pfclass_contr (biloccurrec.pf_key, biloccurrec.bil_date);
				FETCH cur_pfclass_contr INTO pfclassrec;
				IF cur_pfclass_contr%found THEN
					v_self_price     := to_number (pfclassrec.pfselpay) / 100;
					v_other_price    := to_number (pfclassrec.pfreqpay) / 100;
					v_other_fincal   := pfclassrec.pfincode;
				END IF;
				CLOSE cur_pfclass_contr;
        --Add new for 計價碼特約設定 by kuo 20151103		 
			END IF;
			v_self_amt                  := v_self_price * biloccurrec.qty * bilacntwkrec.emg_per;
			v_nh_amt                    := v_nh_price * biloccurrec.qty * bilacntwkrec.emg_per * v_lab_disc_pert;
			v_other_amt                 := v_other_price * biloccurrec.qty * bilacntwkrec.emg_per;
			IF biloccurrec.credit_debit = '-' THEN
				v_self_amt      := v_self_amt * -1;
				v_nh_amt        := v_nh_amt * -1;
				v_other_amt     := v_other_amt * -1;
				v_nh_price      := v_nh_price * -1;
				v_self_price    := v_self_price * -1;
				v_other_price   := v_other_price * -1;
			END IF;
			bilacntwkrec.caseno         := pcaseno;
			v_acnt_seq                  := v_acnt_seq + 1;
			bilacntwkrec.acnt_seq       := v_acnt_seq;
			bilacntwkrec.acnt_seq       := biloccurrec.acnt_seq;
			bilacntwkrec.seq_no         := biloccurrec.acnt_seq;
			bilacntwkrec.price_code     := biloccurrec.pf_key;
			bilacntwkrec.fee_kind       := v_fee_kind;
			bilacntwkrec.qty            := biloccurrec.qty;
			bilacntwkrec.tqty           := biloccurrec.qty;
			bilacntwkrec.emg_flag       := biloccurrec.emergency;
			bilacntwkrec.emg_per        := bilacntwkrec.emg_per;
			bilacntwkrec.insu_amt       := v_nh_price;
			bilacntwkrec.self_amt       := v_self_price;
			bilacntwkrec.part_amt       := v_other_price;
			bilacntwkrec.self_flag      := biloccurrec.elf_flag;
			bilacntwkrec.bed_no         := biloccurrec.bed_no;
			bilacntwkrec.start_date     := biloccurrec.bil_date;
			bilacntwkrec.end_date       := biloccurrec.bil_date;
			bilacntwkrec.nh_type        := v_fee_type;
			bilacntwkrec.cost_code      := biloccurrec.income_dept;
			bilacntwkrec.keyin_date     := biloccurrec.create_dt;
			bilacntwkrec.ward           := biloccurrec.ward;
			bilacntwkrec.clerk          := biloccurrec.operator_name;
			bilacntwkrec.old_acnt_seq   := biloccurrec.acnt_seq;
			bilacntwkrec.bildate        := biloccurrec.bil_date;
			bilacntwkrec.stock_code     := biloccurrec.distribution_rule;
			bilacntwkrec.dept_code      := biloccurrec.patient_section;

      --94005060 always using contract 1155 by kuo 20161024 without entrying contract
			IF bilacntwkrec.price_code = '94005060' THEN
				bilacntwkrec.self_amt   := 0;
				v_other_amt             := v_self_amt;
				v_other_price           := v_self_price;
         --BILACNTWKREC.PART_AMT     := V_OTHER_PRICE;         
         --依郭組長指示將價錢調成廠商的價錢,不論歷史 by kuo 20161125
				IF biloccurrec.credit_debit = '-' THEN
					bilacntwkrec.qty := -1 * bilacntwkrec.qty;
				END IF;
				bilacntwkrec.tqty       := bilacntwkrec.qty;
				bilacntwkrec.part_amt   := 4000;
				v_other_price           := bilacntwkrec.part_amt;
				v_other_amt             := bilacntwkrec.qty * bilacntwkrec.part_amt;
				v_self_price            := 0;
				v_self_amt              := 0;
				v_other_fincal          := '1155';
         --DBMS_OUTPUT.PUT_LINE(v_self_price);
			END IF;
			BEGIN
				SELECT
					bil_date.days
				INTO v_days
				FROM
					bil_date
				WHERE
					bil_date.caseno = pcaseno
					AND
					bil_date.bil_date = biloccurrec.bil_date;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
          --v_days:=1;
			END;
			IF v_days <= 30 THEN
				v_e_level := '1';
			ELSIF v_days <= 60 THEN
				v_e_level := '2';
			ELSE
				v_e_level := '3';
			END IF;
			bilacntwkrec.e_level        := v_e_level;
			IF v_nh_amt <> 0 THEN
        --【費用類別:06藥費單價計算
				IF biloccurrec.fee_kind = '06' THEN
					v_acnt_seq                  := v_acnt_seq + 1;
					bilacntwkrec.acnt_seq       := v_acnt_seq;
					bilacntwkrec.ins_fee_code   := v_ins_fee_code;
					bilacntwkrec.self_amt       := 0;
					bilacntwkrec.part_amt       := 0;
					bilacntwkrec.pfincode       := 'LABI';
					bilacntwkrec.bildate        := biloccurrec.bil_date;
          --BILACNTWKREC.ORDER_SEQ := BILOCCURREC.ORDER_SEQNO;
					IF biloccurrec.credit_debit = '-' THEN
						IF bilacntwkrec.insu_amt < 0 THEN
							bilacntwkrec.insu_amt := bilacntwkrec.insu_amt * -1;
						END IF;
						IF bilacntwkrec.qty > 0 THEN
							bilacntwkrec.qty    := bilacntwkrec.qty * -1;
							bilacntwkrec.tqty   := bilacntwkrec.qty;
						END IF;
					END IF;
					INSERT INTO bil_acnt_wk VALUES bilacntwkrec;
          --費用類別:06藥費單價計算】
				ELSE
          --【非藥費單價計算
          --BILACNTWKREC.ORDER_SEQ := BILOCCURREC.ORDER_SEQNO;
					v_nh_amt1   := 0;
					v_emg_per   := bilacntwkrec.emg_per;

          --找pflabi(含歷史檔)有無"LABI資料"
					OPEN cur_pflabi_labi (bilacntwkrec.price_code, vpfinseq);
					LOOP
						FETCH cur_pflabi_labi INTO
							v_ins_fee_code,
							v_labi_qty;
						EXIT WHEN cur_pflabi_labi%notfound;
						bilacntwkrec.emg_per        := v_emg_per;
						v_acnt_seq                  := v_acnt_seq + 1;
						bilacntwkrec.acnt_seq       := v_acnt_seq;
						IF v_labi_qty IS NULL THEN
							v_labi_qty := 1;
						END IF;
						bilacntwkrec.ins_fee_code   := rtrim (v_ins_fee_code);

            --add LABCHILD_INC 提升兒童加成急做 add by kuo 20140128
						BEGIN
							SELECT
								labprice,
								nhinpric,
								nhitype,
								labchild,
								labchild_inc
							INTO
								v_labprice,
								v_nhipric,
								v_fee_type,
								v_labchild,
								v_labchild_inc
							FROM
								vsnhi
							WHERE
								vsnhi.labkey = bilacntwkrec.ins_fee_code
								AND
								(labbdate <= biloccurrec.bil_date
								 OR
								 labbdate IS NULL)
								AND
								labedate >= biloccurrec.bil_date;
						EXCEPTION
							WHEN OTHERS THEN
								v_labprice     := v_nh_price;
								v_fee_type     := v_fee_kind;
								v_error_code   := sqlcode;
								v_error_info   := sqlerrm;
						END;
						IF v_labchild IS NULL THEN
							v_labchild := 'N';
						END IF;

            --如果pfclass 要兒童加成,vsnhi不需加成,要扣回來
            --這段在手術2刀0.5時會有問題...add new one by kuo 20160527
            --add by kuo 20160824,兒童加重加成會在 getEmgPer裡面(從20160901開始)
						IF biloccurrec.bil_date < TO_DATE ('20160901', 'YYYYMMDD') THEN
							IF biloccurrec.bil_date >= TO_DATE ('20160528', 'YYYYMMDD') THEN
								IF biloccurrec.emergency = 'E' THEN
									IF v_pf_child_pay > 0 AND v_labchild <> 'Y' THEN
										IF v_child_flag_3 = 'Y' THEN
											bilacntwkrec.emg_per := v_emg_per - 0.6;
										END IF;
										IF v_child_flag_2 = 'Y' THEN
											bilacntwkrec.emg_per := v_emg_per - 0.3;
										END IF;
										IF v_child_flag_1 = 'Y' THEN
											bilacntwkrec.emg_per := v_emg_per - 0.2;
										END IF;
									END IF;
								END IF;
							ELSE --old 
								IF v_pf_child_pay > 0 AND v_labchild <> 'Y' THEN
									IF v_child_flag_3 = 'Y' AND bilacntwkrec.emg_per >= 1.6 THEN
										bilacntwkrec.emg_per := v_emg_per - 0.6;
									END IF;
									IF v_child_flag_2 = 'Y' AND bilacntwkrec.emg_per >= 1.3 THEN
										bilacntwkrec.emg_per := v_emg_per - 0.3;
									END IF;
									IF v_child_flag_1 = 'Y' AND bilacntwkrec.emg_per >= 1.2 THEN
										bilacntwkrec.emg_per := v_emg_per - 0.2;
									END IF;
								END IF;
							END IF;
            /*mark for old by kuo 20160527
            IF V_PF_CHILD_PAY > 0 AND V_LABCHILD <> 'Y' THEN
              IF v_child_flag_3 = 'Y' AND bilAcntWkRec.emg_per >= 1.6 THEN
                BILACNTWKREC.EMG_PER := V_EMG_PER - 0.6;
              END IF;
              IF v_child_flag_2 = 'Y' AND bilAcntWkRec.emg_per >= 1.3 THEN
                BILACNTWKREC.EMG_PER := V_EMG_PER - 0.3;
              END IF;
              IF v_child_flag_1 = 'Y' AND bilAcntWkRec.emg_per >= 1.2 THEN
                bilAcntWkRec.emg_per := v_emg_per - 0.2;
              END IF;
              --IF BILACNTWKREC.PRICE_CODE='80009722' THEN
              --   dbms_output.put_line('1.80009722:'||BILACNTWKREC.EMG_PER);
              --END IF;
            END IF;
            */
            --add LABCHILD_INC 提升兒童加成急做 add by kuo 20140128
            --時間在VSNHI抓取時已經判斷了
            --因應兩個都有的問題只取大的 by kuo 20140221
            --因應目前沒有這樣問題就改回來 by kuo 20140729
							IF v_labchild_inc = 'Y' THEN
								IF v_child_flag_1 = 'Y' THEN
									bilacntwkrec.emg_per := bilacntwkrec.emg_per + 0.6;
                  --bilAcntWkRec.emg_per := 0.6;
								END IF;
								IF v_child_flag_2 = 'Y' THEN
									bilacntwkrec.emg_per := bilacntwkrec.emg_per + 0.8;
                  --BILACNTWKREC.EMG_PER := 0.8;
								END IF;
								IF v_child_flag_3 = 'Y' THEN
									bilacntwkrec.emg_per := bilacntwkrec.emg_per + 1;
                  --BILACNTWKREC.EMG_PER := 1;
								END IF;
               --IF BILACNTWKREC.PRICE_CODE='80009722' THEN
               --   DBMS_OUTPUT.PUT_LINE('2.80009722:'||BILACNTWKREC.EMG_PER);
               --END IF;
							END IF;
						END IF;

            --20130101起生效
            --02010B燒傷病房住院診察費兒童加成
            --加成分別為120%,90%,80%
            --Add by kuo 20140206
            --因為20130101已經過去，帳務改為20140101
						IF bilacntwkrec.ins_fee_code = '02010B' AND biloccurrec.bil_date >= TO_DATE ('20140101', 'YYYYMMDD') THEN
							IF v_child_flag_1 = 'Y' THEN
								bilacntwkrec.emg_per := 1.8;
							END IF;
							IF v_child_flag_2 = 'Y' THEN
								bilacntwkrec.emg_per := 1.9;
							END IF;
							IF v_child_flag_3 = 'Y' THEN
								bilacntwkrec.emg_per := 2.2;
							END IF;
						END IF;

            --20130101起生效,20170930結束 modified by kuo 20171003
            --兒科申報02005B,02006K,02007A,02008B,02011K,02012A,02013B,02014K,02015A,02016B加計60%
            --Add by kuo 20140206
            --因為20130101已經過去，帳務改為20140101
            --新增判斷方式，不以PED為主 by kuo 20140306
						IF bilacntwkrec.ins_fee_code IN (
							'02005B',
							'02006K',
							'02007A',
							'02008B',
							'02011K',
							'02012A',
							'02013B',
							'02014K',
							'02015A',
							'02016B'
						) AND 
               --BILROOTREC.HCURSVCL='PED' AND mark by kuo 20140306
						 biloccurrec.bil_date >= TO_DATE ('20140101', 'YYYYMMDD') AND biloccurrec.bil_date <= TO_DATE ('20170930', 'YYYYMMDD') THEN
							vcardno := '';
							OPEN ped_cardno (bilrootrec.hvmdno);
							FETCH ped_cardno INTO vcardno;
							CLOSE ped_cardno;
							IF vcardno IS NOT NULL THEN
								bilacntwkrec.emg_per := bilacntwkrec.emg_per + 0.6;
							END IF;
						END IF;
            --20171001起生效 add by kuo 20171003
            --1.加護病房診察費及住院會診費(02005B,02011K,02012A,02013B)
            --  兒科專科醫師 得外加計百分之一百二十(1.2)， 若同時符合兒童加成者，依加成率合計後一併加成，最高加成上限為百分之一百二十(1.2) 。
            --2.一般住院診察費及隔離病床住院診察費(02006K,02007A,02008B,02014K,02015A,02016B) 
            --  兒科專科醫師得加計百分之一百五十(1.5)， 若同時符合兒童加成者，依加成率合計後一併加成，最高加成上限為百分之一百五十(1.5)。
						IF bilacntwkrec.ins_fee_code IN (
							'02005B',
							'02011K',
							'02012A',
							'02013B'
						) AND biloccurrec.bil_date >= TO_DATE ('20171001', 'YYYYMMDD') THEN
							vcardno := '';
							OPEN ped_cardno (bilrootrec.hvmdno);
							FETCH ped_cardno INTO vcardno;
							CLOSE ped_cardno;
							IF vcardno IS NOT NULL THEN
								IF bilacntwkrec.emg_per + 1.2 < 2.2 THEN
									bilacntwkrec.emg_per := bilacntwkrec.emg_per + 1.2;
								ELSE
									bilacntwkrec.emg_per := 2.2; --bug fixed 20171011 by kuo
								END IF;
							END IF;
						END IF;
						IF bilacntwkrec.ins_fee_code IN (
							'02006K',
							'02007A',
							'02008B',
							'02014K',
							'02015A',
							'02016B'
						) AND biloccurrec.bil_date >= TO_DATE ('20171001', 'YYYYMMDD') THEN
							vcardno := '';
							OPEN ped_cardno (bilrootrec.hvmdno);
							FETCH ped_cardno INTO vcardno;
							CLOSE ped_cardno;
							IF vcardno IS NOT NULL THEN
								IF bilacntwkrec.emg_per + 1.5 < 2.5 THEN
									bilacntwkrec.emg_per := bilacntwkrec.emg_per + 1.5;
								ELSE
									bilacntwkrec.emg_per := 2.5; --bug fixed 20171011 by kuo
								END IF;
							END IF;
						END IF;
						bilacntwkrec.insu_amt       := v_labprice;
						bilacntwkrec.nh_type        := v_fee_type;
						bilacntwkrec.qty            := v_labi_qty * biloccurrec.qty;
						bilacntwkrec.tqty           := v_labi_qty * biloccurrec.qty;

            --計算衛材成數
            /*MARK BY KUO 1000707
            IF v_fee_type = '12' THEN
              IF v_nhipric < 30000 THEN
                IF v_labprice = v_nhipric THEN
                  bilAcntWkRec.Emg_Per := 1;
                ELSE
                  bilAcntWkRec.Emg_Per := 1.05;
                END IF;
              ELSE
                bilAcntWkRec.Emg_Per := 1;
              END IF;
              bilAcntWkRec.Insu_Amt := v_nhipric;
            END IF;
            */
						IF biloccurrec.credit_debit = '-' THEN
							bilacntwkrec.insu_amt := bilacntwkrec.insu_amt * -1;
						END IF;
						v_nh_amt1                   := v_nh_amt1 + (bilacntwkrec.insu_amt * bilacntwkrec.qty * bilacntwkrec.emg_per);
						bilacntwkrec.self_amt       := 0;
						bilacntwkrec.part_amt       := 0;
						bilacntwkrec.pfincode       := 'LABI';
						bilacntwkrec.bildate        := biloccurrec.bil_date;
						IF biloccurrec.credit_debit = '-' THEN
							IF bilacntwkrec.insu_amt < 0 THEN
								bilacntwkrec.insu_amt := bilacntwkrec.insu_amt * -1;
							END IF;
							IF bilacntwkrec.qty > 0 THEN
								bilacntwkrec.qty    := bilacntwkrec.qty * -1;
								bilacntwkrec.tqty   := bilacntwkrec.qty;
							END IF;
						END IF;
						BEGIN
							INSERT INTO bil_acnt_wk VALUES bilacntwkrec;
						EXCEPTION
							WHEN OTHERS THEN
								v_acnt_seq              := v_acnt_seq + 1;
								bilacntwkrec.acnt_seq   := v_acnt_seq;
								bilacntwkrec.pfincode   := 'LABI';
								bilacntwkrec.self_amt   := 0;
								bilacntwkrec.part_amt   := 0;
								INSERT INTO bil_acnt_wk VALUES bilacntwkrec;
						END;
					END LOOP;
					CLOSE cur_pflabi_labi;
					IF v_nh_amt <> v_nh_amt1 AND v_nh_amt1 <> 0 THEN
						v_nh_amt := v_nh_amt1;
					END IF;

          --FOR 健保福
          --因為沒有健保碼又要算健保價,只好硬塞進去....@_@
					IF v_nh_diet_flag = 'Y' AND v_ins_fee_code IS NULL THEN
						v_acnt_seq                  := v_acnt_seq + 1;
						bilacntwkrec.acnt_seq       := v_acnt_seq;
						bilacntwkrec.ins_fee_code   := '';
						bilacntwkrec.self_amt       := 0;
						bilacntwkrec.part_amt       := 0;
						bilacntwkrec.pfincode       := 'LABI';
						bilacntwkrec.bildate        := biloccurrec.bil_date;
						INSERT INTO bil_acnt_wk VALUES bilacntwkrec;
					END IF;
          --非藥費單價計算】
				END IF;
			END IF;
			IF v_nh_amt <> 0 THEN
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					bil_feedtl
				WHERE
					bil_feedtl.caseno = pcaseno
					AND
					bil_feedtl.fee_type = v_fee_kind
					AND
					bil_feedtl.pfincode = 'LABI';
				IF v_cnt = 0 THEN
					bilfeedtlrec.caseno             := pcaseno;
					bilfeedtlrec.fee_type           := v_fee_kind;
					bilfeedtlrec.pfincode           := 'LABI';
					bilfeedtlrec.total_amt          := v_nh_amt;
					bilfeedtlrec.created_by         := 'biling';
					bilfeedtlrec.creation_date      := SYSDATE;
					bilfeedtlrec.last_updated_by    := 'biling';
					bilfeedtlrec.last_update_date   := SYSDATE;
					INSERT INTO bil_feedtl VALUES bilfeedtlrec;
				ELSE
					UPDATE bil_feedtl
					SET
						total_amt = total_amt + v_nh_amt
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = v_fee_kind
						AND
						bil_feedtl.pfincode = 'LABI';
				END IF;
			END IF;
			IF v_self_amt <> 0 THEN
				v_fincode                   := 'CIVC';
        --檢查*單人房病房費優減 KUO 970430
				IF biloccurrec.fee_kind = '01' AND substr (biloccurrec.pf_key, 1, 5) = 'WARD1' THEN
					IF v_other_fincal = 'VTAM' THEN
            --有職中將+上將
						v_fincode := 'VTAM';
					ELSIF v_other_fincal = 'VTAN' THEN
            --無職中將+上將
						SELECT
							COUNT (*)
						INTO v_cnt
						FROM
							common.pat_adm_vtan_rec
						WHERE
							common.pat_adm_vtan_rec.hcaseno = biloccurrec.caseno
							AND
							hvtrnkcd IN (
								'01',
								'02'
							);
						IF v_cnt > 0 AND TO_CHAR (bilrootrec.dischg_date, 'YYYYMMDD') < '20100510' THEN
              --modify by tenya 99/09/27計價組要求(有公文)
							v_fincode := 'VERT'; --轉輔導會
						END IF;
					END IF;
				END IF;
				IF v_fincode IS NULL THEN
					dbms_output.put_line (bilacntwkrec.price_code);
				END IF;
				bilacntwkrec.ins_fee_code   := bilacntwkrec.price_code;
				bilacntwkrec.self_flag      := 'Y';
				v_acnt_seq                  := v_acnt_seq + 1;
				bilacntwkrec.acnt_seq       := v_acnt_seq;
				bilacntwkrec.insu_amt       := 0;
				bilacntwkrec.part_amt       := 0;
				bilacntwkrec.self_amt       := v_self_price;
				bilacntwkrec.pfincode       := v_fincode;
				bilacntwkrec.bildate        := biloccurrec.bil_date;

        --CIVC與LABI調成一致
				IF biloccurrec.credit_debit = '-' THEN
					IF bilacntwkrec.self_amt < 0 THEN
						bilacntwkrec.self_amt := bilacntwkrec.self_amt * -1;
					END IF;
					IF bilacntwkrec.qty > 0 THEN
						bilacntwkrec.qty    := bilacntwkrec.qty * -1;
						bilacntwkrec.tqty   := bilacntwkrec.qty;
					END IF;
				END IF;
				IF v_fincode = 'VERT' THEN
					bilacntwkrec.part_amt   := v_self_price;
					bilacntwkrec.self_amt   := 0;
				END IF;
				INSERT INTO bil_acnt_wk VALUES bilacntwkrec;
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					bil_feedtl
				WHERE
					bil_feedtl.caseno = pcaseno
					AND
					bil_feedtl.fee_type = v_fee_kind
					AND
					bil_feedtl.pfincode = v_fincode; --ADD BY KUO 970430
				IF v_cnt = 0 THEN
					bilfeedtlrec.caseno             := pcaseno;
					bilfeedtlrec.fee_type           := v_fee_kind;
					bilfeedtlrec.pfincode           := v_fincode;
					bilfeedtlrec.total_amt          := v_self_amt;
					bilfeedtlrec.created_by         := 'biling';
					bilfeedtlrec.creation_date      := SYSDATE;
					bilfeedtlrec.last_updated_by    := 'biling';
					bilfeedtlrec.last_update_date   := SYSDATE;
					INSERT INTO bil_feedtl VALUES bilfeedtlrec;
				ELSE
					UPDATE bil_feedtl
					SET
						total_amt = total_amt + v_self_amt
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = v_fee_kind
						AND
						bil_feedtl.pfincode = v_fincode; --ADD BY KUO 970430
				END IF;

        --將官病房費優減 by Kuo 970430
				IF biloccurrec.fee_kind = '01' AND substr (biloccurrec.pf_key, 1, 5) = 'WARD1' AND v_fincode <> 'CIVC' THEN

          --IF v_other_fincal = 'VTAM'
          --   AND bilOccurRec.Fee_Kind = '01'
          --   AND SubStr(bilOccurRec.PF_KEY,1,5)='WARD1' THEN
					UPDATE bil_feemst
					SET
						bil_feemst.credit_amt = bil_feemst.credit_amt + v_self_amt,
						bil_feemst.tot_gl_amt = bil_feemst.tot_gl_amt - v_self_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				END IF;
			END IF;
			IF v_other_amt <> 0 THEN
				bilacntwkrec.ins_fee_code   := bilacntwkrec.price_code;
				bilacntwkrec.self_flag      := 'Y';
				v_acnt_seq                  := v_acnt_seq + 1;
				bilacntwkrec.acnt_seq       := v_acnt_seq;
				bilacntwkrec.insu_amt       := 0;
				bilacntwkrec.self_amt       := 0;
				bilacntwkrec.part_amt       := v_other_price;
				bilacntwkrec.pfincode       := v_other_fincal;
				bilacntwkrec.bildate        := biloccurrec.bil_date;

        --病房費優減
				IF biloccurrec.fee_kind = '01' THEN
					IF v_other_fincal = 'VTAN' THEN
						bilacntwkrec.part_amt := v_other_price / 2;
					END IF;
				END IF;
				INSERT INTO bil_acnt_wk VALUES bilacntwkrec;

        --病房費優減
				IF biloccurrec.fee_kind = '01' THEN
					IF v_other_fincal = 'VTAN' THEN
						v_acnt_seq              := v_acnt_seq + 1;
						bilacntwkrec.acnt_seq   := v_acnt_seq;
						bilacntwkrec.pfincode   := 'VERT';
						INSERT INTO bil_acnt_wk VALUES bilacntwkrec;
						v_other_amt             := v_other_amt / 2;
						SELECT
							COUNT (*)
						INTO v_cnt
						FROM
							bil_feedtl
						WHERE
							bil_feedtl.caseno = pcaseno
							AND
							bil_feedtl.fee_type = v_fee_kind
							AND
							bil_feedtl.pfincode = 'VERT';
						IF v_cnt = 0 THEN
							bilfeedtlrec.caseno             := pcaseno;
							bilfeedtlrec.fee_type           := v_fee_kind;
							bilfeedtlrec.pfincode           := 'VERT';
							bilfeedtlrec.total_amt          := v_other_amt;
							bilfeedtlrec.created_by         := 'biling';
							bilfeedtlrec.creation_date      := SYSDATE;
							bilfeedtlrec.last_updated_by    := 'biling';
							bilfeedtlrec.last_update_date   := SYSDATE;
							INSERT INTO bil_feedtl VALUES bilfeedtlrec;
						ELSE
							UPDATE bil_feedtl
							SET
								total_amt = total_amt + v_other_amt
							WHERE
								bil_feedtl.caseno = pcaseno
								AND
								bil_feedtl.fee_type = v_fee_kind
								AND
								bil_feedtl.pfincode = 'VERT';
						END IF;
					END IF;
				END IF;
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					bil_feedtl
				WHERE
					bil_feedtl.caseno = pcaseno
					AND
					bil_feedtl.fee_type = v_fee_kind
					AND
					bil_feedtl.pfincode = v_other_fincal;
				IF v_cnt = 0 THEN
					bilfeedtlrec.caseno             := pcaseno;
					bilfeedtlrec.fee_type           := v_fee_kind;
					bilfeedtlrec.pfincode           := v_other_fincal;
					bilfeedtlrec.total_amt          := v_other_amt;
					bilfeedtlrec.created_by         := 'biling';
					bilfeedtlrec.creation_date      := SYSDATE;
					bilfeedtlrec.last_updated_by    := 'biling';
					bilfeedtlrec.last_update_date   := SYSDATE;
					INSERT INTO bil_feedtl VALUES bilfeedtlrec;
				ELSE
					UPDATE bil_feedtl
					SET
						total_amt = total_amt + v_other_amt
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = v_fee_kind
						AND
						bil_feedtl.pfincode = v_other_fincal;
				END IF;
			END IF;
			BEGIN
				SELECT
					bil_date.days
				INTO v_days
				FROM
					bil_date
				WHERE
					bil_date.caseno = pcaseno
					AND
					bil_date.bil_date = biloccurrec.bil_date;
			EXCEPTION
				WHEN OTHERS THEN
					v_days := 0;
			END;
			IF v_nh_amt IS NULL THEN
				v_nh_amt := 0;
			END IF;
			IF v_self_amt IS NULL THEN
				v_self_amt := 0;
			END IF;

      --油症判斷，免部份負擔 BY KUO 1010111
			prj901                      := 0;
			SELECT
				COUNT (*)
			INTO prj901
			FROM
				common.pat_adm_case
			WHERE
				hcaseno = pcaseno
				AND
				projectcode = '901';
			IF v_e_level = '1' THEN
				bilfeemstrec.emg_exp_amt1 := bilfeemstrec.emg_exp_amt1 + v_nh_amt;
        --Add 74701580 不算部份負擔 by kuo 20190430
				IF f_getnhrangeflag (pcaseno, biloccurrec.bil_date, '2') = 'NHI0' AND bilacntwkrec.price_code <> '74701580' THEN
					UPDATE bil_feemst
					SET
						bil_feemst.emg_exp_amt1 = bil_feemst.emg_exp_amt1 + v_nh_amt,
						bil_feemst.emg_pay_amt1 = bil_feemst.emg_pay_amt1 + v_nh_amt,
						bil_feemst.tot_gl_amt = bil_feemst.tot_gl_amt + v_self_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				ELSE
					UPDATE bil_feemst
					SET
						bil_feemst.emg_exp_amt1 = bil_feemst.emg_exp_amt1 + v_nh_amt,
						bil_feemst.tot_gl_amt = bil_feemst.tot_gl_amt + v_self_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				END IF;
			ELSIF v_e_level = '2' THEN
        --Add 74701580 不算部份負擔 by kuo 20190430
				IF f_getnhrangeflag (pcaseno, biloccurrec.bil_date, '2') = 'NHI0' AND bilacntwkrec.price_code <> '74701580' THEN
					UPDATE bil_feemst
					SET
						bil_feemst.emg_exp_amt2 = bil_feemst.emg_exp_amt2 + v_nh_amt,
						bil_feemst.emg_pay_amt2 = bil_feemst.emg_pay_amt2 + v_nh_amt,
						bil_feemst.tot_gl_amt = bil_feemst.tot_gl_amt + v_self_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				ELSE
					UPDATE bil_feemst
					SET
						bil_feemst.emg_exp_amt2 = bil_feemst.emg_exp_amt2 + v_nh_amt,
						bil_feemst.tot_gl_amt = bil_feemst.tot_gl_amt + v_self_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				END IF;
			ELSE
        --Add 74701580 不算部份負擔 by kuo 20190430
				IF f_getnhrangeflag (pcaseno, biloccurrec.bil_date, '2') = 'NHI0' AND bilacntwkrec.price_code <> '74701580' THEN
					UPDATE bil_feemst
					SET
						bil_feemst.emg_exp_amt3 = bil_feemst.emg_exp_amt3 + v_nh_amt,
						bil_feemst.emg_pay_amt3 = bil_feemst.emg_pay_amt3 + v_nh_amt,
						bil_feemst.tot_gl_amt = bil_feemst.tot_gl_amt + v_self_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				ELSE
					UPDATE bil_feemst
					SET
						bil_feemst.emg_exp_amt3 = bil_feemst.emg_exp_amt3 + v_nh_amt,
						bil_feemst.tot_gl_amt = bil_feemst.tot_gl_amt + v_self_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				END IF;
			END IF;
		END LOOP;
		CLOSE cur_occur;

    --最後將各項費用之費用總額以四捨五入作調整，以避免與帳單產生差異
		UPDATE bil_feedtl
		SET
			total_amt = round (total_amt, 0)
		WHERE
			bil_feedtl.caseno = pcaseno;
		IF bilrootrec.bl14c1 IS NULL THEN
			bilrootrec.bl14c1 := 0;
		ELSE 
		/** 
		 * 14 天再入院 case，重新計算前次住院第一階段部分負擔（費用類別：41）加總（所有分攤單位總和）
		 * 
		 * @author 陳如軒
		 * @date   2018-05-30
		 */
			FOR rec_encntidx IN (
				SELECT
					*
				FROM
					opdusr.encntidx
				WHERE
					hhisnum = bilrootrec.hpatnum
					AND
					encnttype = 'A'
					AND
					trunc (bilrootrec.admit_date) - TO_DATE (substr (dischargedatetime, 1, 8), 'YYYYMMDD') <= 14
				ORDER BY
					bilrootrec.admit_date DESC
			) LOOP
				SELECT
					SUM (total_amt)
				INTO
					bilrootrec
				.bl14c1
				FROM
					bil_feedtl
				WHERE
					caseno = rec_encntidx.hcaseno
					AND
					fee_type = '41';
				EXIT;
			END LOOP;
		END IF;
		p_transnhrule (pcaseno => pcaseno);
		SELECT
			*
		INTO bilfeemstrec
		FROM
			bil_feemst
		WHERE
			bil_feemst.caseno = pcaseno;

    --油症部份負擔費用歸0 BY KUO 1010111
		IF prj901 = 1 THEN
			bilfeemstrec.emg_pay_amt1   := 0;
			bilfeemstrec.emg_pay_amt2   := 0;
			bilfeemstrec.emg_pay_amt3   := 0;
			UPDATE bil_feemst
			SET
				bil_feemst.emg_pay_amt1 = 0,
				bil_feemst.emg_pay_amt2 = 0,
				bil_feemst.emg_pay_amt3 = 0
			WHERE
				bil_feemst.caseno = pcaseno;
		ELSE
			bilfeemstrec.emg_pay_amt1   := round (bilfeemstrec.emg_pay_amt1 * 0.1, 0);
			bilfeemstrec.emg_pay_amt2   := round (bilfeemstrec.emg_pay_amt2 * 0.2, 0);
			bilfeemstrec.emg_pay_amt3   := round (bilfeemstrec.emg_pay_amt3 * 0.3, 0);
		END IF;
    --bilFeeMstRec.Emg_Pay_Amt1 := ROUND(bilFeeMstRec.Emg_Pay_Amt1 * 0.1, 0);
    --bilFeeMstRec.Emg_Pay_Amt2 := ROUND(bilFeeMstRec.Emg_Pay_Amt2 * 0.2, 0);
    --bilFeeMstRec.Emg_Pay_Amt3 := ROUND(bilFeeMstRec.Emg_Pay_Amt3 * 0.3, 0);

    /*TEST     
         IF PCASENO='01985365' THEN
            INSERT INTO BIL_PROCEDULE_TEMP (CASENO,RECORD_DATE,STATUS,MESSAGE,PRO_NAME,SESSION_ID)
           VALUES(pCaseNo,SYSDATE,'',
            '1D=>'||bilFeeMstRec.Emg_Pay_Amt1||
            '2D=>'||bilFeeMstRec.Emg_Pay_Amt2||
            '3D=>'||bilFeeMstRec.Emg_Pay_Amt2||
            '4D=>'||v_fincal||'5D=>'||bilRootRec.Hfinacl2||'6D=>'||bilRootRec.Dischg_Date,'main_process',NULL);
         END IF;      
    */
		IF bilfeemstrec.emg_pay_amt1 + bilfeemstrec.emg_pay_amt2 + bilfeemstrec.emg_pay_amt3 > 0 THEN
      --【健保30天部份負擔上限
      --2015/01/01(含)以後住院者，健保30天部份負擔上限33000 -- add by kuo 20150128
      --2014/01/01(含)以後住院者，健保30天部份負擔上限32000 -- add by kuo 20140410
      --2014/01/01(含)以後出院者，健保30天部份負擔上限32000 --廢除 by kuo 20140410
      --2012/02/08(含)以後住院者，健保30天部份負擔上限31000
      --2011/01/01(含)以後出院者，健保30天部份負擔上限28000
      --2010/01/01(含)~2010/12/31出院者，健保30天部份負擔上限29000
      --2009/01/01(含)~2009/12/31出院者，健保30天部份負擔上限30000
      --2008/01/01(含)~2008/12/31出院者，健保30天部份負擔上限28000
      --2008/01/01以前出院者，健保30天部份負擔上限26000
      --IF BILROOTREC.DISCHG_DATE IS NULL OR
      --   BILROOTREC.DISCHG_DATE >= TO_DATE('2014/01/01', 'yyyy/mm/dd') THEN
      --   V_LIMIT_AMT := 32000;
      --ELSIF BILROOTREC.DISCHG_DATE >= TO_DATE('2011/01/01', 'yyyy/mm/dd') THEN   
			IF bilrootrec.dischg_date IS NULL OR bilrootrec.dischg_date >= TO_DATE ('2011/01/01', 'yyyy/mm/dd') THEN
         --由於是對住院日判斷，所以寫在這裡 by kuo 1010209
				IF bilrootrec.admit_date >= TO_DATE ('2012/02/08', 'yyyy/mm/dd') THEN
            --201401/01(含)以後住院者，健保30天部份負擔上限32000 -- add by kuo 20140410
					IF bilrootrec.admit_date >= TO_DATE ('2014/01/01', 'yyyy/mm/dd') THEN
						IF bilrootrec.admit_date >= TO_DATE ('2015/01/01', 'yyyy/mm/dd') THEN
                  --201601/01(含)以後住院者，健保30天部份負擔上限36000 -- add by kuo 20160122
							IF bilrootrec.admit_date >= TO_DATE ('2016/01/01', 'yyyy/mm/dd') THEN
                     --201701/01(含)以後住院者，健保30天部份負擔上限37000 -- add by kuo 20170113
								IF bilrootrec.admit_date >= TO_DATE ('2017/01/01', 'yyyy/mm/dd') THEN
                        --V_LIMIT_AMT := 37000;
                        ----201801/01(含)以後住院者，健保30天部份負擔上限38000 -- add by kuo 20171229
									IF bilrootrec.admit_date >= TO_DATE ('2018/01/01', 'yyyy/mm/dd') THEN
                           ----201901/01(含)以後住院者，健保30天部份負擔上限39000 -- add by kuo 20190108
										IF bilrootrec.admit_date >= TO_DATE ('2019/01/01', 'yyyy/mm/dd') THEN
											v_limit_amt := 39000;
										ELSE
											v_limit_amt := 38000;
										END IF;
									ELSE
										v_limit_amt := 37000;
									END IF;
								ELSE
									v_limit_amt := 36000;
								END IF;
							ELSE
								v_limit_amt := 33000;
							END IF;
						ELSE
							v_limit_amt := 32000;
						END IF;
					ELSE
						v_limit_amt := 31000;
					END IF;
				ELSE
					v_limit_amt := 28000;
				END IF;
			ELSIF bilrootrec.dischg_date >= TO_DATE ('2010/01/01', 'yyyy/mm/dd') AND bilrootrec.dischg_date <= TO_DATE ('2010/12/31', 'yyyy/mm/dd'
			) THEN
				v_limit_amt := 29000;
			ELSIF bilrootrec.dischg_date >= TO_DATE ('2009/01/01', 'yyyy/mm/dd') AND bilrootrec.dischg_date <= TO_DATE ('2009/12/31', 'yyyy/mm/dd'
			) THEN
				v_limit_amt := 30000;
			ELSIF bilrootrec.dischg_date < TO_DATE ('2008/01/01', 'yyyy/mm/dd') THEN
				v_limit_amt := 26000;
			ELSE
				v_limit_amt := 28000;
			END IF;
      --ADD BY KUO 1000811 START FOR 14天在入院30日部份負擔超過極限修改 START
      --健保30天部份負擔上限】
			IF bilfeemstrec.emg_pay_amt1 > v_limit_amt THEN
				bilfeemstrec.emg_pay_amt1 := v_limit_amt;
			END IF;
			IF bilfeemstrec.emg_pay_amt1 > 0 THEN
				IF v0921 > 0 THEN
          --0921免部份負擔30日 By Kuo 980814
					bilfeemstrec.emg_pay_amt1 := 0;
				ELSE
          --14天再入院，要減掉上次的部份負擔
					IF (bilrootrec.admit_again_flag = 'Y') THEN --是否有14天再入院
             --兩次部份30日內負擔加起來超過極限
						IF (bilfeemstrec.emg_pay_amt1 + bilrootrec.bl14c1 >= v_limit_amt) THEN
                --上次未超過極限
							IF bilrootrec.bl14c1 < v_limit_amt THEN
								bilfeemstrec.emg_pay_amt1 := v_limit_amt - bilrootrec.bl14c1;
							ELSE --上次已經超過極限，本次就為 0
								bilfeemstrec.emg_pay_amt1 := 0;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
      --ADD BY KUO 1000811 START FOR 14天在入院30日部份負擔超過極限修改 END
      /* MARK BY KUO 1000811 FOR NOT VERY CORRECT
      IF bilFeeMstRec.Emg_Pay_Amt1 > 0 THEN
        IF v0921 > 0 THEN
          --0921免部份負擔30日 By Kuo 980814
          bilFeeMstRec.Emg_Pay_Amt1 := 0;
        ELSE
          --設定部份負擔30日內上限金額
          IF bilFeeMstRec.Emg_Pay_Amt1 >= v_limit_amt THEN
            bilFeeMstRec.Emg_Pay_Amt1 := v_limit_amt;
          ELSE
            IF (bilRootRec.Admit_Again_Flag = 'Y') AND --是否有14天再入院
               (bilFeeMstRec.Emg_Pay_Amt1 + bilRootRec.Bl14c1 >=
               v_limit_amt) THEN
              IF BilRootRec.Bl14c1 < v_limit_amt THEN
                bilFeeMstRec.Emg_Pay_Amt1 := v_limit_amt -
                                             BilRootRec.Bl14c1;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
      */
			UPDATE bil_feemst
			SET
				bil_feemst.emg_pay_amt1 = bilfeemstrec.emg_pay_amt1,
				bil_feemst.emg_pay_amt2 = bilfeemstrec.emg_pay_amt2,
				bil_feemst.emg_pay_amt3 = bilfeemstrec.emg_pay_amt3,
				bil_feemst.tot_self_amt = bilfeemstrec.emg_pay_amt1 + bilfeemstrec.emg_pay_amt2 + bilfeemstrec.emg_pay_amt3
			WHERE
				bil_feemst.caseno = pcaseno;

      --部分負擔30日內
			IF bilfeemstrec.emg_pay_amt1 > 0 THEN
				bilfeedtlrec.caseno             := pcaseno;
				bilfeedtlrec.fee_type           := '41';
				bilfeedtlrec.pfincode           := 'CIVC';
				bilfeedtlrec.total_amt          := bilfeemstrec.emg_pay_amt1;
				bilfeedtlrec.created_by         := 'biling';
				bilfeedtlrec.creation_date      := SYSDATE;
				bilfeedtlrec.last_updated_by    := 'biling';
				bilfeedtlrec.last_update_date   := SYSDATE;
				INSERT INTO bil_feedtl VALUES bilfeedtlrec;
			END IF;

      --部分負擔30-60日內
			IF bilfeemstrec.emg_pay_amt2 > 0 THEN
				bilfeedtlrec.caseno             := pcaseno;
				bilfeedtlrec.fee_type           := '42';
				bilfeedtlrec.pfincode           := 'CIVC';
				bilfeedtlrec.total_amt          := bilfeemstrec.emg_pay_amt2;
				bilfeedtlrec.created_by         := 'biling';
				bilfeedtlrec.creation_date      := SYSDATE;
				bilfeedtlrec.last_updated_by    := 'biling';
				bilfeedtlrec.last_update_date   := SYSDATE;
				INSERT INTO bil_feedtl VALUES bilfeedtlrec;
			END IF;

      --部分負擔61日以上
			IF bilfeemstrec.emg_pay_amt3 > 0 THEN
				bilfeedtlrec.caseno             := pcaseno;
				bilfeedtlrec.fee_type           := '43';
				bilfeedtlrec.pfincode           := 'CIVC';
				bilfeedtlrec.total_amt          := bilfeemstrec.emg_pay_amt3;
				bilfeedtlrec.created_by         := 'biling';
				bilfeedtlrec.creation_date      := SYSDATE;
				bilfeedtlrec.last_updated_by    := 'biling';
				bilfeedtlrec.last_update_date   := SYSDATE;
				INSERT INTO bil_feedtl VALUES bilfeedtlrec;
			END IF;

      --新加 內政部役政署補助替代役男部份負擔作業 1100 by kuo 20121220
			v_cnt := 0;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				tmp_fincal
			WHERE
				tmp_fincal.caseno = pcaseno
				AND
				tmp_fincal.fincalcode IN (
					'1058',
					'1054',
					'1039',
					'1060',
					'1083',
					'1057',
					'1062',
					'1100',
					'9520'
				);
			IF bilrootrec.hfinacl2 = 'VTAN' OR --bilRootRec.Hfinacl = 'NHI4' OR --UPDATE BY KUO 1010625
			 v_cnt > 0 OR bilrootrec.hfinacl2 = 'EMPL' OR v_fincal = 'EMPL' OR pcaseno = '02925683' THEN
        --部份負擔30日內優減[特定特約代碼、無職榮、員工]
				p_modifityselfpay (pcaseno, bilrootrec.hfinacl2, bilrootrec.dischg_date);
			END IF;
		END IF;
    --榮民病房費部份原輔導會只補助一半，20130101起改全額補助，但是因為文來已經是20130326
    --所以依日期判斷更改VTAN 到 VERT by Kuo 20130326
		v_cnt                           := 0;
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			bil_acnt_wk
		WHERE
			caseno = pcaseno
			AND
			fee_kind = '01'
			AND
			pfincode = 'VTAN' --榮民優減
			AND
			bildate >= TO_DATE ('20130101', 'YYYYMMDD');
    --DBMS_OUTPUT.PUT_LINE('xxx:'||V_CNT);   
		IF v_cnt > 0 THEN
       --更新 BIL_ACNT_WK
			UPDATE bil_acnt_wk
			SET
				pfincode = 'VERT'
			WHERE
				caseno = pcaseno
				AND
				fee_kind = '01'
				AND
				pfincode = 'VTAN' --榮民優減
				AND
				bildate >= TO_DATE ('20130101', 'YYYYMMDD');
       --更新 BIL_FEEDTL
			UPDATE bil_feedtl
			SET
				total_amt = total_amt + (
					SELECT
						total_amt
					FROM
						bil_feedtl
					WHERE
						caseno = pcaseno
						AND
						pfincode = 'VTAN'
						AND
						fee_type = '01'
				)
			WHERE
				caseno = pcaseno
				AND
				pfincode = 'VERT'
				AND
				fee_type = '01';
			DELETE FROM bil_feedtl
			WHERE
				caseno = pcaseno
				AND
				pfincode = 'VTAN'
				AND
				fee_type = '01';
			COMMIT WORK;
		END IF;
    --新膳食判斷 BY KUO 20121121
		diet_nhi346_adjust (pcaseno);
    --國際醫療 BY KUO 20121210
		contract_as999 (pcaseno);
    --1046疾管TB膳食判斷 by kuo 20171026
		diet_1046 (pcaseno);
		adjust_1060_acnt_wk (pcaseno);
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := biloccurrec.pf_key || sqlerrm;
			ROLLBACK WORK;
			subject        := v_program_name || ' Exception on ' || pcaseno;
			message        := '<br>SQLCODE:  ' || v_error_code || '<br>SQLERRM: ' || v_error_info || ', case:' || pcaseno;
			bil_sendmail (NULL, 'chkuo@vghtc.gov.tw', subject, message);
			bil_sendmail (NULL, 'kjlu@vghtc.gov.tw', subject, message);
			bil_sendmail (NULL, 'cc3f@vghtc.gov.tw', subject, message);
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --計算單價
	PROCEDURE getprice (
		ppfkey       VARCHAR2,
		pselfprice   OUT   NUMBER,
		pnhprice     OUT   NUMBER
	) IS
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_price          NUMBER (10, 2);
		v_self_price     NUMBER (10, 2);
		v_nh_price       NUMBER (10, 2);
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.getPrice';
		v_session_id     := userenv ('SESSIONID');
		IF ppfkey LIKE '006%' THEN
			BEGIN
				SELECT
					nvl (udnsalprice, 0),
					nvl (udnnhiprice, 0)
				INTO
					v_self_price,
					v_nh_price
				FROM
					cpoe.udndrgoc
				WHERE
					(udnenddate >= SYSDATE
					 OR
					 udnenddate IS NULL)
					AND
					udnbgndate <= SYSDATE
					AND
					udndrgcode = substr (ppfkey, 4, 5);
			EXCEPTION
				WHEN OTHERS THEN
					v_nh_price     := 9999999;
					v_self_price   := 9999999;
			END;
		ELSE
      --先抓出定價
			BEGIN
				SELECT
					dbpfile.pfprice1
				INTO v_price
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = ppfkey;
			EXCEPTION
				WHEN OTHERS THEN
					v_nh_price     := 9999999;
					v_self_price   := 9999999;
			END;

      --計算健保價
			BEGIN
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100
				INTO
					v_self_price,
					v_nh_price
				FROM
					pfclass
				WHERE
					pfclass.pfincode = 'LABI';
				v_nh_price     := v_nh_price;
				v_self_price   := v_self_price;
			EXCEPTION
				WHEN OTHERS THEN
					v_nh_price     := 0;
					v_self_price   := v_price;
			END;
		END IF;
		pselfprice       := v_nh_price;
		pnhprice         := v_self_price;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --計算醫令明細
	PROCEDURE acntwkcalculate (
		pcaseno VARCHAR2
	) IS
		CURSOR cur_master IS
		SELECT
			fee_kind
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
		GROUP BY
			fee_kind;
		CURSOR cur_1 (
			pfeekind VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.fee_kind = pfeekind
		ORDER BY
			fee_kind,
			price_code,
			start_date,
			cir_code,
			qty,
			emg_flag,
			self_flag,
			bed_no;

    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_fee_kind       VARCHAR2 (10);
		bilacntwkrec     bil_acnt_wk%rowtype;
		bilacntdetrec    bil_acntdet%rowtype;
		v_cnt            INTEGER;
		v_seqno          INTEGER;
		v_tqty           NUMBER (8, 2);
		v_flag           VARCHAR2 (01) := 'N';
	BEGIN
    --設定程式名稱及session_id
		v_program_name         := 'biling_calculate_PKG.AcntWkCalculate';
		v_session_id           := userenv ('SESSIONID');
		v_source_seq           := pcaseno;
    --依各類別取出acntwk資料作匯總,寫入醫令明細中
		bilacntdetrec.caseno   := pcaseno;
		v_seqno                := 0;
		OPEN cur_master;
		LOOP
			FETCH cur_master INTO v_fee_kind;
			EXIT WHEN cur_master%notfound;
      --藥費
			v_cnt                      := 0;
			v_tqty                     := 0;
			OPEN cur_1 (v_fee_kind);
			LOOP
				EXIT WHEN cur_1%notfound;
				FETCH cur_1 INTO bilacntwkrec;
				v_cnt := v_cnt + 1;
				IF v_cnt = 1 THEN
					bilacntdetrec.self_flag      := bilacntwkrec.self_flag;
					bilacntdetrec.ins_fee_code   := bilacntwkrec.ins_fee_code;
					bilacntdetrec.emg_per        := bilacntwkrec.emg_per;
					bilacntdetrec.qty            := bilacntwkrec.qty;
					bilacntdetrec.cir_code       := bilacntwkrec.cir_code;
					bilacntdetrec.path_code      := bilacntwkrec.path_code;
					bilacntdetrec.dept_code      := bilacntwkrec.dept_code;
					bilacntdetrec.bed_no         := bilacntwkrec.bed_no;
					bilacntdetrec.start_date     := bilacntwkrec.start_date;
					bilacntdetrec.end_date       := bilacntwkrec.end_date;
					bilacntdetrec.tqty           := bilacntwkrec.tqty;
					bilacntdetrec.insu_amt       := bilacntwkrec.insu_amt;
					bilacntdetrec.start_date     := bilacntwkrec.start_date;
					bilacntdetrec.self_amt       := bilacntwkrec.self_amt;
					bilacntdetrec.start_time     := bilacntwkrec.start_time;
					bilacntdetrec.end_time       := bilacntwkrec.end_time;
				END IF;
				IF bilacntdetrec.ins_fee_code = bilacntwkrec.ins_fee_code AND bilacntdetrec.self_flag = bilacntwkrec.self_flag AND bilacntdetrec
				.emg_per = bilacntwkrec.emg_per AND bilacntdetrec.self_amt = bilacntwkrec.self_amt AND bilacntdetrec.insu_amt = bilacntwkrec.
				insu_amt THEN
					v_flag                   := 'Y';
					bilacntdetrec.end_date   := bilacntwkrec.end_date;
					bilacntdetrec.end_time   := bilacntwkrec.end_time;
					v_tqty                   := v_tqty + bilacntwkrec.tqty;
				ELSE
					v_seqno                      := v_seqno + 1;
					bilacntdetrec.seq_no         := v_seqno;
					bilacntdetrec.racnt_no       := v_fee_kind;
					bilacntdetrec.order_type     := '2';
					bilacntdetrec.tqty           := v_tqty;
					IF bilacntdetrec.self_flag = 'Y' THEN
						bilacntdetrec.tamt := v_tqty * bilacntwkrec.self_amt;
					ELSE
						bilacntdetrec.tamt := v_tqty * bilacntwkrec.insu_amt;
					END IF;
					IF bilacntwkrec.self_flag = 'Y' THEN
						IF bilacntwkrec.price_code LIKE '006%' THEN
							BEGIN
								SELECT
									udndrgoc.udnmftdgnm
								INTO
									bilacntdetrec
								.full_name
								FROM
									cpoe.udndrgoc
								WHERE
									(udnenddate >= bilacntwkrec.start_date
									 OR
									 udnenddate IS NULL)
									AND
									udnbgndate <= bilacntwkrec.start_date
									AND
									udndrgcode = substr (bilacntwkrec.price_code, 4, 5);
							EXCEPTION
								WHEN OTHERS THEN
									v_error_code   := sqlcode;
									v_error_info   := sqlerrm;
							END;
						ELSE
							BEGIN
								SELECT
									dbpfile.pfnmc
								INTO
									bilacntdetrec
								.full_name
								FROM
									cpoe.dbpfile
								WHERE
									dbpfile.pfkey = bilacntwkrec.price_code;
							EXCEPTION
								WHEN OTHERS THEN
									bilacntdetrec.full_name := '';
							END;
						END IF;
					ELSE
						IF bilacntwkrec.price_code LIKE '006%' THEN
							BEGIN
								SELECT
									udndrgoc.udnmftdgnm
								INTO
									bilacntdetrec
								.full_name
								FROM
									cpoe.udndrgoc
								WHERE
									(udnenddate >= bilacntwkrec.start_date
									 OR
									 udnenddate IS NULL)
									AND
									udnbgndate <= bilacntwkrec.start_date
									AND
									udndrgcode = substr (bilacntwkrec.price_code, 4, 5);
							EXCEPTION
								WHEN OTHERS THEN
									v_error_code   := sqlcode;
									v_error_info   := sqlerrm;
							END;
						ELSE
							BEGIN
								SELECT
									labitemc
								INTO
									bilacntdetrec
								.full_name
								FROM
									vsnhi
								WHERE
									vsnhi.labkey = bilacntwkrec.ins_fee_code
									AND
									(labedate >= bilacntwkrec.start_date
									 OR
									 labedate IS NULL)
									AND
									labbdate <= bilacntwkrec.start_date;
							EXCEPTION
								WHEN OTHERS THEN
									bilacntdetrec.full_name := '';
							END;
						END IF;
					END IF;
					INSERT INTO bil_acntdet VALUES bilacntdetrec;
					v_tqty                       := 0;
					bilacntdetrec.self_flag      := bilacntwkrec.self_flag;
					bilacntdetrec.ins_fee_code   := bilacntwkrec.ins_fee_code;
					bilacntdetrec.emg_per        := bilacntwkrec.emg_per;
					bilacntdetrec.qty            := bilacntwkrec.qty;
					bilacntdetrec.cir_code       := bilacntwkrec.cir_code;
					bilacntdetrec.path_code      := bilacntwkrec.path_code;
					bilacntdetrec.dept_code      := bilacntwkrec.dept_code;
					bilacntdetrec.bed_no         := bilacntwkrec.bed_no;
					bilacntdetrec.tqty           := v_tqty;
					bilacntdetrec.insu_amt       := bilacntwkrec.insu_amt;
					bilacntdetrec.self_amt       := bilacntwkrec.self_amt;
					bilacntdetrec.start_time     := bilacntwkrec.start_time;
					bilacntdetrec.end_time       := bilacntwkrec.end_time;
				END IF;
			END LOOP;
			CLOSE cur_1;
			v_seqno                    := v_seqno + 1;
			bilacntdetrec.seq_no       := v_seqno;
			bilacntdetrec.racnt_no     := v_fee_kind;
			bilacntdetrec.order_type   := '2';
			bilacntdetrec.tqty         := v_tqty;
			IF bilacntdetrec.self_flag = 'Y' THEN
				bilacntdetrec.tamt := v_tqty * bilacntwkrec.self_amt;
			ELSE
				bilacntdetrec.tamt := v_tqty * bilacntwkrec.insu_amt;
			END IF;
			INSERT INTO bil_acntdet VALUES bilacntdetrec;
		END LOOP;
		CLOSE cur_master;
	EXCEPTION
    --因為如果透過 user exception 已經塞好錯誤訊息入 err_code及err_info,故不需重取
		WHEN e_user_exception THEN
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --this is old one for swith backup in case by kuo 1010628
	PROCEDURE checkbildate_new (
		pcaseno VARCHAR2
	) IS
		v_date           DATE;
		v_cnt            INTEGER;
		v_daily_flag     VARCHAR2 (01);
		v_days           INTEGER;
		v_14days         INTEGER;
		v_14amt          NUMBER (10, 0);
		bildaterec       bil_date%rowtype;
		bilrootrec       bil_root%rowtype;
		CURSOR cur_2 (
			pmaxdate DATE
		) IS
		SELECT DISTINCT
			TRIM (hbed),
			TRIM (pat_adm_bed.hnursta)
		FROM
			common.pat_adm_bed
		WHERE
			hcaseno = pcaseno
			AND
			hbeddt || hbedtm = TO_CHAR (pmaxdate, 'yyyymmddhh24mi')
			AND
			TRIM (hbeddt) IS NOT NULL;
		v_wardno         VARCHAR2 (04);
		v_bed_no         VARCHAR2 (06);
		v_beddge         VARCHAR2 (04);
		v_hfinacl        VARCHAR2 (10);
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_enddate        DATE;
		v_max_date       DATE;
		v_other_days     INTEGER;
		v_up_hfinacl     VARCHAR2 (10);
		yy               VARCHAR2 (03);
		mmdd             VARCHAR2 (04);
		rsbeddge         VARCHAR2 (04);
		patadmcaserec    common.pat_adm_case%rowtype;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.checkBilDate';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		v_other_days     := 0;
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			bil_root.caseno = pcaseno;
		SELECT
			*
		INTO patadmcaserec
		FROM
			common.pat_adm_case
		WHERE
			common.pat_adm_case.hcaseno = pcaseno;
		IF bilrootrec.admit_again_flag <> patadmcaserec.hreadmit OR bilrootrec.admit_again_flag IS NULL THEN
			UPDATE bil_root
			SET
				admit_again_flag = patadmcaserec.hreadmit
			WHERE
				caseno = pcaseno;
			bilrootrec.admit_again_flag := patadmcaserec.hreadmit;
		END IF;
		v_date           := trunc (bilrootrec.admit_date);
		v_enddate        := trunc (bilrootrec.dischg_date);

    --設定開始天數(加入14天合併天數)
		IF bilrootrec.admit_again_flag = 'Y' THEN
			p_get14days (pcaseno => pcaseno, ptotaldays => v_14days, ptotalamt => v_14amt);
			v_days := v_14days;
      --dbms_output.put_line(pCaseNo||','||v_14Days||','||v_14Amt);
		ELSE
			v_days := 0;
		END IF;

    --判斷日期區間是否均已有bildate資料
		IF v_enddate IS NULL THEN
			v_enddate := trunc (SYSDATE - 1);
		END IF;

    --清除不在住院起迄日期範圍帳
		IF bilrootrec.dischg_date IS NOT NULL THEN
      --add by kuo 970807
			DELETE FROM bil_occur --醫師費算進又算出
			WHERE
				bil_occur.caseno = pcaseno
				AND
				bil_date > v_enddate
				AND
				fee_kind = '03';
			DELETE FROM bil_occur --病房費,護理費算進不算出
			WHERE
				bil_occur.caseno = pcaseno
				AND
				bil_date >= v_enddate
				AND
				fee_kind IN (
					'01',
					'05'
				);
			DELETE FROM bil_occur
			WHERE
				caseno = pcaseno
				AND
				bil_date > v_enddate
				AND
				pf_key LIKE 'DIET%'
				AND
				length (pf_key) <= 6;
			DELETE FROM bil_occur
			WHERE
				bil_occur.caseno = pcaseno
				AND
				bil_date < trunc (bilrootrec.admit_date)
				AND
				fee_kind IN (
					'01',
					'03',
					'05'
				);
			DELETE FROM bil_occur
			WHERE
				caseno = pcaseno
				AND
				bil_date < trunc (bilrootrec.admit_date)
				AND
				pf_key LIKE 'DIET%'
				AND
				length (pf_key) <= 6;
		END IF;
		LOOP
			EXIT WHEN v_date > v_enddate;
			IF trunc (v_date) = TO_DATE ('2007/11/20', 'yyyy/mm/dd') THEN
				v_date := TO_DATE ('2007/11/20', 'yyyy/mm/dd');
			END IF;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				bil_date
			WHERE
				bil_date.caseno = pcaseno
				AND
				bil_date.bil_date = v_date;
			IF v_cnt = 0 THEN
				biling_daily_pkg.expandbildate (pcaseno, v_date);
				biling_daily_pkg.adddailyservicefeeforcase (pcaseno, v_date);
			ELSE
        --取出今天的身份別
				v_hfinacl      := biling_calculate_pkg.f_getnhrangeflag (pcaseno, v_date, '2');

        --計算出今天是第幾天
				IF v_up_hfinacl IS NULL THEN
					v_up_hfinacl := v_hfinacl;
				END IF;
				IF v_other_days > 14 THEN
					v_days := 0;
				END IF;
				IF v_hfinacl <> v_up_hfinacl AND v_hfinacl = 'NHI0' THEN
					v_days := 0;
				END IF;
				v_days         := v_days + 1;
				IF v_hfinacl <> v_up_hfinacl AND v_hfinacl <> 'CIVC' AND v_hfinacl <> 'NHI0' THEN
					v_other_days   := v_other_days + 1;
					v_days         := v_days - 1;
				END IF;
				IF v_hfinacl = 'NHI0' THEN
					v_other_days := 0;
				END IF;
				v_up_hfinacl   := v_hfinacl;

        --取出今天應該是那一張床
        --取出本日最後一張床的位置
        --取出最接近現在日期的轉床日期
				SELECT
					MAX (TO_DATE (hbeddt || hbedtm, 'yyyymmddhh24mi'))
				INTO v_max_date
				FROM
					common.pat_adm_bed
				WHERE
					hcaseno = pcaseno
					AND
					hbeddt <= TO_CHAR (v_date, 'yyyymmdd')
					AND
					TRIM (hbeddt) IS NOT NULL;

        --取出最後一次轉床記錄
				OPEN cur_2 (v_max_date);
				FETCH cur_2 INTO
					v_bed_no,
					v_wardno;
				CLOSE cur_2;

        --SELECT 病房等級
				BEGIN
					SELECT
						hbeddge
					INTO v_beddge
					FROM
						common.adm_bed
					WHERE
						rtrim (hnurstat) = rtrim (v_wardno)
						AND
						rtrim (hbedno) = rtrim (v_bed_no);
				EXCEPTION
					WHEN OTHERS THEN
						v_beddge := '';
				END;
				SELECT
					*
				INTO bildaterec
				FROM
					bil_date
				WHERE
					bil_date.caseno = pcaseno
					AND
					bil_date.bil_date = v_date;
        --特等病房保留查詢 BY KUO 980826
				BEGIN
					yy                   := lpad (to_number (TO_CHAR (v_date, 'YYYY')) - 1911, 3, '0');
					mmdd                 := TO_CHAR (v_date, 'MMDD');
					bildaterec.blordge   := '';
					SELECT
						rtrim (rbbeddge)
					INTO rsbeddge
					FROM
						common.reservebed
					WHERE
						rtrim (rbcaseno) = pcaseno
						AND
						rtrim (rbbegdt) <= yy || mmdd
						AND
						rtrim (rbenddt) > yy || mmdd;
					IF rsbeddge = '12AA' THEN
						bildaterec.blordge := 'A';
					ELSIF rsbeddge = '12AB' THEN
						bildaterec.blordge := 'B';
					ELSIF rsbeddge IS NOT NULL THEN
						bildaterec.blordge := substr (rsbeddge, 1, 1);
					END IF;
					UPDATE bil_date
					SET
						blordge = bildaterec.blordge,
						daily_flag = 'N'
					WHERE
						bil_date.caseno = pcaseno
						AND
						bil_date.bil_date = v_date;
					COMMIT WORK;
					biling_daily_pkg.adddailyservicefeeforcase (pcaseno, v_date);
				EXCEPTION
					WHEN OTHERS THEN
						bildaterec.blordge := '';
				END;
        --日期
				IF bildaterec.days <> v_days OR bildaterec.hfinacl <> v_hfinacl OR bildaterec.bed_no <> v_bed_no OR bildaterec.wardno <> v_wardno
				OR bildaterec.beddge <> v_beddge THEN
					IF (bildaterec.bed_no = v_bed_no AND bildaterec.wardno = v_wardno) AND bildaterec.beddge <> v_beddge THEN
						UPDATE bil_date
						SET
							days = v_days,
							hfinacl = v_hfinacl
						WHERE
							bil_date.caseno = pcaseno
							AND
							bil_date.bil_date = v_date;
					ELSE
						UPDATE bil_date
						SET
							days = v_days,
							hfinacl = v_hfinacl
						WHERE
							bil_date.caseno = pcaseno
							AND
							bil_date.bil_date = v_date;
					END IF;
					v_daily_flag := 'N';
				END IF;

        --變更身份,伙食要重算
				IF v_hfinacl <> bildaterec.hfinacl THEN
					UPDATE bil_date
					SET
						diet_flag = 'N'
					WHERE
						bil_date.caseno = pcaseno
						AND
						bil_date.bil_date = v_date;
				END IF;
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					bil_occur
				WHERE
					bil_occur.caseno = pcaseno
					AND
					bil_occur.bil_date = v_date
					AND
					bil_occur.fee_kind = '01';
				IF v_cnt = 0 THEN
					v_daily_flag := 'N';
					UPDATE bil_date
					SET
						daily_flag = 'N'
					WHERE
						bil_date.caseno = pcaseno
						AND
						bil_date.bil_date = v_date;
				END IF;
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					bil_occur
				WHERE
					bil_occur.caseno = pcaseno
					AND
					trunc (bil_occur.bil_date) = trunc (v_date)
					AND
					bil_occur.fee_kind = '02'
					AND
					length (pf_key) <= 6;
				IF v_cnt = 0 THEN
					v_daily_flag := 'N';
					UPDATE bil_date
					SET
						bil_date.diet_flag = 'N'
					WHERE
						bil_date.caseno = pcaseno
						AND
						bil_date.bil_date = v_date;
				END IF;
				IF v_cnt > 3 THEN
					v_daily_flag := 'N';
					DELETE FROM bil_occur
					WHERE
						caseno = pcaseno
						AND
						pf_key LIKE 'DIET%'
						AND
						length (pf_key) <= 6;
					DELETE FROM bil_occur
					WHERE
						bil_occur.caseno = pcaseno
						AND
						bil_occur.fee_kind = '02'
						AND
						bil_occur.operator_name = 'DDAILY';
					UPDATE bil_date
					SET
						bil_date.diet_flag = 'N'
					WHERE
						bil_date.caseno = pcaseno
						AND
						bil_date.bil_date = v_date;
				END IF;
				IF v_daily_flag = 'N' OR v_daily_flag IS NULL THEN
					biling_daily_pkg.adddailyservicefeeforcase (pcaseno, v_date);
				END IF;
			END IF;
			v_date := v_date + 1;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;
	PROCEDURE checkbildate (
		i_hcaseno VARCHAR2
	) IS
		r_pat_adm_case        common.pat_adm_case%rowtype;
		r_bil_root            bil_root%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
		l_start_bil_date      DATE;
		l_end_bil_date        DATE;
		l_bil_date            DATE;
	BEGIN
		-- 取出住院主檔
		SELECT
			*
		INTO r_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = i_hcaseno;

		-- 更新 14 天再入院註記
		UPDATE bil_root
		SET
			admit_again_flag = r_pat_adm_case.hreadmit
		WHERE
			caseno = r_pat_adm_case.hcaseno;

		-- 取出住院帳務主檔
		SELECT
			*
		INTO r_bil_root
		FROM
			bil_root
		WHERE
			caseno = r_pat_adm_case.hcaseno;

		-- 日檔起迄範圍
		l_start_bil_date   := trunc (r_bil_root.admit_date);
		l_end_bil_date     := trunc (nvl (r_bil_root.dischg_date, SYSDATE));

		-- 逐日展開日檔
		l_bil_date         := l_start_bil_date;
		LOOP
			EXIT WHEN l_bil_date > l_end_bil_date;
			biling_daily_pkg.expandbildate (r_pat_adm_case.hcaseno, l_bil_date);
			FOR r_bil_date IN (
				SELECT
					*
				FROM
					bil_date
				WHERE
					caseno = r_pat_adm_case.hcaseno
					AND
					bil_date = l_bil_date
			) LOOP
				biling_daily_pkg.adddailyservicefeeforcase (r_bil_date.caseno, l_bil_date);

				-- 只取一天
				EXIT;
			END LOOP;
			l_bil_date := l_bil_date + 1;
		END LOOP;

		-- 刪除超出住院起迄範圍的費用
		-- 刪除醫師費（算進算出）
		DELETE FROM bil_occur
		WHERE
			caseno = r_pat_adm_case.hcaseno
			AND
			bil_date NOT BETWEEN l_start_bil_date AND l_end_bil_date
			AND
			fee_kind = '03'
			AND
			operator_name = 'dailyBatch';
		-- 刪除病房費、護理費（算進不算出）
		DELETE FROM bil_occur
		WHERE
			caseno = r_pat_adm_case.hcaseno
			AND
			(bil_date NOT BETWEEN l_start_bil_date AND l_end_bil_date
			 OR
			 bil_date = trunc (r_bil_root.dischg_date)
			 AND
			 bil_date != trunc (r_bil_root.admit_date))
			AND
			fee_kind IN (
				'01',
				'05'
			)
			AND
			operator_name = 'dailyBatch';
		-- 刪除膳食費
		DELETE FROM bil_occur
		WHERE
			caseno = r_pat_adm_case.hcaseno
			AND
			bil_date NOT BETWEEN l_start_bil_date AND l_end_bil_date
			AND
			fee_kind = '02'
			AND
			pf_key LIKE 'DIET%'
			AND
			length (pf_key) <= 6;
		DELETE FROM bil_occur
		WHERE
			caseno = r_pat_adm_case.hcaseno
			AND
			bil_date NOT BETWEEN l_start_bil_date AND l_end_bil_date
			AND
			fee_kind = '02'
			AND
			operator_name = 'DDAILY';
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'checkbildate';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_hcaseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
	END;

  --計算乘數
	FUNCTION getemgper (
		pcaseno    VARCHAR2, --住院序
		ppfkey     VARCHAR2, --計價碼
		pfeekind   VARCHAR2, --帳檔計價類別
		pbldate    DATE,--計價日 new add by kuo 20140731
		pemgflag   VARCHAR2, --急作否
		ptype      VARCHAR2
	) --'1'算全部成數 '2',只算急作成數
	 RETURN NUMBER IS
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_cnt            INTEGER;
		pemgper          NUMBER (10, 2) := 1; --急作乘數預設為1
		v_pf_self_pay    NUMBER (10, 2); --自費金額
		v_pf_nh_pay      NUMBER (10, 2); --申報金額
		v_pf_child_pay   NUMBER (10, 2); --兒童加乘
		v_faemep_flag    VARCHAR2 (01); --住院可急作否
		v_pfopfg_flag    VARCHAR2 (01); --手術否
		v_pfspexam       VARCHAR2 (01); --特殊檢驗否
		v_child_flag_1   VARCHAR2 (01) := 'N'; --兒童加乘
		v_child_flag_2   VARCHAR2 (01) := 'N'; --兒童加乘
		v_child_flag_3   VARCHAR2 (01) := 'N'; --兒童加乘
		bilrootrec       bil_root%rowtype;
		ls_date          VARCHAR2 (10);
		v_nh_type        VARCHAR2 (02);
		or_emper         NUMBER; -- add by kuo 20140822
		vnh_lbchild      VARCHAR2 (01);--提升兒童加成 by kuo 201600824
		vnh_child        VARCHAR2 (01);--兒童加成 by kuo 201600824
		vlabkey          VARCHAR2 (12);--新規則復健健保碼使用 by kuo 20191120

    --出生年齡(健保規定年齡部份計算為年-年)
    --月份才是年月日
		v_yy             INTEGER;

    --add LABKEY for 新規則復健健保碼 by kuo 20191120
		CURSOR cur_vsnhi (
			ppfkey VARCHAR2
		) IS
		SELECT
			vsnhi.labtype,
			vsnhi.labchild,
			vsnhi.labchild_inc,
			vsnhi.labkey
		FROM
			vsnhi,
			pflabi
		WHERE
			pflabi.pfkey = ppfkey
			AND
			vsnhi.labkey = pflabi.pflabcd
			AND
			vsnhi.labbdate <= pbldate
			AND
			vsnhi.labedate >= pbldate;
		CURSOR cur_1 (
			ppfkey VARCHAR2
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfaemep,
			pfopfg,
			pfspexam
		FROM
			pfclass
		WHERE
			pfkey = ppfkey
			AND
			(pfinoea = 'A'
			 OR
			 pfinoea = '@')
			AND
			pfincode = 'LABI'
			AND
			pfbegindate <= pbldate
			AND
			pfenddate >= pbldate
		UNION
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfaemep,
			pfopfg,
			pfspexam
		FROM
			pfhiscls
		WHERE
			pfkey = ppfkey
			AND
			(pfinoea = 'A'
			 OR
			 pfinoea = '@')
			AND
			pfincode = 'LABI'
			AND
			pfbegindate <= pbldate
			AND
			pfenddate >= pbldate;
    /*
      SELECT to_number(pfselpay) / 100,
             to_number(pfreqpay) / 100,
             to_number(pfchild),
             pfaemep,
             pfopfg,
             pfspexam
        FROM pfclass
       WHERE pfclass.pfkey = pPFkey
         AND (PFCLASS.PFINOEA = 'A' OR PFCLASS.PFINOEA = '@');
    */     
    --因應成數變化新增cursor by kuo 20140822
		CURSOR get_or_emper (
			ppfkey VARCHAR2
		) IS
		SELECT
			rate_num
		FROM
			pf_ratedtl
		WHERE
			pfkey = ppfkey
			AND
			impl_date <= pbldate
			AND
			end_date >= pbldate;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.getEmgPer';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		pemgper          := 1;
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			bil_root.caseno = pcaseno;
		OPEN cur_vsnhi (ppfkey);
		FETCH cur_vsnhi INTO
			v_nh_type,
			vnh_child,
			vnh_lbchild,
			vlabkey;
		CLOSE cur_vsnhi;
		IF bilrootrec.birth_date IS NULL THEN --避免錯誤 by kuo 20141203
			bilrootrec.birth_date := TO_DATE ('19880101', 'YYYYMMDD');
		END IF;
		ls_date          := biling_common_pkg.f_datebetween (b_date => bilrootrec.birth_date, e_date => bilrootrec.admit_date);
		v_yy             := to_number (TO_CHAR (bilrootrec.admit_date, 'yyyy')) - to_number (TO_CHAR (bilrootrec.birth_date, 'yyyy'));
		IF pbldate >= TO_DATE ('20160901', 'YYYYMMDD') THEN
			v_yy      := to_number (TO_CHAR (pbldate, 'yyyy')) - to_number (TO_CHAR (bilrootrec.birth_date, 'yyyy'));
			ls_date   := round (months_between (TO_DATE (TO_CHAR (pbldate, 'YYYYMM') || '01', 'YYYYMMDD'), TO_DATE (TO_CHAR (bilrootrec.birth_date
			, 'YYYYMM') || '01', 'YYYYMMDD')), 0);
		END IF;

    --75歲診察費加計20% by kuo 20200102, 20200101以後生效
		IF ppfkey LIKE 'DIAG%' AND pfeekind = '03' AND ls_date >= 900 AND pbldate >= TO_DATE ('20200101', 'YYYYMMDD') THEN
			pemgper := pemgper + 0.2;
		END IF;

    --Add new 74701591 固定加成 1.5 by kuo 20151105, 20151001生效
		IF ppfkey = '74701591' AND pbldate >= TO_DATE ('20151001', 'YYYYMMDD') THEN
			pemgper := 1.5;
			RETURN pemgper;
		END IF;

    --取出病患年齡
    --判斷是否符合兒童加乘( 6歲以下 , 二歲以下 ,六個月以下)
    --年齡大於6歲,就沒有兒童加乘
		v_child_flag_1   := 'N';
		v_child_flag_2   := 'N';
		v_child_flag_3   := 'N';
		IF v_yy > 6 THEN
			v_child_flag_1   := 'N';
			v_child_flag_2   := 'N';
			v_child_flag_3   := 'N';
		ELSE
			IF pbldate < TO_DATE ('20160901', 'YYYYMMDD') THEN
            --小於六歲大於二歲者
				IF v_yy <= 6 AND to_number (ls_date) > 20000 THEN
					v_child_flag_1 := 'Y';
				ELSE
                --年齡小於一歲,月份又小於六個月
					IF substr (ls_date, 1, 3) = '000' AND to_number (substr (ls_date, 4, 2)) < 6 THEN
						v_child_flag_3 := 'Y';
                --小於二歲大於六個月
					ELSE
						v_child_flag_2 := 'Y';
					END IF;
				END IF;
			END IF;
		END IF;

    --add new 兒童加成判斷從20160901開始 by kuo
    --add 結束日期 20181031, 20181029
    --IF PBLDATE  >= TO_DATE('20160901','YYYYMMDD') THEN
		IF pbldate >= TO_DATE ('20160901', 'YYYYMMDD') AND pbldate <= TO_DATE ('20181031', 'YYYYMMDD') THEN
        --手術
			IF pfeekind IN (
				'07',
				'08'
			) OR v_nh_type = '07' THEN
				IF ls_date <= 6 THEN --小於等於六個月
					v_child_flag_3 := 'Y';
				END IF;
				IF ls_date <= 23 AND ls_date >= 7 THEN ---二歲到七個月之間
					v_child_flag_2 := 'Y';
				END IF;
				IF ls_date >= 24 AND ls_date <= 83 THEN --六歲以下
					v_child_flag_1 := 'Y';
				END IF;
			ELSE --非手術           
				IF ls_date < 6 THEN --小於六個月
					v_child_flag_3 := 'Y';
				END IF;
				IF ls_date <= 23 AND ls_date >= 6 THEN ---二歲到六個月之間
					v_child_flag_2 := 'Y';
				END IF;
				IF ls_date >= 24 AND ls_date <= 83 THEN --六歲以下
					v_child_flag_1 := 'Y';
				END IF;
			END IF;
		END IF;

    --add new 兒童加成判斷從20181101開始 by kuo 20181029  
		IF pbldate >= TO_DATE ('20181101', 'YYYYMMDD') THEN
			IF ls_date < 6 THEN --小於六個月
				v_child_flag_3 := 'Y';
			END IF;
			IF ls_date <= 23 AND ls_date >= 6 THEN ---二歲到六個月之間
				v_child_flag_2 := 'Y';
			END IF;
			IF ls_date >= 24 AND ls_date <= 83 THEN --六歲以下
				v_child_flag_1 := 'Y';
			END IF;
		END IF;
		OPEN cur_1 (ppfkey);
		FETCH cur_1 INTO
			v_pf_self_pay,
			v_pf_nh_pay,
			v_pf_child_pay,
			v_faemep_flag,
			v_pfopfg_flag,
			v_pfspexam;
		IF cur_1%found THEN
      --DBMS_OUTPUT.put_line(pPfkey || ',' || v_faemep_flag) ;
      --UPDATE 20110111 BY AMBER 自費項'11'手術材料費未算入,需使用加乘
			IF ppfkey = '80007439' THEN
				pemgper := pemgper + 0.53;
			END IF;

      --住院可報急作,且有急作註記者
			IF v_faemep_flag = 'Y' AND pemgflag = 'E' THEN
        --手術,接生加成
				IF pfeekind IN (
					'07',
					'08'
				) OR v_nh_type = '07' THEN
					pemgper := pemgper + 0.3;
				ELSE
					pemgper := pemgper + 0.2;
				END IF;
			END IF;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				pflabi
			WHERE
				pflabi.pfkey = ppfkey;
			IF v_cnt > 0 THEN
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					pflabi,
					vsnhi
				WHERE
					pflabi.pfkey = ppfkey
					AND
					pflabi.pflabcd = vsnhi.labkey
					AND
					(labbdate <= SYSDATE
					 OR
					 labbdate IS NULL)
					AND
					labedate >= SYSDATE
					AND
					vsnhi.nhitype = '07';
				IF v_cnt = 0 THEN
					v_pfopfg_flag := 'N';
				ELSE
					v_pfopfg_flag := 'Y';
				END IF;
			END IF;

      --手術加成
			IF v_pfopfg_flag = 'Y' THEN
        --以下項目材料費內含 80011890 add by kuo 1000525
        --add 80005349 new item by kuo 1010726
        --add 80010407 new item by kuo 1030811
        --add 72309010 new item by kuo 1040128
				IF ppfkey IN (
					'80004399',
					'50004106',
					'80011890',
					'80005349',
					'80010407',
					'72309010'
				) THEN
           --80005349自1061101須加計手術加成53% request by 徐宗玲 add by kuo 20171106
					IF pbldate >= TO_DATE ('20171101', 'YYYYMMDD') AND ppfkey = '80005349' THEN
						pemgper := pemgper + 0.53;
					ELSE
						pemgper := pemgper;
					END IF;
				ELSE
					IF pfeekind <> '08' THEN
						pemgper := pemgper + 0.53;
					END IF;
				END IF;
        --特殊加成 by kuo 20140822
        --因應加成為1+加成數，所以PF_RATEDTL 除了 747開頭外的計價碼都減0.53 by kuo 20141030
				OPEN get_or_emper (ppfkey);
				FETCH get_or_emper INTO or_emper;
				IF get_or_emper%found THEN
					pemgper := pemgper + or_emper;
				END IF;
				CLOSE get_or_emper;

        --眼科特殊加成 by kuo 20140731, 生效日20140801(給的時間真是緊啊...還剩半天)
        --個碼再加成:
        --80010353:1.08
        --80010161:1.00
        --80010408:0.67
        --80010409:0.82
        --80010410:0.53
        --80010192:1.25
        --80010193,80010197:1.25
        --80010411:1.79
        --80010412:1.75
        --80010413:1.68
        --80010414:1.54
        --80010415:1.94
        --80010416:2.35
        --80010417:1.89
        --以下作廢 by kuo 20140822
        /*
        IF pbldate >= to_date('20140801','YYYYMMDD') THEN
            IF PPFKEY IN ('80010192', '80010193', '80010197') THEN
               pEmgPer := pEmgPer + 1.25;
            END IF;
            IF PPFKEY='80010353' THEN
               pEmgPer := pEmgPer + 1.08;
            END IF;
            IF PPFKEY='80010161' THEN
               PEMGPER := PEMGPER + 1;
            END IF;
            IF PPFKEY='80010408' THEN
               PEMGPER := PEMGPER + 0.67;
            END IF;
            IF PPFKEY='80010409' THEN
               PEMGPER := PEMGPER + 0.82;
            END IF;
            IF PPFKEY='80010410' THEN
               PEMGPER := PEMGPER + 0.53;
            END IF;
            IF PPFKEY='80010411' THEN
               PEMGPER := PEMGPER + 1.79;
            END IF;
            IF PPFKEY='80010412' THEN
               PEMGPER := PEMGPER + 1.75;
            END IF;
            IF PPFKEY='80010413' THEN
               PEMGPER := PEMGPER + 1.68;
            END IF;
            IF PPFKEY='80010414' THEN
               PEMGPER := PEMGPER + 1.54;
            END IF;
            IF PPFKEY='80010415' THEN
               PEMGPER := PEMGPER + 1.94;
            END IF;
            IF PPFKEY='80010416' THEN
               PEMGPER := PEMGPER + 2.35;
            END IF;
            IF PPFKEY='80010417' THEN
               PEMGPER := PEMGPER + 1.89;
            END IF;
        END IF;
        */
        --以上作廢 by kuo 20140822
			END IF;
			IF ptype = '2' THEN
				RETURN pemgper;
			END IF;

      --麻醉加成
			IF pfeekind = '09' OR v_nh_type = '11' THEN
				CASE
					WHEN pemgflag = 'C' THEN
						pemgper := pemgper + 0.2;
					WHEN pemgflag IN (
						'D',
						'L'
					) THEN
						pemgper := pemgper + 0.3;
					WHEN pemgflag IN (
						'A',
						'E',
						'I'
					) THEN
						pemgper := pemgper + 0.5;
					WHEN pemgflag = 'J' THEN
						pemgper := pemgper + 0.6;
					WHEN pemgflag = 'B' THEN
						pemgper := pemgper + 0.7;
					WHEN pemgflag IN (
						'G',
						'K'
					) THEN
						pemgper := pemgper + 0.8;
					WHEN pemgflag = 'H' THEN
						pemgper := pemgper + 1;
					ELSE
						pemgper := pemgper;
				END CASE;
			END IF;

      --加重兒童加成與加成 by kuo 20160824 從20160901開始生效
			IF pbldate >= TO_DATE ('20160901', 'YYYYMMDD') THEN
         --dbpfile 未設定兒童加乘金額者,無兒童加乘,多判斷VSNHI裡面要有兒童加成才行 by kuo 20160824
				IF v_pf_child_pay > 0 AND v_pf_child_pay IS NOT NULL AND vnh_child = 'Y' THEN
            --兒童加成(6歲以下)
					IF v_child_flag_1 = 'Y' THEN
						pemgper := pemgper + 0.2;
					END IF;
            --兒童加成(2歲以下)
					IF v_child_flag_2 = 'Y' THEN
						pemgper := pemgper + 0.3;
					END IF;
            --兒童加成(六個月以下)
					IF v_child_flag_3 = 'Y' THEN
               --復健健保碼範圍:41000-44599 X≦ 23M(小於等於23M)：0.3 20191201生效 by kuo 20191120
						IF pbldate >= TO_DATE ('20191201', 'YYYYMMDD') THEN
							IF substr (vlabkey, 1, 5) >= '41000' AND substr (vlabkey, 1, 5) <= '44599' THEN
								pemgper := pemgper + 0.3;
							ELSE
								pemgper := pemgper + 0.6;
							END IF;
						ELSE
							pemgper := pemgper + 0.6;
						END IF;
               --PEMGPER   := PEMGPER + 0.6;
					END IF;
				ELSE
            --六個月以下,手術加成60
            --20200203後取消 by kuo 20200203
					IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') AND pbldate <= TO_DATE ('20200203', 'YYYYMMDD'
					) THEN
						pemgper := pemgper + 0.6;
					END IF;
				END IF;
         --兒童加重加成 20160901 移至這裡計算 by kuo 20160824
				IF vnh_lbchild = 'Y' THEN
             --兒童加成(6歲以下)
					IF v_child_flag_1 = 'Y' THEN
						pemgper := pemgper + 0.6;
					END IF;
            --兒童加成(2歲以下)
					IF v_child_flag_2 = 'Y' THEN
						pemgper := pemgper + 0.8;
					END IF;
            --兒童加成(六個月以下)
					IF v_child_flag_3 = 'Y' THEN
						pemgper := pemgper + 1;
					END IF;
				END IF;
			ELSE 
         --dbpfile 未設定兒童加乘金額者,無兒童加乘
				IF v_pf_child_pay > 0 AND v_pf_child_pay IS NOT NULL THEN
					IF v_child_flag_1 = 'Y' THEN
              --兒童加成(6歲以下)
						pemgper := pemgper + 0.2;
					ELSIF v_child_flag_2 = 'Y' THEN
              --兒童加成(2歲以下)
						pemgper := pemgper + 0.3;
					ELSIF v_child_flag_3 = 'Y' THEN
              --兒童加成(六個月以下)
						pemgper := pemgper + 0.6;
					END IF;
				ELSE
           --六個月以下,手術加成60
					IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') THEN
						pemgper := pemgper + 0.6;
					END IF;
				END IF;
			END IF;
      /*
      --dbpfile 未設定兒童加乘金額者,無兒童加乘
      IF V_PF_CHILD_PAY > 0 AND V_PF_CHILD_PAY IS NOT NULL THEN

        IF v_child_flag_1 = 'Y' THEN
          --兒童加成(6歲以下)
          pEmgPer := pEmgPer + 0.2;
        ELSIF v_child_flag_2 = 'Y' THEN
          --兒童加成(2歲以下)
          pEmgPer := pEmgPer + 0.3;
        ELSIF v_child_flag_3 = 'Y' THEN
          --兒童加成(六個月以下)
          pEmgPer := pEmgPer + 0.6;
        END IF;
      ELSE
        --六個月以下,手術加成60
        IF v_child_flag_3 = 'Y' AND
           (pFeeKind = '07' OR pFeeKind = '08' OR v_pfopfg_flag = 'Y') THEN
          pEmgPer := pEmgPer + 0.6;
        END IF;
      END IF;
      */
      --以下急作成數為固定成數
      /*
      IF pFeeKind = '11' THEN
        --手材併入手術主項不另列
        pEmgPer := 0;
      ELSIF pFeeKind = '12' THEN
        --麻材
        pEmgPer := 0.5;
      ELSIF pFeeKind = '13' THEN
        --手材
        pEmgPer := 0.53;
      ELSIF pFeeKind = '18' THEN
        --治療處理
        --配合99/01/08健保局0994050093號函「全民健保費用支付標準」
        --自99/6/1起實施，年齡小於84個月，以下2碼加成30%、37%，實際修改日期99/7/1        
        IF (v_yy < 7) THEN
          --年齡小於七歲
          IF (BILROOTREC.ADMIT_DATE >= TO_DATE('2010/07/01', 'yyyy/mm/dd')) THEN
            --狀況不明，無人承認規則，先拿掉 by kuo 20150924
            --IF pPFkey IN ('74700256') THEN
            --  pEmgPer := pEmgPer + 0.3;
            --END IF;
            --狀況不明，無人承認規則，先拿掉 by kuo 20150924
            --IF pPFkey IN ('74700371') THEN
            --  PEMGPER := PEMGPER + 0.37;
            --END IF;
            NULL;
          END IF;
        END IF;
      END IF;
      */
		ELSE
        --六個月以下,手術加成60
			IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') THEN
				pemgper := pemgper + 0.6;
			ELSE
				pemgper := 1;
			END IF;
		END IF;
    --以下急作成數為固定成數
		IF pfeekind = '11' THEN
        --手材併入手術主項不另列
			pemgper := 0;
		ELSIF pfeekind = '12' THEN
        --麻材
        --add 55101401, 55101400 不算麻材 by kuo 20180221
			IF ppfkey IN (
				'55101401',
				'55101400'
			) THEN
				pemgper := 0;
			ELSE
				pemgper := 0.5;
			END IF;
        --pEmgPer := 0.5;
		ELSIF pfeekind = '13' THEN
        --手材
			pemgper := 0.53;
		ELSIF pfeekind = '18' THEN
        --治療處理
        --配合99/01/08健保局0994050093號函「全民健保費用支付標準」
        --自99/6/1起實施，年齡小於84個月，以下2碼加成30%、37%，實際修改日期99/7/1        
			IF (v_yy < 7) THEN
          --年齡小於七歲
				IF (bilrootrec.admit_date >= TO_DATE ('2010/07/01', 'yyyy/mm/dd')) THEN
            --狀況不明，無人承認規則，先拿掉 by kuo 20150924
            --IF pPFkey IN ('74700256') THEN
            --  pEmgPer := pEmgPer + 0.3;
            --END IF;
            --狀況不明，無人承認規則，先拿掉 by kuo 20150924
            --IF pPFkey IN ('74700371') THEN
            --  PEMGPER := PEMGPER + 0.37;
            --END IF;
					NULL;
				END IF;
			END IF;
		END IF;
		CLOSE cur_1;
		RETURN pemgper;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --計算乘數 for history
	FUNCTION getemgperhist (
		pcaseno    VARCHAR2, --住院序
		ppfkey     VARCHAR2, --計價碼
		pfeekind   VARCHAR2, --帳檔計價類別
		pbldate    DATE,--計價日 new add by kuo 20140731
		pemgflag   VARCHAR2, --急作否
		ptype      VARCHAR2
	) --'1'算全部成數 '2',只算急作成數
	 RETURN NUMBER IS
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_cnt            INTEGER;
		pemgper          NUMBER (10, 2) := 1; --急作乘數預設為1
		v_pf_self_pay    NUMBER (10, 2); --自費金額
		v_pf_nh_pay      NUMBER (10, 2); --申報金額
		v_pf_child_pay   NUMBER (10, 2); --兒童加乘
		v_faemep_flag    VARCHAR2 (01); --住院可急作否
		v_pfopfg_flag    VARCHAR2 (01); --手術否
		v_pfspexam       VARCHAR2 (01); --特殊檢驗否
		v_child_flag_1   VARCHAR2 (01) := 'N'; --兒童加乘
		v_child_flag_2   VARCHAR2 (01) := 'N'; --兒童加乘
		v_child_flag_3   VARCHAR2 (01) := 'N'; --兒童加乘
		bilrootrec       bil_root%rowtype;
		ls_date          VARCHAR2 (10);
		v_nh_type        VARCHAR2 (02);
		or_emper         NUMBER; -- add by kuo 20140822
		vnh_lbchild      VARCHAR2 (01);--提升兒童加成 by kuo 201600824
		vnh_child        VARCHAR2 (01);--兒童加成 by kuo 201600824

    --出生年齡(健保規定年齡部份計算為年-年)
    --月份才是年月日
		v_yy             INTEGER;
		CURSOR cur_vsnhi (
			ppfkey VARCHAR2
		) IS
		SELECT
			vsnhi.labtype,
			vsnhi.labchild,
			vsnhi.labchild_inc
		FROM
			vsnhi,
			pflabi
		WHERE
			pflabi.pfkey = ppfkey
			AND
			vsnhi.labkey = pflabi.pflabcd
			AND
			vsnhi.labbdate <= pbldate
			AND
			vsnhi.labedate >= pbldate;
		CURSOR cur_1 (
			ppfkey VARCHAR2
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfaemep,
			pfopfg,
			pfspexam
		FROM
			pfclass
		WHERE
			pfkey = ppfkey
			AND
			(pfinoea = 'A'
			 OR
			 pfinoea = '@')
			AND
			pfbegindate <= pbldate
			AND
			pfenddate >= pbldate
		UNION
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfaemep,
			pfopfg,
			pfspexam
		FROM
			pfhiscls
		WHERE
			pfkey = ppfkey
			AND
			(pfinoea = 'A'
			 OR
			 pfinoea = '@')
			AND
			pfbegindate <= pbldate
			AND
			pfenddate >= pbldate;
    /*
      SELECT to_number(pfselpay) / 100,
             to_number(pfreqpay) / 100,
             to_number(pfchild),
             pfaemep,
             pfopfg,
             pfspexam
        FROM pfclass
       WHERE pfclass.pfkey = pPFkey
         AND (PFCLASS.PFINOEA = 'A' OR PFCLASS.PFINOEA = '@');
    */     
    --因應成數變化新增cursor by kuo 20140822
		CURSOR get_or_emper (
			ppfkey VARCHAR2
		) IS
		SELECT
			rate_num
		FROM
			pf_ratedtl
		WHERE
			pfkey = ppfkey
			AND
			impl_date <= pbldate
			AND
			end_date >= pbldate;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.getEmgPerHist';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			bil_root.caseno = pcaseno;
		OPEN cur_vsnhi (ppfkey);
		FETCH cur_vsnhi INTO
			v_nh_type,
			vnh_child,
			vnh_lbchild;
		CLOSE cur_vsnhi;
		IF bilrootrec.birth_date IS NULL THEN --避免錯誤 by kuo 20141203
			bilrootrec.birth_date := TO_DATE ('19880101', 'YYYYMMDD');
		END IF;
		ls_date          := biling_common_pkg.f_datebetween (b_date => bilrootrec.birth_date, e_date => bilrootrec.admit_date);
		v_yy             := to_number (TO_CHAR (bilrootrec.admit_date, 'yyyy')) - to_number (TO_CHAR (bilrootrec.birth_date, 'yyyy'));
		IF pbldate >= TO_DATE ('20160901', 'YYYYMMDD') THEN
			v_yy      := to_number (TO_CHAR (pbldate, 'yyyy')) - to_number (TO_CHAR (bilrootrec.birth_date, 'yyyy'));
			ls_date   := round (months_between (TO_DATE (TO_CHAR (pbldate, 'YYYYMM') || '01', 'YYYYMMDD'), TO_DATE (TO_CHAR (bilrootrec.birth_date
			, 'YYYYMM') || '01', 'YYYYMMDD')), 0);
		END IF;

    --Add new 74701591 固定加成 1.5 by kuo 20151105, 20151001生效
		IF ppfkey = '74701591' AND pbldate >= TO_DATE ('20151001', 'YYYYMMDD') THEN
			pemgper := 1.5;
			RETURN pemgper;
		END IF;
		OPEN cur_1 (ppfkey);
		FETCH cur_1 INTO
			v_pf_self_pay,
			v_pf_nh_pay,
			v_pf_child_pay,
			v_faemep_flag,
			v_pfopfg_flag,
			v_pfspexam;
		IF cur_1%found THEN
			dbms_output.put_line (ppfkey || ',' || v_faemep_flag);
      --UPDATE 20110111 BY AMBER 自費項'11'手術材料費未算入,需使用加乘
			IF ppfkey = '80007439' THEN
				pemgper := pemgper + 0.53;
			END IF;
      --取出病患年齡
      --判斷是否符合兒童加乘( 6歲以下 , 二歲以下 ,六個月以下)
      --年齡大於6歲,就沒有兒童加乘
			v_child_flag_1   := 'N';
			v_child_flag_2   := 'N';
			v_child_flag_3   := 'N';
			IF v_yy > 6 THEN
				v_child_flag_1   := 'N';
				v_child_flag_2   := 'N';
				v_child_flag_3   := 'N';
			ELSE
				IF pbldate < TO_DATE ('20160901', 'YYYYMMDD') THEN
           --小於六歲大於二歲者
					IF v_yy <= 6 AND to_number (ls_date) > 20000 THEN
						v_child_flag_1 := 'Y';
					ELSE
              --年齡小於一歲,月份又小於六個月
						IF substr (ls_date, 1, 3) = '000' AND to_number (substr (ls_date, 4, 2)) < 6 THEN
							v_child_flag_3 := 'Y';
                --小於二歲大於六個月
						ELSE
							v_child_flag_2 := 'Y';
						END IF;
					END IF;
				END IF;
			END IF;

      --add new 兒童加成判斷從20160901開始 by kuo
			IF pbldate >= TO_DATE ('20160901', 'YYYYMMDD') THEN
         --手術
				IF pfeekind IN (
					'07',
					'08'
				) OR v_nh_type = '07' THEN
					IF ls_date <= 6 THEN --小於等於六個月
						v_child_flag_3 := 'Y';
					END IF;
					IF ls_date <= 23 AND ls_date >= 7 THEN ---二歲到七個月之間
						v_child_flag_2 := 'Y';
					END IF;
					IF ls_date >= 24 AND ls_date <= 83 THEN --六歲以下
						v_child_flag_1 := 'Y';
					END IF;
				ELSE --非手術           
					IF ls_date < 6 THEN --小於六個月
						v_child_flag_3 := 'Y';
					END IF;
					IF ls_date <= 23 AND ls_date >= 6 THEN ---二歲到六個月之間
						v_child_flag_2 := 'Y';
					END IF;
					IF ls_date >= 24 AND ls_date <= 83 THEN --六歲以下
						v_child_flag_1 := 'Y';
					END IF;
				END IF;
			END IF;

      --住院可報急作,且有急作註記者
			IF v_faemep_flag = 'Y' AND pemgflag = 'E' THEN
        --手術,接生加成
				IF pfeekind IN (
					'07',
					'08'
				) OR v_nh_type = '07' THEN
					pemgper := pemgper + 0.3;
				ELSE
					pemgper := pemgper + 0.2;
				END IF;
			END IF;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				pflabi
			WHERE
				pflabi.pfkey = ppfkey;
			IF v_cnt > 0 THEN
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					pflabi,
					vsnhi
				WHERE
					pflabi.pfkey = ppfkey
					AND
					pflabi.pflabcd = vsnhi.labkey
					AND
					(labbdate <= SYSDATE
					 OR
					 labbdate IS NULL)
					AND
					labedate >= SYSDATE
					AND
					vsnhi.nhitype = '07';
				IF v_cnt = 0 THEN
					v_pfopfg_flag := 'N';
				ELSE
					v_pfopfg_flag := 'Y';
				END IF;
			END IF;

      --手術加成
			IF v_pfopfg_flag = 'Y' THEN
        --以下項目材料費內含 80011890 add by kuo 1000525
        --add 80005349 new item by kuo 1010726
        --add 80010407 new item by kuo 1030811
        --add 72309010 new item by kuo 1040128
				IF ppfkey IN (
					'80004399',
					'50004106',
					'80011890',
					'80005349',
					'80010407',
					'72309010'
				) THEN
					pemgper := pemgper;
				ELSE
					IF pfeekind <> '08' THEN
						pemgper := pemgper + 0.53;
					END IF;
				END IF;
        --特殊加成 by kuo 20140822
        --因應加成為1+加成數，所以PF_RATEDTL 除了 747開頭外的計價碼都減0.53 by kuo 20141030
				OPEN get_or_emper (ppfkey);
				FETCH get_or_emper INTO or_emper;
				IF get_or_emper%found THEN
					pemgper := pemgper + or_emper;
				END IF;
				CLOSE get_or_emper;

        --眼科特殊加成 by kuo 20140731, 生效日20140801(給的時間真是緊啊...還剩半天)
        --個碼再加成:
        --80010353:1.08
        --80010161:1.00
        --80010408:0.67
        --80010409:0.82
        --80010410:0.53
        --80010192:1.25
        --80010193,80010197:1.25
        --80010411:1.79
        --80010412:1.75
        --80010413:1.68
        --80010414:1.54
        --80010415:1.94
        --80010416:2.35
        --80010417:1.89
        --以下作廢 by kuo 20140822
        /*
        IF pbldate >= to_date('20140801','YYYYMMDD') THEN
            IF PPFKEY IN ('80010192', '80010193', '80010197') THEN
               pEmgPer := pEmgPer + 1.25;
            END IF;
            IF PPFKEY='80010353' THEN
               pEmgPer := pEmgPer + 1.08;
            END IF;
            IF PPFKEY='80010161' THEN
               PEMGPER := PEMGPER + 1;
            END IF;
            IF PPFKEY='80010408' THEN
               PEMGPER := PEMGPER + 0.67;
            END IF;
            IF PPFKEY='80010409' THEN
               PEMGPER := PEMGPER + 0.82;
            END IF;
            IF PPFKEY='80010410' THEN
               PEMGPER := PEMGPER + 0.53;
            END IF;
            IF PPFKEY='80010411' THEN
               PEMGPER := PEMGPER + 1.79;
            END IF;
            IF PPFKEY='80010412' THEN
               PEMGPER := PEMGPER + 1.75;
            END IF;
            IF PPFKEY='80010413' THEN
               PEMGPER := PEMGPER + 1.68;
            END IF;
            IF PPFKEY='80010414' THEN
               PEMGPER := PEMGPER + 1.54;
            END IF;
            IF PPFKEY='80010415' THEN
               PEMGPER := PEMGPER + 1.94;
            END IF;
            IF PPFKEY='80010416' THEN
               PEMGPER := PEMGPER + 2.35;
            END IF;
            IF PPFKEY='80010417' THEN
               PEMGPER := PEMGPER + 1.89;
            END IF;
        END IF;
        */
        --以上作廢 by kuo 20140822
			END IF;
			IF ptype = '2' THEN
				RETURN pemgper;
			END IF;

      --麻醉加成
			IF pfeekind = '09' OR v_nh_type = '11' THEN
				CASE
					WHEN pemgflag = 'C' THEN
						pemgper := pemgper + 0.2;
					WHEN pemgflag IN (
						'D',
						'L'
					) THEN
						pemgper := pemgper + 0.3;
					WHEN pemgflag IN (
						'A',
						'E',
						'I'
					) THEN
						pemgper := pemgper + 0.5;
					WHEN pemgflag = 'J' THEN
						pemgper := pemgper + 0.6;
					WHEN pemgflag = 'B' THEN
						pemgper := pemgper + 0.7;
					WHEN pemgflag IN (
						'G',
						'K'
					) THEN
						pemgper := pemgper + 0.8;
					WHEN pemgflag = 'H' THEN
						pemgper := pemgper + 1;
					ELSE
						pemgper := pemgper;
				END CASE;
			END IF;

      --加重兒童加成與加成 by kuo 20160824 從20160901開始生效
			IF pbldate >= TO_DATE ('20160901', 'YYYYMMDD') THEN
         --dbpfile 未設定兒童加乘金額者,無兒童加乘,多判斷VSNHI裡面要有兒童加成才行 by kuo 20160824
				IF v_pf_child_pay > 0 AND v_pf_child_pay IS NOT NULL AND vnh_child = 'Y' THEN
            --兒童加成(6歲以下)
					IF v_child_flag_1 = 'Y' THEN
						pemgper := pemgper + 0.2;
					END IF;
            --兒童加成(2歲以下)
					IF v_child_flag_2 = 'Y' THEN
						pemgper := pemgper + 0.3;
					END IF;
            --兒童加成(六個月以下)
					IF v_child_flag_3 = 'Y' THEN
						pemgper := pemgper + 0.6;
					END IF;
				ELSE
            --六個月以下,手術加成60
					IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') THEN
						pemgper := pemgper + 0.6;
					END IF;
				END IF;
         --兒童加重加成 20160901 移至這裡計算 by kuo 20160824
				IF vnh_lbchild = 'Y' THEN
             --兒童加成(6歲以下)
					IF v_child_flag_1 = 'Y' THEN
						pemgper := pemgper + 0.6;
					END IF;
            --兒童加成(2歲以下)
					IF v_child_flag_2 = 'Y' THEN
						pemgper := pemgper + 0.8;
					END IF;
            --兒童加成(六個月以下)
					IF v_child_flag_3 = 'Y' THEN
						pemgper := pemgper + 1;
					END IF;
				END IF;
			ELSE 
         --dbpfile 未設定兒童加乘金額者,無兒童加乘
				IF v_pf_child_pay > 0 AND v_pf_child_pay IS NOT NULL THEN
					IF v_child_flag_1 = 'Y' THEN
              --兒童加成(6歲以下)
						pemgper := pemgper + 0.2;
					ELSIF v_child_flag_2 = 'Y' THEN
              --兒童加成(2歲以下)
						pemgper := pemgper + 0.3;
					ELSIF v_child_flag_3 = 'Y' THEN
              --兒童加成(六個月以下)
						pemgper := pemgper + 0.6;
					END IF;
				ELSE
           --六個月以下,手術加成60
					IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') THEN
						pemgper := pemgper + 0.6;
					END IF;
				END IF;
			END IF;
      /*
      --dbpfile 未設定兒童加乘金額者,無兒童加乘
      IF V_PF_CHILD_PAY > 0 AND V_PF_CHILD_PAY IS NOT NULL THEN

        IF v_child_flag_1 = 'Y' THEN
          --兒童加成(6歲以下)
          pEmgPer := pEmgPer + 0.2;
        ELSIF v_child_flag_2 = 'Y' THEN
          --兒童加成(2歲以下)
          pEmgPer := pEmgPer + 0.3;
        ELSIF v_child_flag_3 = 'Y' THEN
          --兒童加成(六個月以下)
          pEmgPer := pEmgPer + 0.6;
        END IF;
      ELSE
        --六個月以下,手術加成60
        IF v_child_flag_3 = 'Y' AND
           (pFeeKind = '07' OR pFeeKind = '08' OR v_pfopfg_flag = 'Y') THEN
          pEmgPer := pEmgPer + 0.6;
        END IF;
      END IF;
      */
      --以下急作成數為固定成數
			IF pfeekind = '11' THEN
        --手材併入手術主項不另列
				pemgper := 0;
			ELSIF pfeekind = '12' THEN
        --麻材
				pemgper := 0.5;
			ELSIF pfeekind = '13' THEN
        --手材
				pemgper := 0.53;
			ELSIF pfeekind = '18' THEN
        --治療處理
        --配合99/01/08健保局0994050093號函「全民健保費用支付標準」
        --自99/6/1起實施，年齡小於84個月，以下2碼加成30%、37%，實際修改日期99/7/1        
				IF (v_yy < 7) THEN
          --年齡小於七歲
					IF (bilrootrec.admit_date >= TO_DATE ('2010/07/01', 'yyyy/mm/dd')) THEN
            --狀況不明，無人承認規則，先拿掉 by kuo 20150924
            --IF pPFkey IN ('74700256') THEN
            --  pEmgPer := pEmgPer + 0.3;
            --END IF;
            --狀況不明，無人承認規則，先拿掉 by kuo 20150924
            --IF pPFkey IN ('74700371') THEN
            --  PEMGPER := PEMGPER + 0.37;
            --END IF;
						NULL;
					END IF;
				END IF;
			END IF;
		ELSE
			pemgper := 1;
			IF pfeekind = '11' THEN
        --手材併入手術主項不另列
				pemgper := 0;
			ELSIF pfeekind = '12' THEN
        --麻材
				pemgper := 0.5;
			ELSIF pfeekind = '13' THEN
        --手材
				pemgper := 0.53;
			ELSIF pfeekind = '18' THEN
        --治療處理
        --配合99/01/08健保局0994050093號函「全民健保費用支付標準」
        --自99/6/1起實施，年齡小於84個月，以下2碼加成30%、37%，實際修改日期99/7/1        
				IF (v_yy < 7) THEN
          --年齡小於七歲
					IF (bilrootrec.admit_date >= TO_DATE ('2010/07/01', 'yyyy/mm/dd')) THEN
            --狀況不明，無人承認規則，先拿掉 by kuo 20150924
            --IF pPFkey IN ('74700256') THEN
            --  pEmgPer := pEmgPer + 0.3;
            --END IF;
            --狀況不明，無人承認規則，先拿掉 by kuo 20150924
            --IF pPFkey IN ('74700371') THEN
            --  PEMGPER := PEMGPER + 0.37;
            --END IF;
						NULL;
					END IF;
				END IF;
			END IF;
		END IF;
		CLOSE cur_1;
		RETURN pemgper;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --調整應收帳款
	PROCEDURE p_receivablecomp (
		pcaseno VARCHAR2
	) IS
    --取出應收帳款調整主檔
		CURSOR cur_mst IS
		SELECT
			*
		FROM
			bil_adjst_mst
		WHERE
			bil_adjst_mst.caseno = pcaseno
		ORDER BY
			bil_adjst_mst.last_update_date;
		CURSOR cur_mst1 IS
		SELECT
			*
		FROM
			bil_adjst_mst
		WHERE
			bil_adjst_mst.donee_caseno = pcaseno
		ORDER BY
			bil_adjst_mst.last_update_date;

    --取出有被調整到的類別
		CURSOR cur_dtl (
			padjstseqno VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_adjst_dtl
		WHERE
			bil_adjst_dtl.adjst_seqno = padjstseqno
			AND
			bil_adjst_dtl.fee_kind BETWEEN '01' AND '43'
			AND
			bil_adjst_dtl.after_to_amt <> 0;
		biladjstmstrec      bil_adjst_mst%rowtype;
		biladjstdtlrec      bil_adjst_dtl%rowtype;
		bilfeedtlrec        bil_feedtl%rowtype;
		bilfeemstrec        bil_feemst%rowtype;
		bilfeemstrecdonee   bil_feemst%rowtype;
		bilfeedtlrecdonee   bil_feedtl%rowtype;
    --錯誤訊息用途
		v_program_name      VARCHAR2 (80);
		v_session_id        NUMBER (10);
		v_error_code        VARCHAR2 (20);
		v_error_msg         VARCHAR2 (400);
		v_error_info        VARCHAR2 (600);
		v_source_seq        VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.p_receivableComp';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		SELECT
			*
		INTO bilfeemstrec
		FROM
			bil_feemst
		WHERE
			bil_feemst.caseno = pcaseno;

    --取出該病患應收帳款調整檔資料
		OPEN cur_mst;
		LOOP
			FETCH cur_mst INTO biladjstmstrec;
			EXIT WHEN cur_mst%notfound;
			OPEN cur_dtl (biladjstmstrec.adjst_seqno);
			LOOP
				FETCH cur_dtl INTO biladjstdtlrec;
				EXIT WHEN cur_dtl%notfound;
				biladjstmstrec.blfrunit := rtrim (ltrim (biladjstmstrec.blfrunit));
        --取出原有類別資料
				BEGIN
					SELECT
						*
					INTO bilfeedtlrec
					FROM
						bil_feedtl
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = TRIM (biladjstdtlrec.fee_kind)
						AND
						bil_feedtl.pfincode = biladjstmstrec.blfrunit;
					UPDATE bil_feedtl
					SET
						bil_feedtl.total_amt = bil_feedtl.total_amt - biladjstdtlrec.after_to_amt
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = biladjstdtlrec.fee_kind
						AND
						bil_feedtl.pfincode = biladjstmstrec.blfrunit;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
				IF biladjstmstrec.blfrunit = 'CIVC' THEN
					IF biladjstdtlrec.fee_kind BETWEEN '41' AND '43' THEN
						bilfeemstrec.tot_self_amt := bilfeemstrec.tot_self_amt - biladjstdtlrec.after_to_amt;
						UPDATE bil_feemst
						SET
							bil_feemst.tot_self_amt = bilfeemstrec.tot_self_amt
						WHERE
							bil_feemst.caseno = pcaseno;
					ELSE
						bilfeemstrec.tot_gl_amt := bilfeemstrec.tot_gl_amt - biladjstdtlrec.after_to_amt;
						UPDATE bil_feemst
						SET
							bil_feemst.tot_gl_amt = bilfeemstrec.tot_gl_amt
						WHERE
							bil_feemst.caseno = pcaseno;
					END IF;
				ELSE
					bilfeemstrec.credit_amt := nvl (bilfeemstrec.credit_amt, 0) - biladjstdtlrec.after_to_amt;
					UPDATE bil_feemst
					SET
						bil_feemst.credit_amt = bilfeemstrec.credit_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				END IF;

        --取出新身份別的資料,修改金額
				BEGIN
					SELECT
						*
					INTO bilfeedtlrec
					FROM
						bil_feedtl
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = biladjstdtlrec.fee_kind
						AND
						bil_feedtl.pfincode = biladjstmstrec.bltounit;
					bilfeedtlrec.total_amt := bilfeedtlrec.total_amt + biladjstdtlrec.after_to_amt;
					UPDATE bil_feedtl
					SET
						bil_feedtl.total_amt = bilfeedtlrec.total_amt
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = biladjstdtlrec.fee_kind
						AND
						bil_feedtl.pfincode = biladjstmstrec.bltounit;
				EXCEPTION
          --無資料則新增一筆
					WHEN no_data_found THEN
						bilfeedtlrec.caseno      := pcaseno;
						bilfeedtlrec.fee_type    := biladjstdtlrec.fee_kind;
						bilfeedtlrec.pfincode    := biladjstmstrec.bltounit;
						bilfeedtlrec.total_amt   := biladjstdtlrec.after_to_amt;
						INSERT INTO bil_feedtl VALUES bilfeedtlrec;
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
				IF biladjstmstrec.bltounit = 'CIVC' THEN
					bilfeemstrec.tot_gl_amt := bilfeemstrec.tot_gl_amt + biladjstdtlrec.after_to_amt;
					UPDATE bil_feemst
					SET
						bil_feemst.tot_gl_amt = bilfeemstrec.tot_gl_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				ELSE
					bilfeemstrec.credit_amt := bilfeemstrec.credit_amt + biladjstdtlrec.after_to_amt;
					UPDATE bil_feemst
					SET
						bil_feemst.credit_amt = bilfeemstrec.credit_amt
					WHERE
						bil_feemst.caseno = pcaseno;
				END IF;
			END LOOP;
			CLOSE cur_dtl;
		END LOOP;
		CLOSE cur_mst;

    --取出該病患應收帳款調整檔資料
		OPEN cur_mst1;
		LOOP
			FETCH cur_mst1 INTO biladjstmstrec;
			EXIT WHEN cur_mst1%notfound;
			IF biladjstmstrec.bltounit = 'TRAN' THEN
				SELECT
					*
				INTO bilfeemstrecdonee
				FROM
					bil_feemst
				WHERE
					bil_feemst.caseno = biladjstmstrec.donee_caseno;
			END IF;
			OPEN cur_dtl (biladjstmstrec.adjst_seqno);
			LOOP
				FETCH cur_dtl INTO biladjstdtlrec;
				EXIT WHEN cur_dtl%notfound;

        --如調整之分攤單位別為器官移植
				IF biladjstmstrec.bltounit = 'TRAN' THEN
					IF biladjstmstrec.blfrunit = 'CIVC' THEN
						bilfeemstrecdonee.tot_gl_amt := bilfeemstrecdonee.tot_gl_amt + biladjstdtlrec.after_to_amt;
					ELSE
						bilfeemstrecdonee.credit_amt := nvl (bilfeemstrecdonee.credit_amt, 0) + biladjstdtlrec.after_to_amt;
					END IF;
					BEGIN
						SELECT
							*
						INTO bilfeedtlrecdonee
						FROM
							bil_feedtl
						WHERE
							bil_feedtl.caseno = biladjstmstrec.donee_caseno
							AND
							bil_feedtl.pfincode = biladjstmstrec.blfrunit
							AND
							bil_feedtl.fee_type = '44';
						UPDATE bil_feedtl
						SET
							total_amt = total_amt + biladjstdtlrec.after_to_amt
						WHERE
							bil_feedtl.caseno = biladjstmstrec.donee_caseno
							AND
							bil_feedtl.pfincode = biladjstmstrec.blfrunit
							AND
							bil_feedtl.fee_type = '44';
					EXCEPTION
						WHEN no_data_found THEN
							bilfeedtlrecdonee.caseno             := biladjstmstrec.donee_caseno;
							bilfeedtlrecdonee.fee_type           := '44';
							bilfeedtlrecdonee.pfincode           := biladjstmstrec.blfrunit;
							bilfeedtlrecdonee.total_amt          := biladjstdtlrec.after_to_amt;
							bilfeedtlrecdonee.created_by         := biladjstmstrec.last_updated_by;
							bilfeedtlrecdonee.creation_date      := biladjstmstrec.last_update_date;
							bilfeedtlrecdonee.last_updated_by    := biladjstmstrec.last_updated_by;
							bilfeedtlrecdonee.last_update_date   := SYSDATE;
							INSERT INTO bil_feedtl VALUES bilfeedtlrecdonee;
					END;
				END IF;
			END LOOP;
			CLOSE cur_dtl;
			UPDATE bil_feemst
			SET
				bil_feemst.tot_gl_amt = bilfeemstrecdonee.tot_gl_amt,
				bil_feemst.credit_amt = bilfeemstrecdonee.credit_amt
			WHERE
				bil_feemst.caseno = biladjstmstrec.donee_caseno;
		END LOOP;
		CLOSE cur_mst1;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

/*   --榮民資料檔優待身份別處理
	PROCEDURE p_disfin (
		pcaseno    VARCHAR2,
		pfinacl    VARCHAR2,
		pdiscfin   OUT VARCHAR2
	) IS
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_hvtfincl       VARCHAR2 (01);
		v_hvtrnkcd       VARCHAR2 (02);
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			common.pat_adm_vtan_rec
		WHERE
			common.pat_adm_vtan_rec.hcaseno = pcaseno
		ORDER BY
			common.pat_adm_vtan_rec.hfindate DESC,
			common.pat_adm_vtan_rec.hfininf DESC;
		patadmvtanrec    common.pat_adm_vtan_rec%rowtype;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.p_disfin';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		IF pfinacl = 'VTAN' THEN
			OPEN cur_1;
			FETCH cur_1 INTO patadmvtanrec;
			IF cur_1%notfound THEN
        --確認是否榮民資料檔有資料
				pdiscfin := pfinacl;
				return;
			ELSE
				v_hvtfincl   := patadmvtanrec.hvtfincl; --有/無職榮
				v_hvtrnkcd   := patadmvtanrec.hvtrnkcd; --階級
				IF v_hvtfincl = '1' THEN
          --無職榮

          --將官
          --IF v_hvtrnkcd IN ('01','02') THEN
          --pDiscFin := 'VTAM';
          --ELSE
					pdiscfin := pfinacl;
          --END IF ;
				ELSIF v_hvtfincl = '2' THEN
          --有職榮
					IF v_hvtrnkcd IN (
						'01',
						'02'
					) THEN
            --將官 (03 少將無優待 BY KUO
						pdiscfin := 'VTAM';
            --上校
					ELSIF v_hvtrnkcd = '04' THEN
						pdiscfin := 'VT04';
            --校級
					ELSIF v_hvtrnkcd IN (
						'05',
						'06'
					) THEN
						pdiscfin := 'VT05';
            --尉級
					ELSIF v_hvtrnkcd IN (
						'07',
						'08',
						'09',
						'10'
					) THEN
						pdiscfin := 'VT07';
            --士官兵
					ELSIF v_hvtrnkcd IN (
						'11',
						'12',
						'13',
						'14',
						'15',
						'16',
						'17',
						'18'
					) THEN
						pdiscfin := 'VT11';
            --2010/5/17修改為，有職榮無階級沒有優減
            --ELSE
            --    pDiscFin := 'VT04';--以最高計
					END IF;
          --00於20160116開始與 11 相同 request by 姬小姐 by kuo 20160323
					IF v_hvtrnkcd IN (
						'00'
					) AND patadmvtanrec.hfindate >= '20160116' THEN
						pdiscfin := 'VT11';
					END IF;
				ELSE
					pdiscfin := 'VTAN';
				END IF;
			END IF;
			CLOSE cur_1;
		ELSE
			pdiscfin := pfinacl;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END; */
	  --榮民資料檔優待身份別處理
	PROCEDURE get_discfin (
		i_hcaseno   VARCHAR2,
		i_pfinacl   VARCHAR2,
		o_discfin   OUT VARCHAR2
	) IS
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
		l_hvtfincl            VARCHAR2 (01);
		l_hvtrnkcd            VARCHAR2 (02);
	BEGIN
		IF i_pfinacl = 'VTAN' THEN
			FOR r_pat_adm_vtan_rec IN (
				SELECT
					*
				FROM
					common.pat_adm_vtan_rec
				WHERE
					hcaseno = i_hcaseno
				ORDER BY
					hfindate DESC,
					hfininf DESC
			) LOOP
				l_hvtfincl   := r_pat_adm_vtan_rec.hvtfincl; --有/無職榮
				l_hvtrnkcd   := r_pat_adm_vtan_rec.hvtrnkcd; --階級
				--有職榮
				IF l_hvtfincl = '2' THEN
					o_discfin := 'VT' || l_hvtrnkcd;
				ELSE
					--1無職榮, 3榮民遺眷
					o_discfin := i_pfinacl;
				END IF;
			END LOOP;
			IF l_hvtfincl IS NULL THEN
				--榮民資料檔無資料
				o_discfin := i_pfinacl;
			END IF;
		ELSE
			o_discfin := i_pfinacl;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'get_discfin';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_hcaseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
	END;

  --新生兒健保內含項check
	FUNCTION f_checkbabynh (
		ppfkey VARCHAR2
	) RETURN VARCHAR2 IS
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.f_CheckBabyNH';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := ppfkey;
		IF ppfkey IN (
			'60204000',
			'74770148',
			'74700317',
			'74700256',
			'60204001',
			'60204002',
			'60204001',
			'74711016',
			'74701066',
			'74712141',
			'74700023',
			'74770862',
			'60204000',
			'90414101',
			'74701263',
			'74701088',
			'90223002',
			'90414101',
			'74700125',
			'006AK240',
			'PHAR3BR',
			'DIAG3BR',
			'WARD3BR'
		) THEN
			RETURN 'Y';
		ELSE
			RETURN 'N';
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := ppfkey;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;
	FUNCTION f_checkbabyflag (
		pcaseno   VARCHAR2,
		pdate     DATE
	) RETURN VARCHAR2 IS
		bilrootrec       bil_root%rowtype;
		v_babyflag       VARCHAR2 (01);
		v_babyselfdate   DATE;
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.f_checkBabyFlag';
		v_session_id     := userenv ('SESSIONID');
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			bil_root.caseno = pcaseno;

    --母嬰關係 CHECK 是否有母親的住院號,有者,健保帳合併於母親申報
		IF TRIM (bilrootrec.hmrcase) IS NOT NULL AND bilrootrec.hmrcase <> 'N' AND bilrootrec.hfinacl = 'CIVC' THEN
      --新生兒
			v_babyflag := 'Y';
      --以新生兒自付設定切割健保/自付日期區間
			BEGIN
        --抓出自費起始日期
				SELECT
					bil_baby_set.effective_date
				INTO v_babyselfdate
				FROM
					bil_baby_set
				WHERE
					bil_baby_set.caseno = pcaseno;
			EXCEPTION
				WHEN OTHERS THEN
					v_babyselfdate := SYSDATE;
			END;
		ELSE
			v_babyflag       := 'N';
			v_babyselfdate   := NULL;
		END IF;
		IF v_babyflag = 'Y' AND trunc (pdate) <= trunc (v_babyselfdate) THEN
			RETURN 'Y';
		ELSE
			RETURN 'N';
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --健保規則調整
	PROCEDURE p_transnhrule (
		pcaseno VARCHAR2
	) IS
    --抓出有在規則轉換設定中有資料的主項健保碼
		CURSOR cur_1 IS
		SELECT
			bil_nhrule_set.ins_fee_code1
		FROM
			bil_acnt_wk,
			bil_nhrule_set
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.ins_fee_code LIKE bil_nhrule_set.ins_fee_code1 || '%'
			AND
			length (bil_acnt_wk.ins_fee_code) <= 7
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.insu_amt > 0
		GROUP BY
			bil_nhrule_set.ins_fee_code1;

    --再傳入符合主項健保碼之相關規定
		CURSOR cur_2 (
			pinsfeecode VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_nhrule_set
		WHERE
			bil_nhrule_set.ins_fee_code1 = pinsfeecode;

    --抓出符合該項規定的明細帳
    --因應規則取消,bil_nhrule_setru8 加入end_date判斷 by kuo 20140205
		CURSOR cur_3_1 (
			pinsfeecode   VARCHAR2,
			vbedin_date   DATE,
			vend_date     DATE
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			length (bil_acnt_wk.ins_fee_code) <= 7
			AND
			bil_acnt_wk.ins_fee_code LIKE pinsfeecode || '%'
			AND
			bildate BETWEEN vbedin_date AND vend_date;
		CURSOR cur_3 (
			pinsfeecode VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			length (bil_acnt_wk.ins_fee_code) <= 7
			AND
			bil_acnt_wk.ins_fee_code LIKE pinsfeecode || '%';

    --抓出每日帳款筆數
		CURSOR cur_4 (
			pinsfeecode VARCHAR2
		) IS
		SELECT
			bil_acnt_wk.start_date
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.ins_fee_code LIKE pinsfeecode || '%'
			AND
			length (bil_acnt_wk.ins_fee_code) <= 7
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			bil_acnt_wk.self_flag = 'N'
		GROUP BY
			bil_acnt_wk.start_date;
		CURSOR cur_5 (
			pinsfeecode   VARCHAR2,
			pdate         DATE
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.ins_fee_code LIKE pinsfeecode || '%'
			AND
			length (bil_acnt_wk.ins_fee_code) <= 7
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			bil_acnt_wk.start_date = pdate;

    --6.過濾手術類別(07)同日之換藥48011C,48012C,48013C,CASEPAYMENT除外不過濾
		CURSOR cur_6 IS
		SELECT
			bil_acnt_wk.*
		FROM
			bil_acnt_wk,
			bil_root
		WHERE
			bil_root.caseno = pcaseno
			AND
			rtrim (bil_root.drg_code) <> '000'
			AND
			bil_root.drg_code IS NULL
			AND
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			bil_acnt_wk.ins_fee_code IN (
				'48011C',
				'48012C',
				'48013C'
			);

    --7.每日33046B2次轉33088B,三次以上轉成33089B
		CURSOR cur_7 IS
		SELECT
			bil_acnt_wk.start_date,
			COUNT (*)
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.ins_fee_code = '33046B'
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.insu_amt > 0
		GROUP BY
			bil_acnt_wk.start_date
		HAVING
			COUNT (*) >= 2;
		CURSOR cur_7_1 (
			pstartdate DATE
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.start_date = pstartdate
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			bil_acnt_wk.ins_fee_code = '33046B';

    --8.取出所有單價>30000的衛材
		CURSOR cur_8 IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.nh_type = '12'
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			bil_acnt_wk.insu_amt >= 30000;

    --9.尿常規申報規則(按天計)
		CURSOR cur_9 IS
		SELECT
			bil_acnt_wk.start_date,
			SUM (bil_acnt_wk.qty * bil_acnt_wk.emg_per * bil_acnt_wk.insu_amt)
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.ins_fee_code BETWEEN '06001C' AND '06017B'
		GROUP BY
			bil_acnt_wk.start_date
		HAVING
			SUM (bil_acnt_wk.qty * bil_acnt_wk.emg_per * bil_acnt_wk.insu_amt) >= 75;
		CURSOR cur_9_1 (
			pstartdate DATE
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.start_date = pstartdate
			AND
			bil_acnt_wk.self_flag = 'N'
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			bil_acnt_wk.ins_fee_code BETWEEN '06001C' AND '06017B';

    --10.血液常規併項修正(同日)
		CURSOR cur_10 IS
		SELECT
			start_date
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			bil_acnt_wk.ins_fee_code = '08001C'
		GROUP BY
			start_date;
		CURSOR cur_10_1 (
			pstartdate    DATE,
			pinsfeecode   VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.start_date = pstartdate
			AND
			bil_acnt_wk.insu_amt > 0
			AND
			bil_acnt_wk.ins_fee_code = pinsfeecode;
		CURSOR cur_14 IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.ins_fee_code IN (
				'32001C',
				'32007C',
				'32009C',
				'32011C',
				'32013C',
				'32015C',
				'32017C',
				'32022C'
			);

    --刪除新生兒內含
		CURSOR cur_12 IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.part_amt <> 0
			AND
			f_checkbabyflag (bil_acnt_wk.caseno, bil_acnt_wk.start_date) = 'Y'
			AND
			(bil_acnt_wk.price_code IN (
				'60204000',
				'74770148',
				'74700317',
				'74700256',
				'74711016',
				'74701066',
				'74712141',
				'74700023',
				'74770862',
				'60204001',
				'60204002',
				'60204003',
				'74701263',
				'74701088',
				'90223002',
				'90414101',
				'74700125',
				'006AK240'
			));

    --最後一天管灌伙食
		CURSOR cur_13 (
			pdate DATE
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.start_date = pdate
			AND
			bil_acnt_wk.insu_amt <> 0
			AND
			(bil_acnt_wk.ins_fee_code IN (
				'05101B',
				'05102B',
				'05103A',
				'05104A',
				'05105A',
				'05106A',
				'05107A'
			));
		CURSOR cur_15 IS
		SELECT
			bil_acnt_wk.start_date
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.fee_kind = '02'
			AND
			bil_acnt_wk.self_amt > 0
			AND
			bil_acnt_wk.start_date >= TO_DATE ('2008/01/01', 'yyyy/mm/dd')
			AND
			bil_acnt_wk.price_code NOT IN (
				SELECT
					pfkey
				FROM
					pfclass
				WHERE
					substr (pfkey, 1, 4) = 'DIET'
					AND
					pfincode = 'LABI'
					AND
					pfreqpay > 0
			)
		GROUP BY
			start_date;
		CURSOR cur_16 (
			pdate DATE
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.fee_kind = '02'
			AND
			bil_acnt_wk.start_date = pdate
			AND
			bil_acnt_wk.self_amt > 0
			AND
			bil_acnt_wk.price_code NOT IN (
				SELECT
					pfkey
				FROM
					pfclass
				WHERE
					substr (pfkey, 1, 4) = 'DIET'
					AND
					pfincode = 'LABI'
					AND
					pfreqpay > 0
			);
		bilnhrulesetrec   bil_nhrule_set%rowtype;
		bilacntwkrec      bil_acnt_wk%rowtype;
		v_ins_fee_code    VARCHAR2 (20);
		v_cnt             INTEGER;
		v_qty             INTEGER;
		v_qty1            INTEGER;
		v_qty2            INTEGER;
		v_start_date      DATE;
		v_amt             NUMBER (10, 2);
		v_first           VARCHAR2 (01) := 'Y';
		bilrootrec        bil_root%rowtype;
		bilfeemstrec      bil_feemst%rowtype;
		vsnhirec          vsnhi%rowtype;
		v_dischg_date     DATE;
		v_qty_1           INTEGER;
		bilfeedtlrec      bil_feedtl%rowtype;
		patadmcaserec     common.pat_adm_case%rowtype;
		v_tb_days         INTEGER;
		v_days            INTEGER;
		v_insu_amt        NUMBER;
		v_nhi2date_s      VARCHAR2 (10);
		v_nhi2date_e      VARCHAR2 (10);
		v_nhi2_flag       NUMBER;
    --錯誤訊息用途
		v_program_name    VARCHAR2 (80);
		v_session_id      NUMBER (10);
		v_error_code      VARCHAR2 (20);
		v_error_msg       VARCHAR2 (400);
		v_error_info      VARCHAR2 (600);
		v_source_seq      VARCHAR2 (20);
		drgcode           VARCHAR2 (03);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.p_TransNHRule';
		v_session_id     := userenv ('SESSIONID');

    --2007/11/21 會議決議帳務部份暫不處理此項規則
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			bil_root.caseno = pcaseno;
		drgcode          := bilrootrec.drg_code;
		SELECT
			*
		INTO patadmcaserec
		FROM
			common.pat_adm_case
		WHERE
			common.pat_adm_case.hcaseno = pcaseno;

    --6.過濾手術類別(07)同日之換藥48011C,48012C,48013C,CASEPAYMENT除外不過濾
		OPEN cur_6;
		LOOP
			FETCH cur_6 INTO bilacntwkrec;
			EXIT WHEN cur_6%notfound;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				bil_acnt_wk
			WHERE
				bil_acnt_wk.caseno = pcaseno
				AND
				bil_acnt_wk.start_date = bilacntwkrec.start_date
				AND
				bil_acnt_wk.fee_kind = '07';

      --同一時有手術
			IF v_cnt > 0 THEN
				p_deleteacntwk (pcaseno, bilacntwkrec.acnt_seq, '每日有手術項,故不得申報本項');
			END IF;
		END LOOP;
		CLOSE cur_6;

    --7.每日33046B2次轉33088B,三次以上轉成33089B
		OPEN cur_7;
		LOOP
			FETCH cur_7 INTO
				v_start_date,
				v_cnt;
			EXIT WHEN cur_7%notfound;

      --33046B=2 轉成33088B
			IF v_cnt = 2 THEN
				v_first := 'Y';
				OPEN cur_7_1 (v_start_date);
				LOOP
					FETCH cur_7_1 INTO bilacntwkrec;
					EXIT WHEN cur_7_1%notfound;
					IF v_first = 'Y' THEN
						p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '33088B', pdeletereason => '每日33076B 二次轉成33088B'
						);
						v_first := 'N';
					END IF;

          --reset qty values ,就不會再insert 一次了...
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '每日33076B 二次轉成33088B');
				END LOOP;
				CLOSE cur_7_1;

        --33076B > 2 轉成33089B
			ELSE
        --reset qty values ,就不會再insert 一次了...
				v_first := 'Y';
				OPEN cur_7_1 (v_start_date);
				LOOP
					FETCH cur_7_1 INTO bilacntwkrec;
					EXIT WHEN cur_7_1%notfound;
					IF v_first = 'Y' THEN
						p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '33089B', pdeletereason => '每日33076B 超過二次轉成33089B'
						);
						v_first := 'N';
					END IF;
          --reset qty values ,就不會再insert 一次了...
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '每日33076B 超過二次轉成33089B');
				END LOOP;
				CLOSE cur_7_1;
			END IF;
		END LOOP;
		CLOSE cur_7;

    --8.衛材金額大於三萬,管理費上限1500
    --在院或是離院日期大於20120724就不算,BY KUO 20120724 ,補給室逸婷 20120724
		IF bilrootrec.dischg_date IS NULL OR bilrootrec.dischg_date > TO_DATE ('20120724', 'YYYYMMDD') THEN
			NULL;
		ELSE
			OPEN cur_8;
			LOOP
				FETCH cur_8 INTO bilacntwkrec;
				EXIT WHEN cur_8%notfound;
				p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => 'MA12345678NH', pdeletereason => '材料管理費上限1500'
				);
			END LOOP;
			CLOSE cur_8;
		END IF;
    --9.尿常規申報規則(按天計)
    --如有06009C則以06012C,無則以06013c報
		OPEN cur_9;
		LOOP
			FETCH cur_9 INTO
				v_start_date,
				v_amt;
			EXIT WHEN cur_9%notfound;

      --如有06009C則以06012C,無則以06013c報
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				bil_acnt_wk
			WHERE
				bil_acnt_wk.caseno = pcaseno
				AND
				bil_acnt_wk.start_date = v_start_date
				AND
				bil_acnt_wk.ins_fee_code = '06009C';
			IF v_cnt > 0 THEN
				v_ins_fee_code := '06012C';
			ELSE
				v_ins_fee_code := '06013C';
			END IF;
			v_first := 'Y';
			OPEN cur_9_1 (v_start_date);
			LOOP
				FETCH cur_9_1 INTO bilacntwkrec;
				EXIT WHEN cur_9_1%notfound;
				IF v_first = 'Y' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '06012C', pdeletereason => '尿液常規申報規則轉'
					|| v_ins_fee_code);
					v_first := 'N';
				END IF;
        --reset qty values ,就不會再insert 一次了...
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉' || v_ins_fee_code);
			END LOOP;
			CLOSE cur_9_1;
		END LOOP;
		CLOSE cur_9;

    --10.血液常規併項修正(同日)
    --先抓出有作08001C的天數(最基本的,沒有就不符合這個規則)
		OPEN cur_10;
		LOOP
			FETCH cur_10 INTO v_start_date;
			EXIT WHEN cur_10%notfound;

      --check 是否有08002C
			OPEN cur_10_1 (v_start_date, '08002C');
			FETCH cur_10_1 INTO bilacntwkrec;
      --找不到就跳出回圈
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --check 是否有08003C
			OPEN cur_10_1 (v_start_date, '08003C');
			FETCH cur_10_1 INTO bilacntwkrec;
      --找不到就跳出回圈
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --check 是否有08004C
			OPEN cur_10_1 (v_start_date, '08004C');
			FETCH cur_10_1 INTO bilacntwkrec;
      --找不到就是 08001C+08002C+08003C都有,轉成08014C
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;

        --刪除08001C,08002C,08003C
				OPEN cur_10_1 (v_start_date, '08001C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08002C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08003C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
          --新增08014C
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '08014C', pdeletereason => '尿液常規申報規則轉08014C'
					);
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --check 是否有08127C
			OPEN cur_10_1 (v_start_date, '08127C');
			FETCH cur_10_1 INTO bilacntwkrec;
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;

        --刪除08001C,08002C,08003C
				OPEN cur_10_1 (v_start_date, '08001C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08002C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08003C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
          --新增08014C
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '08014C', pdeletereason => '尿液常規申報規則轉08014C'
					);
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --check 是否有08006C
			OPEN cur_10_1 (v_start_date, '08006C');
			FETCH cur_10_1 INTO bilacntwkrec;
      --找不到就是 08001C+08002C+08003C+08004C+08127C都有,轉成08012C
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
        --刪除08001C,08002C,08003C,08004C,08127C
				OPEN cur_10_1 (v_start_date, '08001C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08002C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08003C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08004C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08127C');
				FETCH cur_10_1 INTO bilacntwkrec;
				IF cur_10_1%found THEN
          --新增08012C
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '08012C', pdeletereason => '尿液常規申報規則轉08012C'
					);
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --通通都有
      --08001C+08002C+08003C+08004C+08127C+08006C都有,轉成08011C
      --刪除08001C,08002C,08003C,08004C,08127C,08006C
			OPEN cur_10_1 (v_start_date, '08001C');
			FETCH cur_10_1 INTO bilacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08002C');
			FETCH cur_10_1 INTO bilacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08003C');
			FETCH cur_10_1 INTO bilacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08004C');
			FETCH cur_10_1 INTO bilacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08127C');
			FETCH cur_10_1 INTO bilacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08006C');
			FETCH cur_10_1 INTO bilacntwkrec;
			IF cur_10_1%found THEN
        --新增08011C
				p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '08011C', pdeletereason => '尿液常規申報規則轉08011C'
				);
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
		END LOOP;
		CLOSE cur_10;

    --取得待合轉換設定檔的資料
		OPEN cur_1;
		LOOP
			FETCH cur_1 INTO v_ins_fee_code;
			EXIT WHEN cur_1%notfound;

      --取得該健保碼之明細規定
			OPEN cur_2 (v_ins_fee_code);
			LOOP
				FETCH cur_2 INTO bilnhrulesetrec;
				EXIT WHEN cur_2%notfound;

        --A項與B項不得同時申報
        --modify by kuo 20140205
				IF bilnhrulesetrec.rule_kind = '1' THEN
					OPEN cur_3_1 (v_ins_fee_code, bilnhrulesetrec.bedin_date, bilnhrulesetrec.end_date);
					LOOP
						FETCH cur_3_1 INTO bilacntwkrec;
						EXIT WHEN cur_3_1%notfound;
						IF bilnhrulesetrec.range_type = '1' THEN
              --SELECT COUNT(*)
              --應該看數量，非筆數 BY KUO 1000914
							SELECT
								SUM (bil_acnt_wk.qty)
							INTO v_cnt
							FROM
								bil_acnt_wk
							WHERE
								bil_acnt_wk.caseno = pcaseno
								AND
								bil_acnt_wk.ins_fee_code LIKE bilnhrulesetrec.ins_fee_code2 || '%'
								AND
								bil_acnt_wk.start_date = bilacntwkrec.start_date;
						ELSE
              --SELECT COUNT(*)
              --應該看數量，非筆數 BY KUO 1000914
							SELECT
								SUM (bil_acnt_wk.qty)
							INTO v_cnt
							FROM
								bil_acnt_wk
							WHERE
								bil_acnt_wk.caseno = pcaseno
								AND
								bil_acnt_wk.ins_fee_code LIKE bilnhrulesetrec.ins_fee_code2 || '%';
						END IF;

            --存在不得同時申報的B健保碼,故A不得申報
						IF v_cnt > 0 THEN
              --刪除A碼
              --移至轉換明細檔
              --調整金額回 bil_feemst/bil_feedtl
							p_deleteacntwk (pcaseno, bilacntwkrec.acnt_seq, '不得與' || bilnhrulesetrec.ins_fee_code2 || '同時申報');
						END IF;
					END LOOP;
					CLOSE cur_3_1;
				END IF;

        --限次數
				IF bilnhrulesetrec.rule_kind = '2' THEN
					v_qty := 0;
          --限日
					IF bilnhrulesetrec.range_type = '1' THEN
						OPEN cur_4 (v_ins_fee_code);
						LOOP
							FETCH cur_4 INTO v_start_date;
							EXIT WHEN cur_4%notfound;
							v_qty := 0;
              --取出所有符合的資料
							IF v_start_date <= TO_DATE ('20161018', 'YYYYMMDD') THEN
								OPEN cur_5 (v_ins_fee_code, v_start_date);
								LOOP
									FETCH cur_5 INTO bilacntwkrec;
									EXIT WHEN cur_5%notfound;
									v_qty := v_qty + bilacntwkrec.qty;
									IF v_qty > bilnhrulesetrec.qty THEN
										p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '超過每日限制次數');
									END IF;
								END LOOP;
								CLOSE cur_5;
							ELSE --考慮藥師費(05216)因為未來帳造成的重複需要拿掉要取消，由20161018以後開始 by kuo 20161017
								OPEN cur_5 (v_ins_fee_code, v_start_date);
								LOOP
									FETCH cur_5 INTO bilacntwkrec;
									EXIT WHEN cur_5%notfound;
									v_qty := v_qty + bilacntwkrec.qty;
								END LOOP;
								CLOSE cur_5;
								IF v_qty > bilnhrulesetrec.qty AND v_ins_fee_code <> '05216' THEN
									p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '超過每日限制次數');
								END IF;
							END IF;
						END LOOP;
						CLOSE cur_4;
					ELSE
						v_qty := 0;
            --取出所有符合的資料
						OPEN cur_3 (v_ins_fee_code);
						LOOP
							FETCH cur_3 INTO bilacntwkrec;
							EXIT WHEN cur_3%notfound;
							v_qty := v_qty + bilacntwkrec.qty;
							IF v_qty > bilnhrulesetrec.qty THEN
								p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '超過每次限制次數');
							END IF;
						END LOOP;
						CLOSE cur_3;
					END IF;
				END IF;

        --A碼過後幾次轉成B碼
				IF bilnhrulesetrec.rule_kind = '3' THEN
					v_qty := 0;
          --限日
					IF bilnhrulesetrec.range_type = '1' THEN
						OPEN cur_4 (v_ins_fee_code);
						LOOP
							FETCH cur_4 INTO v_start_date;
							EXIT WHEN cur_4%notfound;

              --算出該健保於某日期中的筆數,超過才要轉換,不然沒事
							SELECT
								SUM (bil_acnt_wk.tqty)
							INTO v_qty1
							FROM
								bil_acnt_wk
							WHERE
								bil_acnt_wk.caseno = pcaseno
								AND
								bil_acnt_wk.ins_fee_code = v_ins_fee_code
								AND
								bil_acnt_wk.start_date = v_start_date
								AND
								bil_acnt_wk.insu_amt > 0;
							SELECT
								SUM (bil_acnt_wk.tqty)
							INTO v_qty2
							FROM
								bil_acnt_wk
							WHERE
								bil_acnt_wk.caseno = pcaseno
								AND
								bil_acnt_wk.ins_fee_code = v_ins_fee_code
								AND
								bil_acnt_wk.start_date = v_start_date
								AND
								bil_acnt_wk.insu_amt < 0;
							IF v_qty1 IS NULL THEN
								v_qty1 := 0;
							END IF;
							IF v_qty2 IS NULL THEN
								v_qty2 := 0;
							END IF;
							v_qty := v_qty1 - v_qty2;

              --CHECK同一日中的次數是否超過需轉換的次數,
              --是就全刪,並COPY一筆給轉換的健保碼
							IF v_qty >= bilnhrulesetrec.qty THEN
								v_first := 'Y';
                --取出所有符合的資料
								OPEN cur_5 (v_ins_fee_code, v_start_date);
								LOOP
									FETCH cur_5 INTO bilacntwkrec;
									EXIT WHEN cur_5%notfound;

                  --只有第一筆要新增B項健保碼,其他全都要刪除含第一筆,只是第一筆要拿來copyB項健保碼用.
									IF v_qty >= bilnhrulesetrec.qty AND v_first = 'Y' THEN
										p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => bilnhrulesetrec.ins_fee_code2, pdeletereason
										=> '超過每日限制次數,轉換成' || bilnhrulesetrec.ins_fee_code2);
                    --reset qty values ,就不會再insert 一次了...
										v_first := 'N';
									END IF;
									IF v_qty >= bilnhrulesetrec.qty AND bilacntwkrec.tqty <= v_qty THEN
										p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '超過每日限制次數,轉換成' || bilnhrulesetrec
										.ins_fee_code2);
										v_qty := v_qty - bilacntwkrec.tqty;
									END IF;
								END LOOP;
								CLOSE cur_5;
							END IF;
						END LOOP;
						CLOSE cur_4;
					ELSE
            --算出該健保於某日期中的筆數,超過才要轉換,不然沒事
						SELECT
							SUM (bil_acnt_wk.tqty)
						INTO v_qty1
						FROM
							bil_acnt_wk
						WHERE
							bil_acnt_wk.caseno = pcaseno
							AND
							bil_acnt_wk.insu_amt > 0
							AND
							bil_acnt_wk.ins_fee_code = v_ins_fee_code;
						SELECT
							SUM (bil_acnt_wk.tqty)
						INTO v_qty2
						FROM
							bil_acnt_wk
						WHERE
							bil_acnt_wk.caseno = pcaseno
							AND
							bil_acnt_wk.insu_amt < 0
							AND
							bil_acnt_wk.ins_fee_code = v_ins_fee_code;
						IF v_qty1 IS NULL THEN
							v_qty1 := 0;
						END IF;
						IF v_qty2 IS NULL THEN
							v_qty2 := 0;
						END IF;
						v_qty := v_qty1 - v_qty2;

            --CHECK同一日中的次數是否超過需轉換的次數,
            --是就全刪,並COPY一筆給轉換的健保碼
						IF v_qty > bilnhrulesetrec.qty THEN
              --取出所有符合的資料
							OPEN cur_3 (v_ins_fee_code);
							LOOP
								FETCH cur_3 INTO bilacntwkrec;
								EXIT WHEN cur_3%notfound;
                --只有第一筆要新增B項健保碼,其他全都要刪除含第一筆,只是第一筆要拿來copyB項健保碼用.
								IF v_qty > bilnhrulesetrec.qty THEN
									p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => bilnhrulesetrec.ins_fee_code2, pdeletereason
									=> '超過每次住院限制次數,轉換成' || bilnhrulesetrec.ins_fee_code2);
                  --reset qty values ,就不會再insert 一次了...
									v_qty := 0;
								END IF;
								p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => '超過每次住院限制次數,轉換成' || bilnhrulesetrec
								.ins_fee_code2);
							END LOOP;
							CLOSE cur_3;
						END IF;
					END IF;
				END IF;
			END LOOP;
			CLOSE cur_2;
		END LOOP;
		CLOSE cur_1;

    --12.新生兒內含項刪除
		BEGIN
			SELECT
				*
			INTO bilrootrec
			FROM
				bil_root
			WHERE
				bil_root.caseno = bilrootrec.hmrcase
				AND
				bil_root.hfinacl <> 'CIVC';
			v_first := 'Y';
			OPEN cur_12;
			LOOP
				FETCH cur_12 INTO bilacntwkrec;
				EXIT WHEN cur_12%notfound;

        --IF bilRootRec.Drg_Code IN ('A02', 'A04') THEN\
				IF drgcode IN (
					'A02',
					'A04'
				) THEN
					v_ins_fee_code := '57114C';
				ELSE
					v_ins_fee_code := '57115C';
				END IF;
				IF v_first = 'Y' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => v_ins_fee_code, pdeletereason => '新生兒照顧費'
					);
				END IF;
				p_deleteacntwk (pcaseno, bilacntwkrec.acnt_seq, '新生兒內含項');
				v_first := 'N';
			END LOOP;
			CLOSE cur_12;
		EXCEPTION
			WHEN OTHERS THEN
				v_error_code   := sqlcode;
				v_error_info   := sqlerrm;
		END;
		OPEN cur_14;
		LOOP
			FETCH cur_14 INTO bilacntwkrec;
			EXIT WHEN cur_14%notfound;
			SELECT
				COUNT (*)
			INTO v_qty
			FROM
				bil_acnt_wk
			WHERE
				bil_acnt_wk.caseno = pcaseno
				AND
				bil_acnt_wk.ins_fee_code = bilacntwkrec.ins_fee_code
				AND
				bil_acnt_wk.start_date = bilacntwkrec.start_date
				AND
				(bil_acnt_wk.insu_amt * bil_acnt_wk.qty) > 0;
			SELECT
				COUNT (*)
			INTO v_qty_1
			FROM
				bil_acnt_wk,
				pflabi
			WHERE
				bil_acnt_wk.caseno = pcaseno
				AND
				bil_acnt_wk.ins_fee_code = bilacntwkrec.ins_fee_code
				AND
				bil_acnt_wk.start_date = bilacntwkrec.start_date
				AND
				(bil_acnt_wk.insu_amt * bil_acnt_wk.qty) < 0;
			v_qty := nvl (v_qty, 0) - nvl (v_qty_1, 0);
			IF v_qty > 1 THEN
				IF bilacntwkrec.ins_fee_code = '32001C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '32002C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					bilacntwkrec.ins_fee_code := '32002C';
				ELSIF bilacntwkrec.ins_fee_code = '32007C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '32008C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					bilacntwkrec.ins_fee_code := '32008C';
				ELSIF bilacntwkrec.ins_fee_code = '32009C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '32010C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					bilacntwkrec.ins_fee_code := '32010C';
				ELSIF bilacntwkrec.ins_fee_code = '32011C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '32012C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					bilacntwkrec.ins_fee_code := '32012C';
				ELSIF bilacntwkrec.ins_fee_code = '32013C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '32014C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					bilacntwkrec.ins_fee_code := '32014C';
				ELSIF bilacntwkrec.ins_fee_code = '32015C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '32016C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					bilacntwkrec.ins_fee_code := '32016C';
				ELSIF bilacntwkrec.ins_fee_code = '32017C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '32018C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					bilacntwkrec.ins_fee_code := '32018C';
				ELSIF bilacntwkrec.ins_fee_code = '32022C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => '32023C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					bilacntwkrec.ins_fee_code := '32023C';
				END IF;
			END IF;
		END LOOP;
		CLOSE cur_14;
		v_first          := 'Y';
		IF bilrootrec.dischg_date IS NOT NULL THEN
			OPEN cur_13 (trunc (bilrootrec.dischg_date));
			LOOP
				FETCH cur_13 INTO bilacntwkrec;
				EXIT WHEN cur_13%notfound;
				p_deleteacntwk (pcaseno, bilacntwkrec.acnt_seq, '最後一天管灌伙食不計價');
			END LOOP;
			CLOSE cur_13;
		END IF;

    --判斷是否為自行要求剖腹產
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			bil_root.caseno = pcaseno;

    --update by amber 20101222  
    --Blcsfg自行剖腹標記,並判斷此次住院身份別是否有為健保產NHI2,並抓取其該身份有效日計算金額
    --判斷此住院號在此次住院間是否為NHI2健保產(自行要求剖負產需自付)
		SELECT
			COUNT (*)
		INTO v_nhi2_flag
		FROM
			common.pat_adm_financial
		WHERE
			hfinancl = 'NHI2'
			AND
			hcaseno = pcaseno;

    --抓取NHI2健保產身份別起始日
		SELECT
			MAX (hfindate)
		INTO v_nhi2date_s
		FROM
			common.pat_adm_financial
		WHERE
			hfinancl = 'NHI2'
			AND
			hcaseno = pcaseno;

    --抓取NHI2健保產身份別結束日(以防之後又有新身份)
		SELECT
			TO_CHAR (TO_DATE (MIN (hfindate), 'yyyymmdd') - 1, 'yyyymmdd')
		INTO v_nhi2date_e
		FROM
			common.pat_adm_financial
		WHERE
			hfindate > v_nhi2date_s
			AND
			hcaseno = pcaseno;
		IF v_nhi2date_e IS NULL THEN
			v_nhi2date_e := TO_CHAR (bilrootrec.dischg_date, 'YYYYMMDD');
		END IF;
		IF bilrootrec.blcsfg = 'Y' AND v_nhi2_flag <> 0 THEN
			IF bilrootrec.dischg_date IS NOT NULL THEN
				v_dischg_date := trunc (bilrootrec.dischg_date);
			ELSE
				v_dischg_date := trunc (SYSDATE);
			END IF;
			SELECT
				*
			INTO bilfeemstrec
			FROM
				bil_feemst
			WHERE
				bil_feemst.caseno = pcaseno;

      --自費剖腹產20140701落入DRG 改為 17252(目前為止),因為健保碼無法使用,所以先壓死 by kuo 20140702
			IF v_dischg_date < TO_DATE ('20140701', 'YYYYMMDD') THEN
				SELECT
					*
				INTO vsnhirec
				FROM
					vsnhi
				WHERE
					vsnhi.labkey = '97014C'
					AND
					vsnhi.labbdate < v_dischg_date
					AND
					vsnhi.labedate >= v_dischg_date;
			ELSE
				SELECT
					*
				INTO vsnhirec
				FROM
					vsnhi
				WHERE
					vsnhi.labkey = '97014C'
					AND
					vsnhi.labbdate < TO_DATE ('20140630', 'YYYYMMDD')
					AND
					vsnhi.labedate >= TO_DATE ('20140630', 'YYYYMMDD');
				vsnhirec.labprice := 17252;
			END IF;

      --抓取此NHI2身份別此區間的健保金額,將原本應健保已付的部份改為自行負擔
      --剖腹產金額-2000>該期間健保金額 --> 該期間健保金額-剖腹產金額-2000=自付金額
			SELECT
				nvl (SUM (a.insu_amt * a.emg_per * a.qty), 0)
			INTO v_insu_amt
			FROM
				bil_acnt_wk a
			WHERE
				a.caseno = pcaseno
				AND
				TO_CHAR (a.bildate, 'yyyymmdd') BETWEEN v_nhi2date_s AND v_nhi2date_e
				AND
				a.pfincode = 'LABI';

      --dbms_output.put_line(v_insu_amt);
			IF vsnhirec.labprice - 2000 < v_insu_amt
      /*IF vsnhiRec.Labprice - 2000 < (bilFeemstRec.Emg_Exp_Amt1 +
                                                   bilFeemstRec.Emg_Exp_Amt2 +
                                                   bilFeemstRec.Emg_Exp_Amt3)*/ THEN
        --塞差額到固定收費碼中
				bilacntwkrec.caseno        := pcaseno;
				SELECT
					MAX (bil_acnt_wk.acnt_seq)
				INTO
					bilacntwkrec
				.acnt_seq
				FROM
					bil_acnt_wk
				WHERE
					caseno = pcaseno
					AND
					bil_acnt_wk.acnt_seq IS NOT NULL;
				IF bilacntwkrec.acnt_seq IS NULL THEN
					bilacntwkrec.acnt_seq := 1;
				ELSE
					bilacntwkrec.acnt_seq := bilacntwkrec.acnt_seq + 1;
				END IF;
				bilacntwkrec.seq_no        := '0000';
				bilacntwkrec.price_code    := '60499999';
				bilacntwkrec.fee_kind      := '18';
				bilacntwkrec.keyin_date    := SYSDATE;
				bilacntwkrec.qty           := 1;
				bilacntwkrec.tqty          := 1;
				bilacntwkrec.insu_tqty     := 1;
				bilacntwkrec.emg_flag      := 'N';
				bilacntwkrec.emg_per       := 1;
				bilacntwkrec.insu_amt      := 0;
        /*bilAcntWkRec.self_amt    := (bilFeemstRec.Emg_Exp_Amt1
        + bilFeemstRec.Emg_Exp_Amt2
        + bilFeemstRec.Emg_Exp_Amt3 )
        - (vsnhiRec.Labprice
        - 2000);*/
				bilacntwkrec.self_amt      := (v_insu_amt) - (vsnhirec.labprice - 2000);
				bilacntwkrec.part_amt      := 0;
				bilacntwkrec.self_flag     := 'Y';
				bilacntwkrec.order_doc     := bilrootrec.hvmdno;
				bilacntwkrec.execute_doc   := bilrootrec.hvmdno;
				bilacntwkrec.clerk         := 'billing';
				bilacntwkrec.bed_no        := bilrootrec.bed_no;
				bilacntwkrec.dept_code     := bilrootrec.hcursvcl;
				bilacntwkrec.start_date    := bilrootrec.admit_date;
				bilacntwkrec.end_date      := bilrootrec.admit_date;
				bilacntwkrec.del_flag      := 'N';
				bilacntwkrec.ward          := bilrootrec.ward;
				bilacntwkrec.pfincode      := 'CIVC';
				INSERT INTO bil_acnt_wk VALUES bilacntwkrec;
				bilacntwkrec.seq_no        := '0001';
				bilacntwkrec.acnt_seq      := bilacntwkrec.acnt_seq + 1;
				bilacntwkrec.insu_amt      := bilacntwkrec.self_amt * -1;
				bilacntwkrec.self_amt      := 0;
				bilacntwkrec.self_flag     := 'N';
				bilacntwkrec.pfincode      := 'LABI';
				INSERT INTO bil_acnt_wk VALUES bilacntwkrec;
				bilacntwkrec.self_amt      := bilacntwkrec.insu_amt * -1;
				BEGIN
					SELECT
						*
					INTO bilfeedtlrec
					FROM
						bil_feedtl
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = '18'
						AND
						bil_feedtl.pfincode = 'CIVC';
					UPDATE bil_feedtl
					SET
						bil_feedtl.total_amt = bil_feedtl.total_amt + bilacntwkrec.self_amt
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = '18'
						AND
						bil_feedtl.pfincode = 'CIVC';
				EXCEPTION
					WHEN OTHERS THEN
						bilfeedtlrec.caseno             := pcaseno;
						bilfeedtlrec.fee_type           := '18';
						bilfeedtlrec.pfincode           := 'CIVC';
						bilfeedtlrec.total_amt          := bilacntwkrec.self_amt;
						bilfeedtlrec.created_by         := 'billing';
						bilfeedtlrec.creation_date      := SYSDATE;
						bilfeedtlrec.last_updated_by    := 'billing';
						bilfeedtlrec.last_update_date   := SYSDATE;
						INSERT INTO bil_feedtl VALUES bilfeedtlrec;
				END;
				BEGIN
					SELECT
						*
					INTO bilfeedtlrec
					FROM
						bil_feedtl
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = '18'
						AND
						bil_feedtl.pfincode = 'LABI';
					UPDATE bil_feedtl
					SET
						bil_feedtl.total_amt = bil_feedtl.total_amt - bilacntwkrec.self_amt
					WHERE
						bil_feedtl.caseno = pcaseno
						AND
						bil_feedtl.fee_type = '18'
						AND
						bil_feedtl.pfincode = 'LABI';
				EXCEPTION
					WHEN OTHERS THEN
						bilfeedtlrec.caseno             := pcaseno;
						bilfeedtlrec.fee_type           := '18';
						bilfeedtlrec.pfincode           := 'LABI';
						bilfeedtlrec.total_amt          := bilacntwkrec.self_amt * -1;
						bilfeedtlrec.created_by         := 'billing';
						bilfeedtlrec.creation_date      := SYSDATE;
						bilfeedtlrec.last_updated_by    := 'billing';
						bilfeedtlrec.last_update_date   := SYSDATE;
						INSERT INTO bil_feedtl VALUES bilfeedtlrec;
				END;
				UPDATE bil_feemst
				SET
					bil_feemst.tot_gl_amt = bil_feemst.tot_gl_amt + bilacntwkrec.self_amt,
					bil_feemst.emg_exp_amt1 = bil_feemst.emg_exp_amt1 - bilacntwkrec.self_amt
				WHERE
					bil_feemst.caseno = pcaseno;
			END IF;
		END IF;
		v_tb_days        := 0;

    --如果TBDIET 註記 = 'C2' 且身份為NHI5 則,為C2符合案件,可申報伙食天數為14天
		IF patadmcaserec.htbdiet = 'C2' AND patadmcaserec.hfinancl = 'NHI5' THEN
			v_tb_days := 14;
		END IF;

    --3/24 郭先生通知修正C4案件規則同C2,但身份別須為CIVC
    --如果TBDIET 註記 = 'C4' 且身份為NHI5 則,為C2符合案件,可申報伙食天數為14天
		IF patadmcaserec.htbdiet = 'C2' AND patadmcaserec.hfinancl = 'CIVC' THEN
			v_tb_days := 14;
		END IF;

    --如果TBDIET 註記 = 'C3' 且身份為NHI5 則,為C2符合案件,可申報伙食天數為30天
    --C3 從 1040101後取消 by kuo 20141126
		IF patadmcaserec.htbdiet = 'C3' AND patadmcaserec.hfinancl = 'NHI5' THEN
			v_tb_days := 30;
		END IF;
		IF v_tb_days > 0 THEN
			v_days := 0;
			OPEN cur_15;
			LOOP
				FETCH cur_15 INTO v_start_date;
				EXIT WHEN cur_15%notfound;
				v_first   := 'Y';
				v_days    := v_days + 1;
				IF v_days <= v_tb_days AND v_start_date < TO_DATE ('20150101', 'YYYYMMDD') THEN
					OPEN cur_16 (v_start_date);
					LOOP
						FETCH cur_16 INTO bilacntwkrec;
						EXIT WHEN cur_16%notfound;

            --只有第一筆要新增B項健保碼,其他全都要刪除含第一筆,只是第一筆要拿來copyB項健保碼用.
            --普通飲食
						IF substr (bilacntwkrec.price_code, 1, 5) IN (
							'DIET1',
							'DIET2'
						) OR bilacntwkrec.price_code LIKE 'DITP_001' OR bilacntwkrec.price_code LIKE 'DITP_008' THEN
							v_ins_fee_code := 'E4001B';
						ELSE
							v_ins_fee_code := 'E4002B';
						END IF;
						IF v_first = 'Y' THEN
							p_insertacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pinsfeecode => v_ins_fee_code, pdeletereason => 'C2/C3案件伙食補助'
							);
						END IF;
						v_first := 'N';
						p_deleteacntwk (pcaseno => pcaseno, pacntseq => bilacntwkrec.acnt_seq, pdeletereason => 'C2/C3案件伙食補助');
					END LOOP;
					CLOSE cur_16;
				END IF;
			END LOOP;
			CLOSE cur_15;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;
	PROCEDURE p_deleteacntwk (
		pcaseno         VARCHAR2,
		pacntseq        NUMBER,
		pdeletereason   VARCHAR2
	) IS
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.acnt_seq = pacntseq;
		bilacntwkrec       bil_acnt_wk%rowtype;
		biloccurtransrec   bil_occur_trans%rowtype;
		v_amt              NUMBER (10, 1);
		v_amt1             NUMBER (10, 1);
		v_amt2             NUMBER (10, 1);
		v_amt3             NUMBER (10, 1);
		v_seqno            NUMBER (5, 0);
    --錯誤訊息用途
		v_program_name     VARCHAR2 (80);
		v_session_id       NUMBER (10);
		v_error_code       VARCHAR2 (20);
		v_error_msg        VARCHAR2 (400);
		v_error_info       VARCHAR2 (600);
		v_source_seq       VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name                          := 'biling_calculate_PKG.p_deleteAcntWk';
		v_session_id                            := userenv ('SESSIONID');
		OPEN cur_1;
		FETCH cur_1 INTO bilacntwkrec;
		CLOSE cur_1;

    --複制一筆到記錄檔中
		biloccurtransrec.caseno                 := bilacntwkrec.caseno;
		biloccurtransrec.bil_date               := bilacntwkrec.start_date;
		biloccurtransrec.order_seqno            := bilacntwkrec.seq_no;
		biloccurtransrec.id                     := bilacntwkrec.order_seq;
		biloccurtransrec.discharged             := bilacntwkrec.discharged;
		biloccurtransrec.pf_key                 := bilacntwkrec.price_code;
		biloccurtransrec.create_dt              := bilacntwkrec.keyin_date;
		biloccurtransrec.fee_kind               := bilacntwkrec.fee_kind;
		biloccurtransrec.qty                    := bilacntwkrec.qty * -1;
		IF bilacntwkrec.insu_amt <> 0 THEN
			v_amt := bilacntwkrec.insu_amt * bilacntwkrec.emg_per * bilacntwkrec.qty;
		END IF;
		IF bilacntwkrec.self_amt <> 0 THEN
			v_amt := bilacntwkrec.self_amt * bilacntwkrec.emg_per * bilacntwkrec.qty;
		END IF;
		IF bilacntwkrec.part_amt <> 0 THEN
			v_amt := bilacntwkrec.part_amt * bilacntwkrec.emg_per * bilacntwkrec.qty;
		END IF;
		biloccurtransrec.charge_amount          := v_amt * -1;
		biloccurtransrec.emergency              := bilacntwkrec.emg_flag;
		biloccurtransrec.self_flag              := bilacntwkrec.self_flag;
		biloccurtransrec.income_dept            := bilacntwkrec.cost_code;
		biloccurtransrec.log_location           := bilacntwkrec.stock_code;
		biloccurtransrec.discharge_bring_back   := bilacntwkrec.out_med_flag;
		biloccurtransrec.ward                   := bilacntwkrec.ward;
		biloccurtransrec.bed_no                 := bilacntwkrec.bed_no;
		biloccurtransrec.created_by             := bilacntwkrec.clerk;
		biloccurtransrec.creation_date          := bilacntwkrec.keyin_date;
		biloccurtransrec.last_updated_by        := bilacntwkrec.clerk;
		biloccurtransrec.last_update_date       := SYSDATE;
		biloccurtransrec.e_level                := bilacntwkrec.e_level;
		biloccurtransrec.trans_reason           := pdeletereason;
		biloccurtransrec.ins_fee_code           := bilacntwkrec.ins_fee_code;
		biloccurtransrec.bildate                := bilacntwkrec.bildate;
		BEGIN
			SELECT
				MAX (bil_occur_trans.acnt_seq)
			INTO v_seqno
			FROM
				bil_occur_trans
			WHERE
				bil_occur_trans.caseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				v_seqno := 0;
		END;
		IF v_seqno IS NULL THEN
			v_seqno := 0;
		END IF;
		IF v_seqno > 5000 THEN
			v_seqno := v_seqno + 1;
		ELSE
			v_seqno := v_seqno + 5001;
		END IF;
		biloccurtransrec.acnt_seq               := v_seqno;
		INSERT INTO bil_occur_trans VALUES biloccurtransrec;

    --修改 bil_feedtl 及bilfeemst的金額
		IF bilacntwkrec.insu_amt <> 0 THEN
			UPDATE bil_feedtl
			SET
				bil_feedtl.total_amt = bil_feedtl.total_amt - v_amt
			WHERE
				bil_feedtl.caseno = pcaseno
				AND
				bil_feedtl.fee_type = bilacntwkrec.fee_kind
				AND
				bil_feedtl.pfincode = 'LABI';
			v_amt1   := 0;
			v_amt2   := 0;
			v_amt3   := 0;
			IF biloccurtransrec.e_level = '1' THEN
				v_amt1 := v_amt;
			ELSIF biloccurtransrec.e_level = '2' THEN
				v_amt2 := v_amt;
			ELSE
				v_amt3 := v_amt;
			END IF;
			IF f_getnhrangeflag (pcaseno, bilacntwkrec.start_date, '2') = 'NHI0' THEN
				UPDATE bil_feemst
				SET
					bil_feemst.emg_exp_amt1 = bil_feemst.emg_exp_amt1 - v_amt1,
					bil_feemst.emg_exp_amt2 = bil_feemst.emg_exp_amt2 - v_amt2,
					bil_feemst.emg_exp_amt3 = bil_feemst.emg_exp_amt3 - v_amt3,
					bil_feemst.emg_pay_amt1 = bil_feemst.emg_pay_amt1 - v_amt1,
					bil_feemst.emg_pay_amt2 = bil_feemst.emg_pay_amt2 - v_amt2,
					bil_feemst.emg_pay_amt3 = bil_feemst.emg_pay_amt3 - v_amt3
				WHERE
					bil_feemst.caseno = pcaseno;
			ELSE
				UPDATE bil_feemst
				SET
					bil_feemst.emg_exp_amt1 = bil_feemst.emg_exp_amt1 - v_amt1,
					bil_feemst.emg_exp_amt2 = bil_feemst.emg_exp_amt2 - v_amt2,
					bil_feemst.emg_exp_amt3 = bil_feemst.emg_exp_amt3 - v_amt3
				WHERE
					bil_feemst.caseno = pcaseno;
			END IF;
		END IF;
		IF bilacntwkrec.self_amt <> 0 THEN
			UPDATE bil_feedtl
			SET
				bil_feedtl.total_amt = bil_feedtl.total_amt - v_amt
			WHERE
				bil_feedtl.caseno = pcaseno
				AND
				bil_feedtl.fee_type = bilacntwkrec.fee_kind
				AND
				bil_feedtl.pfincode = 'CIVC';
			UPDATE bil_feemst
			SET
				bil_feemst.tot_gl_amt = bil_feemst.tot_gl_amt - v_amt
			WHERE
				bil_feemst.caseno = pcaseno;
		END IF;
		IF bilacntwkrec.part_amt <> 0 THEN
			UPDATE bil_feedtl
			SET
				bil_feedtl.total_amt = bil_feedtl.total_amt - v_amt
			WHERE
				bil_feedtl.caseno = pcaseno
				AND
				bil_feedtl.fee_type = bilacntwkrec.fee_kind
				AND
				bil_feedtl.pfincode = bilacntwkrec.pfincode;
			UPDATE bil_feemst
			SET
				bil_feemst.credit_amt = bil_feemst.credit_amt - v_amt
			WHERE
				bil_feemst.caseno = pcaseno;
		END IF;
		DELETE FROM bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.acnt_seq = pacntseq;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;
	PROCEDURE p_insertacntwk (
		pcaseno         VARCHAR2,
		pacntseq        NUMBER,
		pinsfeecode     VARCHAR2,
		pdeletereason   VARCHAR2
	) IS
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			bil_acnt_wk.caseno = pcaseno
			AND
			bil_acnt_wk.acnt_seq = pacntseq;
		bilacntwkrec       bil_acnt_wk%rowtype;
		biloccurtransrec   bil_occur_trans%rowtype;
		bilfeedtlrec       bil_feedtl%rowtype;
		v_amt              NUMBER (10, 1);
		v_amt1             NUMBER (10, 1);
		v_amt2             NUMBER (10, 1);
		v_amt3             NUMBER (10, 1);
		v_labprice         NUMBER (10, 2);
		v_seqno            NUMBER (5, 0);
		v_cnt              INTEGER;
    --錯誤訊息用途
		v_program_name     VARCHAR2 (80);
		v_session_id       NUMBER (10);
		v_error_code       VARCHAR2 (20);
		v_error_msg        VARCHAR2 (400);
		v_error_info       VARCHAR2 (600);
		v_source_seq       VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name                          := 'biling_calculate_PKG.p_insertAcntWk';
		v_session_id                            := userenv ('SESSIONID');
		OPEN cur_1;
		FETCH cur_1 INTO bilacntwkrec;
		CLOSE cur_1;

    --複制一筆到記錄檔中
		biloccurtransrec.caseno                 := bilacntwkrec.caseno;
		biloccurtransrec.acnt_seq               := bilacntwkrec.acnt_seq;
		biloccurtransrec.bil_date               := bilacntwkrec.start_date;
		biloccurtransrec.order_seqno            := bilacntwkrec.seq_no;
		biloccurtransrec.id                     := bilacntwkrec.order_seq;
		biloccurtransrec.discharged             := bilacntwkrec.discharged;
		biloccurtransrec.create_dt              := bilacntwkrec.keyin_date;
    --新生兒照顧費
		IF pinsfeecode IN (
			'57114C',
			'57115C'
		) THEN
			biloccurtransrec.fee_kind   := '39';
			bilacntwkrec.fee_kind       := '39';
			IF pinsfeecode = '57114C' THEN
				bilacntwkrec.price_code := '60299998';
			ELSE
				bilacntwkrec.price_code := '60299999';
			END IF;
		ELSE
			biloccurtransrec.fee_kind := bilacntwkrec.fee_kind;
		END IF;
		biloccurtransrec.qty                    := 1;
		biloccurtransrec.emergency              := bilacntwkrec.emg_flag;
		IF pinsfeecode IN (
			'E4001B',
			'E4002B'
		) THEN
			bilacntwkrec.self_flag   := 'N';
			bilacntwkrec.self_amt    := 0;
			bilacntwkrec.pfincode    := 'LABI';
		END IF;
		biloccurtransrec.pf_key                 := bilacntwkrec.price_code;
		biloccurtransrec.self_flag              := bilacntwkrec.self_flag;
		biloccurtransrec.income_dept            := bilacntwkrec.cost_code;
		biloccurtransrec.log_location           := bilacntwkrec.stock_code;
		biloccurtransrec.discharge_bring_back   := bilacntwkrec.out_med_flag;
		biloccurtransrec.ward                   := bilacntwkrec.ward;
		biloccurtransrec.bed_no                 := bilacntwkrec.bed_no;
		biloccurtransrec.created_by             := bilacntwkrec.clerk;
		biloccurtransrec.creation_date          := bilacntwkrec.keyin_date;
		biloccurtransrec.last_updated_by        := bilacntwkrec.clerk;
		biloccurtransrec.last_update_date       := SYSDATE;
		biloccurtransrec.e_level                := bilacntwkrec.e_level;
		biloccurtransrec.trans_reason           := pdeletereason;
		biloccurtransrec.ins_fee_code           := pinsfeecode;
		biloccurtransrec.bildate                := bilacntwkrec.bildate;
		BEGIN
			SELECT
				MAX (bil_occur_trans.acnt_seq)
			INTO v_seqno
			FROM
				bil_occur_trans
			WHERE
				bil_occur_trans.caseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				v_seqno := 0;
		END;
		IF v_seqno IS NULL THEN
			v_seqno := 0;
		END IF;
		IF v_seqno > 5000 THEN
			v_seqno := v_seqno + 1;
		ELSE
			v_seqno := v_seqno + 5001;
		END IF;
		biloccurtransrec.acnt_seq               := v_seqno;
		SELECT
			vsnhi.labprice
		INTO v_labprice
		FROM
			vsnhi
		WHERE
			rtrim (vsnhi.labkey) = pinsfeecode
			AND
			(labbdate <= bilacntwkrec.start_date
			 OR
			 labbdate IS NULL)
			AND
			labedate >= bilacntwkrec.start_date;
		v_amt                                   := v_labprice * bilacntwkrec.emg_per * 1;
		biloccurtransrec.charge_amount          := v_amt;
		IF pinsfeecode <> 'MA12345678NH' THEN
			INSERT INTO bil_occur_trans VALUES biloccurtransrec;
		END IF;
		BEGIN
			SELECT
				MAX (bil_acnt_wk.acnt_seq)
			INTO v_seqno
			FROM
				bil_acnt_wk
			WHERE
				bil_acnt_wk.caseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				v_seqno := 0;
		END;
		IF v_seqno IS NULL THEN
			v_seqno := 0;
		END IF;
		bilacntwkrec.acnt_seq                   := v_seqno + 1;
		bilacntwkrec.insu_amt                   := v_labprice;
		IF pinsfeecode <> 'MA12345678NH' THEN
			bilacntwkrec.qty    := 1;
			bilacntwkrec.tqty   := 1;
		ELSE
			v_amt := v_amt * bilacntwkrec.qty;
		END IF;
		bilacntwkrec.ins_fee_code               := pinsfeecode;
		INSERT INTO bil_acnt_wk VALUES bilacntwkrec;

    --修改 bil_feedtl 及bilfeemst的金額
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			bil_feedtl
		WHERE
			bil_feedtl.caseno = pcaseno
			AND
			bil_feedtl.fee_type = biloccurtransrec.fee_kind
			AND
			bil_feedtl.pfincode = 'LABI';
		IF v_cnt > 0 THEN
			UPDATE bil_feedtl
			SET
				bil_feedtl.total_amt = bil_feedtl.total_amt + v_amt
			WHERE
				bil_feedtl.caseno = pcaseno
				AND
				bil_feedtl.fee_type = biloccurtransrec.fee_kind
				AND
				bil_feedtl.pfincode = 'LABI';
		ELSE
			bilfeedtlrec.caseno             := pcaseno;
			bilfeedtlrec.fee_type           := biloccurtransrec.fee_kind;
			bilfeedtlrec.pfincode           := 'LABI';
			bilfeedtlrec.total_amt          := v_amt;
			bilfeedtlrec.created_by         := 'billing';
			bilfeedtlrec.creation_date      := SYSDATE;
			bilfeedtlrec.last_updated_by    := 'billing';
			bilfeedtlrec.last_update_date   := SYSDATE;
			INSERT INTO bil_feedtl VALUES bilfeedtlrec;
		END IF;
		v_amt1                                  := 0;
		v_amt2                                  := 0;
		v_amt3                                  := 0;
		IF biloccurtransrec.e_level = '1' THEN
			v_amt1 := v_amt;
		ELSIF biloccurtransrec.e_level = '2' THEN
			v_amt2 := v_amt;
		ELSE
			v_amt3 := v_amt;
		END IF;
		IF f_getnhrangeflag (pcaseno, bilacntwkrec.start_date, '2') = 'NHI0' THEN
			UPDATE bil_feemst
			SET
				bil_feemst.emg_exp_amt1 = bil_feemst.emg_exp_amt1 + v_amt1,
				bil_feemst.emg_exp_amt2 = bil_feemst.emg_exp_amt2 + v_amt2,
				bil_feemst.emg_exp_amt3 = bil_feemst.emg_exp_amt3 + v_amt3,
				bil_feemst.emg_pay_amt1 = bil_feemst.emg_pay_amt1 + v_amt1,
				bil_feemst.emg_pay_amt2 = bil_feemst.emg_pay_amt2 + v_amt2,
				bil_feemst.emg_pay_amt3 = bil_feemst.emg_pay_amt3 + v_amt3
			WHERE
				bil_feemst.caseno = pcaseno;
		ELSE
			UPDATE bil_feemst
			SET
				bil_feemst.emg_exp_amt1 = bil_feemst.emg_exp_amt1 + v_amt1,
				bil_feemst.emg_exp_amt2 = bil_feemst.emg_exp_amt2 + v_amt2,
				bil_feemst.emg_exp_amt3 = bil_feemst.emg_exp_amt3 + v_amt3
			WHERE
				bil_feemst.caseno = pcaseno;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --判斷是否為就養榮民
	FUNCTION f_checknhdiet (
		pcaseno VARCHAR2
	) RETURN VARCHAR2 IS
		v_hvtcatcd       VARCHAR2 (02);
		v_hvtfincl       VARCHAR2 (01);
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.f_checkNHDiet';
		v_session_id     := userenv ('SESSIONID');

    --取出安置單位及身份類別
		BEGIN
			SELECT
				hvtcatcd,
				hvtfincl
			INTO
				v_hvtcatcd,
				v_hvtfincl
			FROM
				common.pat_adm_vtan_rec
			WHERE
				common.pat_adm_vtan_rec.hcaseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				v_hvtcatcd := '00';
		END;

    --公費安置+ 身份<>有職榮
		IF v_hvtcatcd = '14' AND v_hvtfincl <> '2' THEN
			RETURN 'Y';
		ELSE
			RETURN 'N';
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;
	PROCEDURE p_modifityselfpay (
		pcaseno          VARCHAR2,
		pfinacl          VARCHAR2,
		pdischargedate   DATE
	)
  /*
    部份負擔30日內優減計算
    */ IS
		bilfeemstrec     bil_feemst%rowtype;
		bilfeedtlrec     bil_feedtl%rowtype;
		bilrootrec       bil_root%rowtype;
		v_discount       NUMBER (5, 2);
		v_disfin         VARCHAR2 (10);
		v_discount_amt   NUMBER (10, 0);
		t_1060disamt     NUMBER; --add by kuo 20131107
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_fincalcode     tmp_fincal.fincalcode%TYPE;

    --還要改按區間
    --新加 內政部役政署補助替代役男部份負擔作業 1100 by kuo 20121220
		CURSOR cur_checkpfincode (
			p_caseno VARCHAR2
		) IS
		SELECT
			fincalcode
		FROM
			tmp_fincal
		WHERE
			tmp_fincal.caseno = p_caseno
			AND
			tmp_fincal.fincalcode IN (
				'1058',
				'1054',
				'1083',
				'1060',
				'1039',
				'1057',
				'1062',
				'1100',
				'9520'
			);
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.p_modifitySelfPay';
		v_session_id     := userenv ('SESSIONID');
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			caseno = pcaseno;
		--p_disfin (pcaseno, pfinacl, v_disfin);
		get_discfin (pcaseno, pfinacl, v_disfin);
		BEGIN
			OPEN cur_checkpfincode (pcaseno);
			FETCH cur_checkpfincode INTO v_fincalcode;
			IF cur_checkpfincode%found THEN
        --先檢查特約優減
				v_disfin := v_fincalcode;
				dbms_output.put_line (v_disfin);
				IF v_fincalcode = '1057' THEN
					v_discount := 0.9;
				ELSE
					v_discount := 0;
				END IF;
			ELSIF pfinacl = 'EMPL' THEN
        --再檢查員工優減
				IF pdischargedate IS NULL OR pdischargedate >= TO_DATE ('2010/05/10', 'yyyy/mm/dd') THEN
					v_discount := 0.5; --出院日期在2010/05/15之後，員工身份打五折
				END IF;
			ELSIF pfinacl = 'VTAN' THEN
        --再檢查無職榮輔導會優減
				v_discount := 1; --預設為無優減
				IF v_disfin >= 'VT01' AND v_disfin <= 'VT03' THEN
					v_discount := 1;
				ELSIF v_disfin = 'VT04' THEN
					v_discount := 0.8; --上校，輔導會補助20%，病患自付80%
				ELSIF v_disfin = 'VT05' OR v_disfin = 'VT06' THEN
					v_discount := 0.5; --中上校，輔導會補助50%，病患自付50%
				ELSIF v_disfin = 'VT07' THEN
					v_discount := 0.3; --尉級，輔導會補助70%，病患自付30%
				ELSIF v_disfin = 'VT11' THEN
					v_discount := 0; --士兵，輔導會補助100%，病患自付0%
				END IF;
			END IF;
			IF pcaseno = '02925683' THEN --request by 姬小姐 2534
				v_discount   := 0; --士兵，輔導會補助100%，病患自付0%
				v_disfin     := 'VT11';
				dbms_output.put_line ('---');
			END IF;
			SELECT
				*
			INTO bilfeemstrec
			FROM
				bil_feemst
			WHERE
				bil_feemst.caseno = pcaseno;

      --強制隔離住院，NHI0依住院天數核減部份負擔(30日內)by kuo 20131106 
			IF v_fincalcode = '1060' THEN
				SELECT
					SUM (a.qty * a.emg_per * a.insu_amt) / 10
				INTO t_1060disamt
				FROM
					bil_acnt_wk   a,
					tmp_fincal    b,
					bil_date      c
				WHERE
					a.caseno = pcaseno
					AND
					a.caseno = b.caseno
					AND
					b.fincalcode = '1060'
					AND
					a.pfincode = 'LABI'
					AND
					a.bildate >= b.st_date
					AND
					a.bildate <= b.end_date
					AND
					a.caseno = c.caseno
					AND
					a.bildate = c.bil_date
					AND
					c.hfinacl = 'NHI0';
				v_discount_amt := t_1060disamt;
			ELSE
         --程式調整 20140829 by kuo,前面錯的就算了...
				IF bilrootrec.dischg_date IS NULL OR bilrootrec.dischg_date > TO_DATE ('20140830', 'YYYYMMDD') THEN
					v_discount_amt := bilfeemstrec.emg_pay_amt1 * (1 - v_discount);
				ELSE
					v_discount_amt := bilfeemstrec.tot_self_amt * (1 - v_discount);
				END IF;
			END IF;
      --DBMS_OUTPUT.PUT_LINE('V_DISCOUNT_AMT:'||V_DISCOUNT_AMT);
      --計算*部份負擔30日內優減後之金額 mark by kuo 20131106 
      --v_discount_amt := bilFeemstRec.Tot_Self_Amt * (1 - v_discount);
      --程式調整 20140829 by kuo,前面錯的就算了...
			IF bilrootrec.dischg_date IS NULL OR bilrootrec.dischg_date > TO_DATE ('20140830', 'YYYYMMDD') THEN
				UPDATE bil_feemst
				SET
					bil_feemst.tot_self_amt = bilfeemstrec.tot_self_amt - v_discount_amt,
					bil_feemst.credit_amt = bilfeemstrec.credit_amt + v_discount_amt,
					bil_feemst.emg_pay_amt1 = bilfeemstrec.emg_pay_amt1 - v_discount_amt
				WHERE
					bil_feemst.caseno = pcaseno;
			ELSE
				UPDATE bil_feemst
				SET
					bil_feemst.tot_self_amt = bilfeemstrec.tot_self_amt - v_discount_amt,
					bil_feemst.credit_amt = bilfeemstrec.credit_amt + v_discount_amt
				WHERE
					bil_feemst.caseno = pcaseno;
			END IF;
      --新增*部份負擔30日內之優減帳款
			bilfeedtlrec.caseno             := pcaseno;
			bilfeedtlrec.fee_type           := '41';
			bilfeedtlrec.pfincode           := v_disfin;
			bilfeedtlrec.total_amt          := v_discount_amt;
			bilfeedtlrec.created_by         := 'billing';
			bilfeedtlrec.creation_date      := SYSDATE;
			bilfeedtlrec.last_updated_by    := 'billing';
			bilfeedtlrec.last_update_date   := SYSDATE;
			INSERT INTO bil_feedtl VALUES bilfeedtlrec;
			UPDATE bil_feedtl
			SET
				bil_feedtl.total_amt = bil_feedtl.total_amt - v_discount_amt
			WHERE
				caseno = pcaseno
				AND
				pfincode = 'CIVC'
				AND
				fee_type = bilfeedtlrec.fee_type;

      --新增VT% 31-60與 60以外優減帳款by kuo 20150108
      --新增1058 31-60與 60以外優減帳款by kuo 20160129
			dbms_output.put_line (bilfeemstrec.emg_pay_amt2);
			IF bilfeemstrec.emg_pay_amt2 > 0 AND (pfinacl LIKE 'VT%' OR v_disfin IN (
				'1058'
			) OR pcaseno = '02925683') THEN
				bilfeemstrec.tot_self_amt       := bilfeemstrec.tot_self_amt - v_discount_amt;
        --dbms_output.put_line('----');
				v_discount_amt                  := bilfeemstrec.emg_pay_amt2 * (1 - v_discount);
				UPDATE bil_feemst
				SET
					bil_feemst.tot_self_amt = bilfeemstrec.tot_self_amt - v_discount_amt,
					bil_feemst.credit_amt = bilfeemstrec.credit_amt + v_discount_amt,
					bil_feemst.emg_pay_amt2 = bilfeemstrec.emg_pay_amt2 - v_discount_amt
				WHERE
					bil_feemst.caseno = pcaseno;
				bilfeedtlrec.caseno             := pcaseno;
				bilfeedtlrec.fee_type           := '42';
				bilfeedtlrec.pfincode           := v_disfin;
				bilfeedtlrec.total_amt          := v_discount_amt;
				bilfeedtlrec.created_by         := 'billing';
				bilfeedtlrec.creation_date      := SYSDATE;
				bilfeedtlrec.last_updated_by    := 'billing';
				bilfeedtlrec.last_update_date   := SYSDATE;
				INSERT INTO bil_feedtl VALUES bilfeedtlrec;
				UPDATE bil_feedtl
				SET
					bil_feedtl.total_amt = bil_feedtl.total_amt - v_discount_amt
				WHERE
					caseno = pcaseno
					AND
					pfincode = 'CIVC'
					AND
					fee_type = bilfeedtlrec.fee_type;
			END IF;
			IF bilfeemstrec.emg_pay_amt3 > 0 AND (pfinacl LIKE 'VT%' OR v_disfin IN (
				'1058'
			)) THEN
				bilfeemstrec.tot_self_amt       := bilfeemstrec.tot_self_amt - v_discount_amt;
				v_discount_amt                  := bilfeemstrec.emg_pay_amt3 * (1 - v_discount);
				UPDATE bil_feemst
				SET
					bil_feemst.tot_self_amt = bilfeemstrec.tot_self_amt - v_discount_amt,
					bil_feemst.credit_amt = bilfeemstrec.credit_amt + v_discount_amt,
					bil_feemst.emg_pay_amt3 = bilfeemstrec.emg_pay_amt3 - v_discount_amt
				WHERE
					bil_feemst.caseno = pcaseno;
				bilfeedtlrec.caseno             := pcaseno;
				bilfeedtlrec.fee_type           := '43';
				bilfeedtlrec.pfincode           := v_disfin;
				bilfeedtlrec.total_amt          := v_discount_amt;
				bilfeedtlrec.created_by         := 'billing';
				bilfeedtlrec.creation_date      := SYSDATE;
				bilfeedtlrec.last_updated_by    := 'billing';
				bilfeedtlrec.last_update_date   := SYSDATE;
				INSERT INTO bil_feedtl VALUES bilfeedtlrec;
				UPDATE bil_feedtl
				SET
					bil_feedtl.total_amt = bil_feedtl.total_amt - v_discount_amt
				WHERE
					caseno = pcaseno
					AND
					pfincode = 'CIVC'
					AND
					fee_type = bilfeedtlrec.fee_type;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				v_error_code   := sqlcode;
				v_error_info   := sqlerrm;
		END;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;

  --取得當日身份別
	FUNCTION f_getnhrangeflag (
		pcaseno    VARCHAR2,
		pdate      DATE,
		pfinflag   VARCHAR2
	) RETURN VARCHAR2 IS
		CURSOR cur_1 IS
		SELECT
			tmp_fincal.*
		FROM
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
			AND
			tmp_fincal.st_date <= pdate
			AND
			tmp_fincal.end_date >= pdate
			AND
			tmp_fincal.fincalcode IN (
				'LABI',
				'CIVC'
			)
		ORDER BY
			trunc (tmp_fincal.end_date) DESC,
			tmp_fincal.fincalcode ASC;
		CURSOR cur_2 IS
		SELECT
			*
		FROM
			common.pat_adm_financial
		WHERE
			common.pat_adm_financial.hcaseno = pcaseno
			AND
			common.pat_adm_financial.hfindate <= TO_CHAR (pdate, 'yyyymmdd')
		ORDER BY
			common.pat_adm_financial.hfindate DESC,
			hfininf DESC,
			ins_date DESC;
		tmpfincalrec         tmp_fincal%rowtype;
		patadmfinancialrec   common.pat_adm_financial%rowtype;

    --錯誤訊息用途
		v_program_name       VARCHAR2 (80);
		v_session_id         NUMBER (10);
		v_error_code         VARCHAR2 (20);
		v_error_msg          VARCHAR2 (400);
		v_error_info         VARCHAR2 (600);
		v_source_seq         VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.f_getNhRangeFlag';
		v_session_id     := userenv ('SESSIONID');

    --RETURN LABI/CIVC/特約 算價格用
		IF pfinflag = '1' THEN
			OPEN cur_1;
			FETCH cur_1 INTO tmpfincalrec;
			CLOSE cur_1;
			RETURN tmpfincalrec.fincalcode;
		ELSIF pfinflag = '2' THEN
			OPEN cur_2;
			FETCH cur_2 INTO patadmfinancialrec;
			CLOSE cur_2;
			RETURN patadmfinancialrec.hfinancl;
		ELSIF pfinflag = '3' THEN
			OPEN cur_2;
			FETCH cur_2 INTO patadmfinancialrec;
			CLOSE cur_2;
			RETURN patadmfinancialrec.hfincl2;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END;
  --計算乘數
  --兒童加成依計價日起算
	FUNCTION getemgpernew (
		pcaseno    VARCHAR2, --住院序
		ppfkey     VARCHAR2, --計價碼
		pfeekind   VARCHAR2, --帳檔計價類別
		pemgflag   VARCHAR2, --急作否
		bldate     DATE,     --計價日期 NEW ADD
		ptype      VARCHAR2
	) --'1'算全部成數 '2',只算急作成數
	 RETURN NUMBER IS
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_cnt            INTEGER;
		pemgper          NUMBER (10, 2) := 1; --急作乘數預設為1
		v_pf_self_pay    NUMBER (10, 2); --自費金額
		v_pf_nh_pay      NUMBER (10, 2); --申報金額
		v_pf_child_pay   NUMBER (10, 2); --兒童加乘
		v_faemep_flag    VARCHAR2 (01); --住院可急作否
		v_pfopfg_flag    VARCHAR2 (01); --手術否
		v_pfspexam       VARCHAR2 (01); --特殊檢驗否
		v_child_flag_1   VARCHAR2 (01) := 'N'; --兒童加乘
		v_child_flag_2   VARCHAR2 (01) := 'N'; --兒童加乘
		v_child_flag_3   VARCHAR2 (01) := 'N'; --兒童加乘
		bilrootrec       bil_root%rowtype;
		ls_date          VARCHAR2 (10);
		v_nh_type        VARCHAR2 (02);
		adt1             DATE; -- 出生年月，日=01
		adt2             DATE; -- 就醫年月，日=01

    --出生年齡(健保規定年齡部份計算為年-年)
    --月份才是年月日
		v_yy             INTEGER;
		CURSOR cur_vsnhi (
			ppfkey VARCHAR2
		) IS
		SELECT
			vsnhi.labtype
		FROM
			vsnhi,
			pflabi
		WHERE
			pflabi.pfkey = ppfkey
			AND
			vsnhi.labkey = pflabi.pflabcd;
		CURSOR cur_1 (
			ppfkey VARCHAR2
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfaemep,
			pfopfg,
			pfspexam
		FROM
			pfclass
		WHERE
			pfclass.pfkey = ppfkey
			AND
			(pfclass.pfinoea = 'A'
			 OR
			 pfclass.pfinoea = '@');
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_calculate_PKG.GETEMGPERNEW';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			bil_root.caseno = pcaseno;
		IF bilrootrec.admit_date < TO_DATE ('20120201', 'YYYYMMDD') THEN
			pemgper := getemgper (pcaseno => pcaseno, ppfkey => ppfkey, pfeekind => pfeekind, pbldate => bldate, pemgflag => pemgflag, ptype
			=> ptype);
			RETURN pemgper;
		END IF;
		OPEN cur_vsnhi (ppfkey);
		FETCH cur_vsnhi INTO v_nh_type;
		CLOSE cur_vsnhi;

    --ls_date := biling_common_pkg.f_datebetween(b_date => bilRootRec.Birth_Date,
    --                                           e_date => bilRootRec.Admit_Date);
    --v_yy    := TO_NUMBER(to_char(bilRootRec.Admit_Date, 'yyyy')) -
    --           TO_NUMBER(TO_CHAR(BILROOTREC.BIRTH_DATE, 'yyyy'));
    --回歸健保制度依月來看而非日
		adt1             := TO_DATE (TO_CHAR (bilrootrec.birth_date, 'YYYYMM') || '01', 'YYYYMMDD');
		adt2             := TO_DATE (TO_CHAR (bldate, 'YYYYMM') || '01', 'YYYYMMDD');
		ls_date          := round (months_between (adt2, adt1), 0);
    --ls_date := biling_common_pkg.f_datebetween(b_date => bilRootRec.Birth_Date,
    --                                           e_date => BLDATE);
		v_yy             := to_number (TO_CHAR (bldate, 'yyyy')) - to_number (TO_CHAR (bilrootrec.birth_date, 'yyyy'));
		OPEN cur_1 (ppfkey);
		FETCH cur_1 INTO
			v_pf_self_pay,
			v_pf_nh_pay,
			v_pf_child_pay,
			v_faemep_flag,
			v_pfopfg_flag,
			v_pfspexam;
		IF cur_1%found THEN
      --UPDATE 20110111 BY AMBER 自費項'11'手術材料費未算入,需使用加乘
			IF ppfkey = '80007439' THEN
				pemgper := pemgper + 0.53;
			END IF;
      --取出病患年齡
      --判斷是否符合兒童加乘( 6歲以下 , 二歲以下 ,六個月以下)
      --年齡大於6歲,就沒有兒童加乘
      --1.< 6m 者 ，+60%
      --2.大於等於6M，小於等於23M 者，+30%
      --3.大於等於24m，小於等於83m者，+20%
			v_child_flag_1   := 'N';
			v_child_flag_2   := 'N';
			v_child_flag_3   := 'N';
			IF ls_date < 6 THEN --小於六個月
				v_child_flag_3 := 'Y';
			END IF;
			IF ls_date <= 23 AND ls_date >= 6 THEN ---二歲到六個月之間
				v_child_flag_2 := 'Y';
			END IF;
			IF ls_date >= 24 AND ls_date <= 83 THEN --六歲以下
				v_child_flag_1 := 'Y';
			END IF;
      --取出病患年齡
      --判斷是否符合兒童加乘( 6歲以下 , 二歲以下 ,六個月以下)
      --年齡大於6歲,就沒有兒童加乘
      --IF v_yy > 6 THEN
      --  v_child_flag_1 := 'N';
      --  v_child_flag_2 := 'N';
      --  v_child_flag_3 := 'N';
      --ELSE
      --  --小於六歲大於二歲者
      --  IF v_yy <= 6 AND to_number(ls_date) > 20000 THEN
      --    v_child_flag_1 := 'Y';
      --  ELSE
      --    --年齡小於一歲,月份又小於六個月
      --    IF substr(ls_date, 1, 3) = '000' AND
      --       TO_NUMBER(substr(ls_date, 4, 2)) < 6 THEN
      --      v_child_flag_3 := 'Y';
      --      --小於二歲大於六個月
      --    ELSE
      --      v_child_flag_2 := 'Y';
      --    END IF;
      --  END IF;
      --END IF;

      --住院可報急作,且有急作註記者
			IF v_faemep_flag = 'Y' AND pemgflag = 'E' THEN
        --手術,接生加成
				IF pfeekind IN (
					'07',
					'08'
				) OR v_nh_type = '07' THEN
					pemgper := pemgper + 0.3;
				ELSE
					pemgper := pemgper + 0.2;
				END IF;
			END IF;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				pflabi
			WHERE
				pflabi.pfkey = ppfkey;
			IF v_cnt > 0 THEN
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					pflabi,
					vsnhi
				WHERE
					pflabi.pfkey = ppfkey
					AND
					pflabi.pflabcd = vsnhi.labkey
					AND
					(labbdate <= SYSDATE
					 OR
					 labbdate IS NULL)
					AND
					labedate >= SYSDATE
					AND
					vsnhi.nhitype = '07';
				IF v_cnt = 0 THEN
					v_pfopfg_flag := 'N';
				ELSE
					v_pfopfg_flag := 'Y';
				END IF;
			END IF;

      --手術加成
			IF v_pfopfg_flag = 'Y' THEN
        --以下項目材料費內含, ADD 80011890 BY KUO 1000525
				IF ppfkey IN (
					'80004399',
					'50004106',
					'80011890'
				) THEN
					pemgper := pemgper;
				ELSE
					IF pfeekind <> '08' THEN
						pemgper := pemgper + 0.53;
					END IF;
				END IF;
			END IF;
			IF ptype = '2' THEN
				RETURN pemgper;
			END IF;

      --麻醉加成
			IF pfeekind = '09' OR v_nh_type = '11' THEN
				CASE
					WHEN pemgflag = 'C' THEN
						pemgper := pemgper + 0.2;
					WHEN pemgflag IN (
						'D',
						'L'
					) THEN
						pemgper := pemgper + 0.3;
					WHEN pemgflag IN (
						'A',
						'E',
						'I'
					) THEN
						pemgper := pemgper + 0.5;
					WHEN pemgflag = 'J' THEN
						pemgper := pemgper + 0.6;
					WHEN pemgflag = 'B' THEN
						pemgper := pemgper + 0.7;
					WHEN pemgflag IN (
						'G',
						'K'
					) THEN
						pemgper := pemgper + 0.8;
					WHEN pemgflag = 'H' THEN
						pemgper := pemgper + 1;
					ELSE
						pemgper := pemgper;
				END CASE;
			END IF;
      --dbpfile 未設定兒童加乘金額者,無兒童加乘
			IF v_pf_child_pay > 0 AND v_pf_child_pay IS NOT NULL THEN
				IF v_child_flag_1 = 'Y' THEN
          --兒童加成(6歲以下)
					pemgper := pemgper + 0.2;
				ELSIF v_child_flag_2 = 'Y' THEN
          --兒童加成(2歲以下)
					pemgper := pemgper + 0.3;
				ELSIF v_child_flag_3 = 'Y' THEN
          --兒童加成(六個月以下)
					pemgper := pemgper + 0.6;
				END IF;
			ELSE
        --六個月以下,手術加成60
				IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') THEN
					pemgper := pemgper + 0.6;
				END IF;
			END IF;

      --以下急作成數為固定成數
			IF pfeekind = '11' THEN
        --手材併入手術主項不另列
				pemgper := 0;
			ELSIF pfeekind = '12' THEN
        --麻材
				pemgper := 0.5;
			ELSIF pfeekind = '13' THEN
        --手材
				pemgper := 0.53;
			ELSIF pfeekind = '18' THEN
        --治療處理
        --配合99/01/08健保局0994050093號函「全民健保費用支付標準」
        --自99/6/1起實施，年齡小於84個月，以下2碼加成30%、37%，實際修改日期99/7/1
				IF (v_yy < 7) THEN
          --年齡小於七歲
					IF (bilrootrec.admit_date >= TO_DATE ('2010/07/01', 'yyyy/mm/dd')) THEN
						IF ppfkey IN (
							'74700256'
						) THEN
							pemgper := pemgper + 0.3;
						END IF;
						IF ppfkey IN (
							'74700371'
						) THEN
							pemgper := pemgper + 0.37;
						END IF;
					END IF;
				END IF;
			END IF;
		ELSE
			pemgper := 1;
		END IF;
		CLOSE cur_1;
		RETURN pemgper;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			pemgper        := 1;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END getemgpernew;

  --國際醫療計算用，整個翻新 BY KUO 20121108
  --健保給付價=健保價*1.63
  --自費=自費*1.3
  --有部份給付算在自費(含病房費，護理費)
  --無藥事服務費
  --CU病房診察費為民眾價*1.3，餘1500
	PROCEDURE contract_as999_old (
		pcaseno VARCHAR2
	) IS
		CURSOR upd_acnt_wk IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			caseno = pcaseno
		ORDER BY
			fee_kind
		FOR UPDATE;
    --找CPOE.DBPFILE定價
		CURSOR cur_dbpfile_price (
			ppfkey VARCHAR2
		) IS
		SELECT
			pfprice1
		FROM
			cpoe.dbpfile
		WHERE
			pfkey = ppfkey;
    --找pfmlog
		CURSOR cur_pfmlog (
			ppfkey   VARCHAR2,
			pdate    DATE,
			pamt     NUMBER
		) IS
		SELECT
			*
		FROM
			pfmlog
		WHERE
			pfmlog.pfkey = ppfkey
			AND
			pfmlog.enddatetime IN (
				SELECT
					MIN (pfmlog.enddatetime) --modify by kuo 981221
				FROM
					pfmlog
				WHERE
					pfmlog.pfkey = ppfkey
					AND
					substr (pfmlog.enddatetime, 1, 8) >= TO_CHAR (pdate, 'yyyymmdd') --MODIFY BY kUO 970616
					AND
					pfmlog.pflprice <> pamt
					AND
					pfmlog.pflprice <> 0
					AND
					pfmlog.pfldbtyp = 'A'
			) --modify by tenya 990923)
			AND
			pfmlog.pfldbtyp = 'A'; --modify by kuo 981221     
    --找特殊收費檔PFCLASS(含歷史檔)有無"LABI資料"
		CURSOR cur_pfclass_labi (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			*
		FROM
			(
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100
				FROM
					pfclass
				WHERE
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'LABI'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
				UNION
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100
				FROM
					pfhiscls
				WHERE
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'LABI'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
			);
    --BIL_FEEDTL FOR UPDATE
		CURSOR upd_bil_feedtl IS
		SELECT
			*
		FROM
			bil_feedtl
		WHERE
			caseno = pcaseno
		ORDER BY
			fee_type
		FOR UPDATE;
		sprice           cpoe.dbpfile.pfprice1%TYPE;
		pfcnhiprice      NUMBER;
		pfcselprice      NUMBER;
		pfmlogrec        pfmlog%rowtype;
		bilfeedtlrec     bil_feedtl%rowtype;
		totalglamt       NUMBER;
		emper            NUMBER;
		s999flag         NUMBER;
		cuflag           VARCHAR2 (1);
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		acntwk_rec       bil_acnt_wk%rowtype;
	BEGIN
		v_program_name   := 'biling_calculate_PKG.CONTRACT_S999';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
    --ONLY S999 CAN DO THIS
    --SELECT COUNT(*) INTO S999FLAG FROM BIL_CONTR WHERE CASENO=PCASENO AND BILCUNIT='S999';
    --Add new S998 by Kuo 20130617
    --Add new S996 by Kuo 20140520
		SELECT
			COUNT (*)
		INTO s999flag
		FROM
			bil_contr
		WHERE
			caseno = pcaseno
			AND
			bilcunit IN (
				'S999',
				'S998',
				'S996'
			);
		IF s999flag = 0 THEN
			return;
		END IF;
		OPEN upd_acnt_wk;
		LOOP
			<< xxx >> emper := 1.3;
			FETCH upd_acnt_wk INTO acntwk_rec;
			EXIT WHEN upd_acnt_wk%notfound;
      --抓DBPFILE價錢
			OPEN cur_dbpfile_price (acntwk_rec.price_code);
			FETCH cur_dbpfile_price INTO sprice;
			CLOSE cur_dbpfile_price;
      --抓PFMLOG
			OPEN cur_pfmlog (acntwk_rec.price_code, acntwk_rec.bildate, sprice);
			FETCH cur_pfmlog INTO pfmlogrec;
			IF cur_pfmlog%found THEN
				sprice := pfmlogrec.pflprice;
			END IF;
			CLOSE cur_pfmlog;
      --抓PFCLASS,PFHISCLS健保價與部份自付價
			OPEN cur_pfclass_labi (acntwk_rec.price_code, acntwk_rec.bildate);
			FETCH cur_pfclass_labi INTO
				pfcselprice,
				pfcnhiprice;
			IF cur_pfclass_labi%found THEN
				IF pfcselprice = 0 AND pfcnhiprice > 0 THEN
					sprice   := pfcnhiprice;
					emper    := 1.63;
				END IF;
			END IF;
			CLOSE cur_pfclass_labi;
			IF acntwk_rec.fee_kind = '06' THEN
				sprice := acntwk_rec.self_amt;
			END IF;
      --非CU病房診察費一律1500
			IF acntwk_rec.fee_kind = '03' THEN
         --判斷是否CU
         --IF CUFLAG='N' THEN --非CU
				IF NOT (acntwk_rec.ward) LIKE '%CU' THEN
					UPDATE bil_acnt_wk
					SET
						price_code = 'DIAGINT1', --新碼
						self_amt = 1500,
						ins_fee_code = 'DIAGINT1'--新碼
					WHERE
						CURRENT OF upd_acnt_wk;
					GOTO xxx;
				END IF;
			END IF;
      --藥事服務費取消
			IF acntwk_rec.fee_kind = '04' THEN
				UPDATE bil_acnt_wk
				SET
					qty = 0,
					tqty = 0
				WHERE
					CURRENT OF upd_acnt_wk;
				GOTO xxx;
			END IF;
      --電話費依據實際狀況算入,by kuo 20130327
			IF acntwk_rec.fee_kind = '40' THEN
				GOTO xxx;
			END IF;
      --一般項目
			UPDATE bil_acnt_wk
			SET
				self_amt = sprice,
				emg_per = emg_per * emper
      --UPDATE BIL_ACNT_WK SET EMG_PER=EMG_PER*EMPER
			WHERE
				CURRENT OF upd_acnt_wk;
		END LOOP;
		CLOSE upd_acnt_wk;
		COMMIT WORK;
    --修改BIL_FEEMST與BIL_FEEDTL,因為只有CIVC,所以不特別指出了
		OPEN upd_bil_feedtl;
		LOOP
			FETCH upd_bil_feedtl INTO bilfeedtlrec;
			EXIT WHEN upd_bil_feedtl%notfound;
			SELECT
				round (SUM (qty * emg_per * self_amt))
			INTO
				bilfeedtlrec
			.total_amt
			FROM
				bil_acnt_wk
			WHERE
				caseno = pcaseno
				AND
				fee_kind = bilfeedtlrec.fee_type;
			UPDATE bil_feedtl
			SET
				total_amt = bilfeedtlrec.total_amt
			WHERE
				CURRENT OF upd_bil_feedtl;
		END LOOP;
		CLOSE upd_bil_feedtl;
		COMMIT WORK;
		SELECT
			SUM (total_amt)
		INTO totalglamt
		FROM
			bil_feedtl
		WHERE
			caseno = pcaseno;
		UPDATE bil_feemst
		SET
			tot_gl_amt = totalglamt
		WHERE
			caseno = pcaseno;
		COMMIT WORK;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END contract_as999_old;

  --國際醫療計算用，整個翻新 BY KUO 20121108
  --健保給付價=健保價*1.63
  --自費=自費*1.3
  --有部份給付算在自費(含病房費，護理費)
  --無藥事服務費
  --CU病房診察費為民眾價*1.3，餘1500
	PROCEDURE contract_as999_origin (
		pcaseno VARCHAR2
	) IS
		CURSOR upd_acnt_wk IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			caseno = pcaseno
		ORDER BY
			fee_kind
		FOR UPDATE;
    --找CPOE.DBPFILE定價
		CURSOR cur_dbpfile_price (
			ppfkey VARCHAR2
		) IS
		SELECT
			pfprice1
		FROM
			cpoe.dbpfile
		WHERE
			pfkey = ppfkey;
    --找pfmlog
		CURSOR cur_pfmlog (
			ppfkey   VARCHAR2,
			pdate    DATE,
			pamt     NUMBER
		) IS
		SELECT
			*
		FROM
			pfmlog
		WHERE
			pfmlog.pfkey = ppfkey
			AND
			pfmlog.enddatetime IN (
				SELECT
					MIN (pfmlog.enddatetime) --modify by kuo 981221
				FROM
					pfmlog
				WHERE
					pfmlog.pfkey = ppfkey
					AND
					substr (pfmlog.enddatetime, 1, 8) >= TO_CHAR (pdate, 'yyyymmdd') --MODIFY BY kUO 970616
					AND
					pfmlog.pflprice <> pamt
					AND
					pfmlog.pflprice <> 0
					AND
					pfmlog.pfldbtyp = 'A'
			) --modify by tenya 990923)
			AND
			pfmlog.pfldbtyp = 'A'; --modify by kuo 981221     
    --找特殊收費檔PFCLASS(含歷史檔)有無"LABI資料"
		CURSOR cur_pfclass_labi (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			*
		FROM
			(
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100
				FROM
					pfclass
				WHERE
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'LABI'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
				UNION
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100
				FROM
					pfhiscls
				WHERE
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'LABI'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
			);
    --BIL_FEEDTL FOR UPDATE
		CURSOR upd_bil_feedtl IS
		SELECT
			*
		FROM
			bil_feedtl
		WHERE
			caseno = pcaseno
		ORDER BY
			fee_type
		FOR UPDATE;
		sprice           cpoe.dbpfile.pfprice1%TYPE;
		pfcnhiprice      NUMBER;
		pfcselprice      NUMBER;
		pfmlogrec        pfmlog%rowtype;
		bilfeedtlrec     bil_feedtl%rowtype;
		totalglamt       NUMBER;
		emper            NUMBER;
		s999flag         NUMBER;
		cuflag           VARCHAR2 (1);
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		acntwk_rec       bil_acnt_wk%rowtype;
	BEGIN
		v_program_name   := 'biling_calculate_PKG.CONTRACT_S999';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
    --ONLY S999 CAN DO THIS
    --SELECT COUNT(*) INTO S999FLAG FROM BIL_CONTR WHERE CASENO=PCASENO AND BILCUNIT='S999';
    --Add new S998 by Kuo 20130617
    --Add new S996 by Kuo 20140520
		SELECT
			COUNT (*)
		INTO s999flag
		FROM
			bil_contr
		WHERE
			caseno = pcaseno
			AND
			bilcunit IN (
				'S999',
				'S998',
				'S996'
			);
		IF s999flag = 0 THEN
			return;
		END IF;
		OPEN upd_acnt_wk;
		LOOP
			<< xxx >> emper := 1.3;
			FETCH upd_acnt_wk INTO acntwk_rec;
			EXIT WHEN upd_acnt_wk%notfound;
      --抓DBPFILE價錢
			OPEN cur_dbpfile_price (acntwk_rec.price_code);
			FETCH cur_dbpfile_price INTO sprice;
			CLOSE cur_dbpfile_price;
      --抓PFMLOG
			OPEN cur_pfmlog (acntwk_rec.price_code, acntwk_rec.bildate, sprice);
			FETCH cur_pfmlog INTO pfmlogrec;
			IF cur_pfmlog%found THEN
				sprice := pfmlogrec.pflprice;
			END IF;
			CLOSE cur_pfmlog;
      --抓PFCLASS,PFHISCLS健保價與部份自付價
			OPEN cur_pfclass_labi (acntwk_rec.price_code, acntwk_rec.bildate);
			FETCH cur_pfclass_labi INTO
				pfcselprice,
				pfcnhiprice;
			IF cur_pfclass_labi%found THEN
				IF pfcselprice = 0 AND pfcnhiprice > 0 THEN
					sprice   := pfcnhiprice;
					emper    := 1.63;
				END IF;
			END IF;
			CLOSE cur_pfclass_labi;
			IF acntwk_rec.fee_kind = '06' THEN
				sprice := acntwk_rec.self_amt;
			END IF;
      --非CU病房診察費一律1500
			IF acntwk_rec.fee_kind = '03' THEN
         --判斷是否CU
         --IF CUFLAG='N' THEN --非CU
				IF NOT (acntwk_rec.ward) LIKE '%CU' THEN
					UPDATE bil_acnt_wk
					SET
						price_code = 'DIAGINT1', --新碼
						self_amt = 1500,
						ins_fee_code = 'DIAGINT1'--新碼
					WHERE
						CURRENT OF upd_acnt_wk;
					GOTO xxx;
				END IF;
			END IF;
      --藥事服務費取消
			IF acntwk_rec.fee_kind = '04' THEN
				UPDATE bil_acnt_wk
				SET
					qty = 0,
					tqty = 0
				WHERE
					CURRENT OF upd_acnt_wk;
				GOTO xxx;
			END IF;
      --電話費依據實際狀況算入,by kuo 20130327
			IF acntwk_rec.fee_kind = '40' THEN
				GOTO xxx;
			END IF;
      --一般項目
			UPDATE bil_acnt_wk
			SET
				self_amt = sprice,
				emg_per = emg_per * emper
      --UPDATE BIL_ACNT_WK SET EMG_PER=EMG_PER*EMPER
			WHERE
				CURRENT OF upd_acnt_wk;
		END LOOP;
		CLOSE upd_acnt_wk;
		COMMIT WORK;
    --修改BIL_FEEMST與BIL_FEEDTL,因為只有CIVC,所以不特別指出了
		OPEN upd_bil_feedtl;
		LOOP
			FETCH upd_bil_feedtl INTO bilfeedtlrec;
			EXIT WHEN upd_bil_feedtl%notfound;
			SELECT
				round (SUM (qty * emg_per * self_amt))
			INTO
				bilfeedtlrec
			.total_amt
			FROM
				bil_acnt_wk
			WHERE
				caseno = pcaseno
				AND
				fee_kind = bilfeedtlrec.fee_type;
			UPDATE bil_feedtl
			SET
				total_amt = bilfeedtlrec.total_amt
			WHERE
				CURRENT OF upd_bil_feedtl;
		END LOOP;
		CLOSE upd_bil_feedtl;
		COMMIT WORK;
		SELECT
			SUM (total_amt)
		INTO totalglamt
		FROM
			bil_feedtl
		WHERE
			caseno = pcaseno;
		UPDATE bil_feemst
		SET
			tot_gl_amt = totalglamt
		WHERE
			caseno = pcaseno;
		COMMIT WORK;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END contract_as999_origin;

  --國際醫療計算用，整個翻新 BY KUO 20121108
  --健保給付價=健保價*1.63 20151015 以後為 2.21 request by 國際醫療小組 add by kuo
  --自費=自費*1.3 20151102 以後為 1.7 request by 國際醫療小組 add by kuo
  --有部份給付算在自費(含病房費，護理費)
  --無藥事服務費
  --CU病房診察費為民眾價*1.3，餘1500
  --有比例的必須按比例調整 by kuo 20140520, 未上線，因為相同特約比例又不一樣   by kuo 20140527
  --新版本，如上 by kuo 20140609,取消頭等除了VTAM可特約
	PROCEDURE contract_as999 (
		pcaseno VARCHAR2
	) IS
		CURSOR upd_acnt_wk IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			caseno = pcaseno
		ORDER BY
			fee_kind
		FOR UPDATE;
    --找CPOE.DBPFILE定價
		CURSOR cur_dbpfile_price (
			ppfkey VARCHAR2
		) IS
		SELECT
			pfprice1
		FROM
			cpoe.dbpfile
		WHERE
			pfkey = ppfkey;
    --找pfmlog
		CURSOR cur_pfmlog (
			ppfkey   VARCHAR2,
			pdate    DATE,
			pamt     NUMBER
		) IS
		SELECT
			*
		FROM
			pfmlog
		WHERE
			pfmlog.pfkey = ppfkey
			AND
			pfmlog.enddatetime IN (
				SELECT
					MIN (pfmlog.enddatetime) --modify by kuo 981221
				FROM
					pfmlog
				WHERE
					pfmlog.pfkey = ppfkey
					AND
					substr (pfmlog.enddatetime, 1, 8) >= TO_CHAR (pdate, 'yyyymmdd') --MODIFY BY kUO 970616
					AND
					pfmlog.pflprice <> pamt
					AND
					pfmlog.pflprice <> 0
					AND
					pfmlog.pfldbtyp = 'A'
			) --modify by tenya 990923)
			AND
			pfmlog.pfldbtyp = 'A'; --modify by kuo 981221     
    --找特殊收費檔PFCLASS(含歷史檔)有無"LABI資料"
		CURSOR cur_pfclass_labi (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			*
		FROM
			(
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100
				FROM
					pfclass
				WHERE
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'LABI'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
				UNION
				SELECT
					to_number (pfselpay) / 100,
					to_number (pfreqpay) / 100
				FROM
					pfhiscls
				WHERE
					pfbegindate <= pbildate
					AND
					pfenddate >= pbildate
					AND
					pfkey = ppfkey
					AND
					pfincode = 'LABI'
					AND
					(pfinoea = 'A'
					 OR
					 pfinoea = '@')
			);
    --BIL_FEEDTL FOR UPDATE
		CURSOR upd_bil_feedtl IS
		SELECT
			*
		FROM
			bil_feedtl
		WHERE
			caseno = pcaseno
		ORDER BY
			fee_type
		FOR UPDATE;   
    --GET BIL_DISDTL discount ratio
		CURSOR dis_type (
			feetype VARCHAR2
		) IS
		SELECT
			salf_per
		FROM
			bil_discdtl
		WHERE
			bilkey IN (
				SELECT
					bilcunit
				FROM
					bil_contr
				WHERE
					caseno = pcaseno
			)
			AND
			bilkind = 'P'
			AND
			pftype = feetype;
		sprice           cpoe.dbpfile.pfprice1%TYPE;
		selprice         NUMBER;
		otherprice       NUMBER;
		pfcnhiprice      NUMBER;
		pfcselprice      NUMBER;
		pfmlogrec        pfmlog%rowtype;
		bilfeedtlrec     bil_feedtl%rowtype;
		totalglamt       NUMBER;
		emper            NUMBER;
		s999flag         NUMBER;
		s998flag         NUMBER;
		s996flag         NUMBER;
		s995flag         NUMBER;
		sel_pay_ratio    NUMBER;
		cuflag           VARCHAR2 (1);
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		acntwk_rec       bil_acnt_wk%rowtype;
	BEGIN
		v_program_name   := 'biling_calculate_PKG.CONTRACT_S999';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
    --ONLY S999 CAN DO THIS
    --SELECT COUNT(*) INTO S999FLAG FROM BIL_CONTR WHERE CASENO=PCASENO AND BILCUNIT='S999';
    --Add new S998 by Kuo 20130617
    --RETURN;
		SELECT
			COUNT (*)
		INTO s999flag
		FROM
			bil_contr
		WHERE
			caseno = pcaseno
			AND
			bilcunit IN (
				'S999',
				'S998',
				'S996',
				'S995'
			);
		SELECT
			COUNT (*)
		INTO s996flag
		FROM
			bil_contr
		WHERE
			caseno = pcaseno
			AND
			bilcunit = 'S996';
    --add by kuo 20150326 all civc to S995
		SELECT
			COUNT (*)
		INTO s995flag
		FROM
			bil_contr
		WHERE
			caseno = pcaseno
			AND
			bilcunit = 'S995';
    --add by kuo 20150810 all civc to S998
		SELECT
			COUNT (*)
		INTO s998flag
		FROM
			bil_contr
		WHERE
			caseno = pcaseno
			AND
			bilcunit = 'S998';
    --DBMS_OUTPUT.PUT_LINE('CNT:'||S999FLAG);
		IF s999flag = 0 THEN
			return;
		END IF;
		OPEN upd_acnt_wk;
		LOOP
			<< xxx >>
      --EMPER:=1.3;
			 FETCH upd_acnt_wk INTO acntwk_rec;
			EXIT WHEN upd_acnt_wk%notfound;
      --20151102後調整為 1.7 by kuo 20151014
			IF acntwk_rec.bildate >= TO_DATE ('20151102', 'YYYYMMDD') THEN
				emper := 1.7;
			ELSE
				emper := 1.3;
			END IF;
      --抓DBPFILE價錢
			OPEN cur_dbpfile_price (acntwk_rec.price_code);
			FETCH cur_dbpfile_price INTO sprice;
			CLOSE cur_dbpfile_price;
      --抓PFMLOG
			OPEN cur_pfmlog (acntwk_rec.price_code, acntwk_rec.bildate, sprice);
			FETCH cur_pfmlog INTO pfmlogrec;
			IF cur_pfmlog%found THEN
				sprice := pfmlogrec.pflprice;
			END IF;
			CLOSE cur_pfmlog;
      --抓PFCLASS,PFHISCLS健保價與部份自付價
			OPEN cur_pfclass_labi (acntwk_rec.price_code, acntwk_rec.bildate);
			FETCH cur_pfclass_labi INTO
				pfcselprice,
				pfcnhiprice;
			IF cur_pfclass_labi%found THEN
				IF pfcselprice = 0 AND pfcnhiprice > 0 THEN
					sprice := pfcnhiprice;
            --20151102後調整為 2.21 by kuo 20151014
					IF acntwk_rec.bildate >= TO_DATE ('20151102', 'YYYYMMDD') THEN
						emper := 2.21;
					ELSE
						emper := 1.63;
					END IF;
				END IF;
			END IF;
			CLOSE cur_pfclass_labi;
      --非CU病房診察費一律1500,S996因為要分百分比，不適用
			IF s996flag = 0 THEN
				IF acntwk_rec.fee_kind = '03' THEN
            --判斷是否CU
            --IF CUFLAG='N' THEN --非CU
					IF NOT (acntwk_rec.ward) LIKE '%CU' THEN
						UPDATE bil_acnt_wk
						SET
							price_code = 'DIAGINT1', --新碼
							self_amt = 1500,
							ins_fee_code = 'DIAGINT1'--新碼
						WHERE
							CURRENT OF upd_acnt_wk;
						GOTO xxx;
					END IF;
				END IF;
			ELSE --硬壓 S996 bil_date > 20140701 by kuo 20140722
				IF acntwk_rec.fee_kind = '03' AND acntwk_rec.bildate > TO_DATE ('20140701', 'YYYYMMDD') THEN
					IF NOT (acntwk_rec.ward) LIKE '%CU' THEN
						IF acntwk_rec.part_amt > 0 THEN
							UPDATE bil_acnt_wk
							SET
								price_code = 'DIAGINT1', --新碼
								part_amt = 1500 * 0.9,
								ins_fee_code = 'DIAGINT1'--新碼
							WHERE
								CURRENT OF upd_acnt_wk;
							GOTO xxx;
						END IF;
						IF acntwk_rec.self_amt > 0 THEN
							UPDATE bil_acnt_wk
							SET
								price_code = 'DIAGINT1', --新碼
								self_amt = 1500 * 0.1,
								ins_fee_code = 'DIAGINT1'--新碼
							WHERE
								CURRENT OF upd_acnt_wk;
							GOTO xxx;
						END IF;
					END IF;
				END IF;
			END IF;
      --藥事服務費取消
			IF acntwk_rec.fee_kind = '04' THEN
				UPDATE bil_acnt_wk
				SET
					qty = 0,
					tqty = 0
				WHERE
					CURRENT OF upd_acnt_wk;
				GOTO xxx;
			END IF;
			IF acntwk_rec.fee_kind = '06' THEN
				sprice   := acntwk_rec.self_amt;
				emper    := 1.3;
			END IF;
      --電話費依據實際狀況算入,by kuo 20130327
			IF acntwk_rec.fee_kind = '40' THEN
				GOTO xxx;
			END IF;
			OPEN dis_type (acntwk_rec.fee_kind);
			FETCH dis_type INTO sel_pay_ratio;
			IF dis_type%found THEN
				selprice     := sprice * sel_pay_ratio;
				otherprice   := sprice - selprice;
			END IF;
			CLOSE dis_type;
      --一般項目,無保險項目
      --DBMS_OUTPUT.PUT_LINE('ACNTWK_REC:'||ACNTWK_REC.PRICE_CODE||','||EMPER||',self:'||ACNTWK_REC.SELF_AMT||','||ACNTWK_REC.INSU_AMT||',SELPRICE='||SELPRICE);
      --IF ACNTWK_REC.SELF_AMT > 0 THEN
         --UPDATE BIL_ACNT_WK SET SELF_AMT=SELPRICE,EMG_PER=EMG_PER*EMPER
         --規則範圍S996 type S999 type 界定清楚 by kuo 20150724
			IF acntwk_rec.self_amt > 0 THEN
				IF s996flag > 0 THEN
					UPDATE bil_acnt_wk
					SET
						emg_per = emg_per * emper,
						self_amt = selprice
					WHERE
						CURRENT OF upd_acnt_wk;
				ELSE
					UPDATE bil_acnt_wk
					SET
						emg_per = emg_per * emper,
						self_amt = sprice
					WHERE
						CURRENT OF upd_acnt_wk;
				END IF;
			END IF;
			IF acntwk_rec.part_amt > 0 AND s996flag > 0 THEN
				UPDATE bil_acnt_wk
				SET
					emg_per = emg_per * emper,
					part_amt = otherprice
				WHERE
					CURRENT OF upd_acnt_wk;
			END IF; 
      --ELSE
         --UPDATE BIL_ACNT_WK SET PART_AMT=OTHERPRICE,EMG_PER=EMG_PER*EMPER
      --   UPDATE BIL_ACNT_WK SET EMG_PER=EMG_PER*EMPER
      --    WHERE CURRENT OF UPD_ACNT_WK;
      --END IF; 
		END LOOP;
		CLOSE upd_acnt_wk;
		COMMIT WORK;
    --修改BIL_FEEMST與BIL_FEEDTL,因為只有CIVC,所以不特別指出了
		OPEN upd_bil_feedtl;
		LOOP
			FETCH upd_bil_feedtl INTO bilfeedtlrec;
			EXIT WHEN upd_bil_feedtl%notfound;
			IF bilfeedtlrec.pfincode = 'CIVC' THEN
				SELECT
					round (SUM (qty * emg_per * self_amt))
				INTO
					bilfeedtlrec
				.total_amt
				FROM
					bil_acnt_wk
				WHERE
					caseno = pcaseno
					AND
					fee_kind = bilfeedtlrec.fee_type
					AND
					pfincode = bilfeedtlrec.pfincode;
			ELSE
				SELECT
					round (SUM (qty * emg_per * part_amt))
				INTO
					bilfeedtlrec
				.total_amt
				FROM
					bil_acnt_wk
				WHERE
					caseno = pcaseno
					AND
					fee_kind = bilfeedtlrec.fee_type
					AND
					pfincode = bilfeedtlrec.pfincode;
			END IF;
			UPDATE bil_feedtl
			SET
				total_amt = bilfeedtlrec.total_amt
			WHERE
				CURRENT OF upd_bil_feedtl;
		END LOOP;
		CLOSE upd_bil_feedtl;
		COMMIT WORK;
		SELECT
			SUM (total_amt)
		INTO totalglamt
		FROM
			bil_feedtl
		WHERE
			caseno = pcaseno
			AND
			pfincode = 'CIVC';
		UPDATE bil_feemst
		SET
			tot_gl_amt = totalglamt
		WHERE
			caseno = pcaseno;
		SELECT
			SUM (total_amt)
		INTO totalglamt
		FROM
			bil_feedtl
		WHERE
			caseno = pcaseno
			AND
			pfincode <> 'CIVC';
		UPDATE bil_feemst
		SET
			credit_amt = totalglamt
		WHERE
			caseno = pcaseno;
		COMMIT WORK;
    --add by kuo 20150326 S995
		IF s995flag > 0 THEN
       --update TOT_GL_AMT,CREDIT_AMT FROM BIL_FEEMST
			UPDATE bil_feemst
			SET
				tot_gl_amt = tot_gl_amt - tot_gl_amt,
				credit_amt = tot_gl_amt
			WHERE
				caseno = pcaseno;
       --update BIL_FEEDTL pfincode = CIVC to S995
			UPDATE bil_feedtl
			SET
				pfincode = 'S995'
			WHERE
				caseno = pcaseno
				AND
				pfincode = 'CIVC';
       --update bil_acnt_wk pfincdoe CIVC to S995
			UPDATE bil_acnt_wk
			SET
				pfincode = 'S995'
			WHERE
				caseno = pcaseno
				AND
				pfincode = 'CIVC';
			COMMIT WORK;
		END IF;
    --add by kuo 20150810 S998 request by 國際醫療
		IF s998flag > 0 THEN
       --update TOT_GL_AMT,CREDIT_AMT FROM BIL_FEEMST
			UPDATE bil_feemst
			SET
				tot_gl_amt = tot_gl_amt - tot_gl_amt,
				credit_amt = tot_gl_amt
			WHERE
				caseno = pcaseno;
       --update BIL_FEEDTL pfincode = CIVC to S995
			UPDATE bil_feedtl
			SET
				pfincode = 'S998'
			WHERE
				caseno = pcaseno
				AND
				pfincode = 'CIVC';
       --update bil_acnt_wk pfincdoe CIVC to S995
			UPDATE bil_acnt_wk
			SET
				pfincode = 'S998'
			WHERE
				caseno = pcaseno
				AND
				pfincode = 'CIVC';
			COMMIT WORK;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END contract_as999;

    --膳食for 1046調整，比照福 by kuo 20171026
	PROCEDURE diet_1046 (
		pcaseno VARCHAR2
	) IS
		CURSOR get_diet_acntwk_date IS
		SELECT DISTINCT
			bildate
		FROM
			bil_acnt_wk
		WHERE
			caseno = pcaseno
			AND
			fee_kind = '02'
			AND
			(clerk = 'DDAILY'
         --OR PRICE_CODE='DITPE001')
			 OR
			 price_code LIKE 'DITPE%') --20170912有新增DITPE開頭給精神科使用的碼，為更改依據 by kuo
         --AND SUBSTR(PRICE_CODE,1,4) in ('DITP','DITI')  --三餐
         --AND SUBSTR(PRICE_CODE,5,1) in ('A','B','C','D') --三餐全，早午晚
         --AND (SUBSTR(PRICE_CODE, 5, 3) NOT IN ('TCM') OR --排除陪客餐
         --     SUBSTR(PRICE_CODE, 1, 4) NOT IN ('DITG'))
         --AND BILDATE > TO_DATE('20121231','YYYYMMDD') 
		ORDER BY
			bildate;
		CURSOR get_acnk_wk (
			pbildate DATE
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			caseno = pcaseno
			AND
			fee_kind = '02'
			AND
			clerk = 'DDAILY'
         --AND SUBSTR(PRICE_CODE,1,4) IN ('DITP','DITI')  --三餐
         --AND SUBSTR(PRICE_CODE,5,1) in ('A','B','C','D') --三餐全，早午晚
         --AND (SUBSTR(PRICE_CODE, 5, 3) NOT IN ('TCM') OR --排除陪客餐
         --     SUBSTR(PRICE_CODE, 1, 4) NOT IN ('DITG'))
			AND
			bildate = pbildate;
		CURSOR get_diet_kind (
			pbildate DATE
		) IS
		SELECT
			b.pfincode
		FROM
			bil_acnt_wk   a,
			bil_dietset   b
		WHERE
			a.caseno = pcaseno
			AND
			a.price_code = b.pfkey
			AND
			a.fee_kind = '02'
			AND
			a.clerk = 'DDAILY'
         --AND SUBSTR(A.PRICE_CODE,1,4) IN ('DITP','DITI')  --三餐
         --AND SUBSTR(A.PRICE_CODE,5,1) IN ('A','B','C','D') --三餐全，早午晚
         --AND (SUBSTR(A.PRICE_CODE, 5, 3) NOT IN ('TCM') OR --排除陪客餐
         --     SUBSTR(A.PRICE_CODE, 1, 4) NOT IN ('DITG'))
			AND
			a.bildate = pbildate;
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		acntwk_rec       bil_acnt_wk%rowtype;
		bilrootrec       bil_root%rowtype;
		feerec           bil_feedtl%rowtype;
		vtot_gl_amt      NUMBER;
		diet_date        DATE;
		totalsum         NUMBER;
		nhi4self         NUMBER;
		nhiapply         NUMBER;
		maxacntseq       NUMBER;
		v_lastdate       DATE;
		v_day            NUMBER;
		v_fincode        VARCHAR2 (10);
		diet_kind        VARCHAR2 (4);
		tdiet_kind       VARCHAR2 (4);
		applyflag        VARCHAR2 (01);
		pfincl           VARCHAR2 (04);
		c1046cnt         NUMBER;
	BEGIN
		v_program_name   := 'biling_calculate_PKG.DIET_1046';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		c1046cnt         := 0;
		SELECT
			COUNT (*)
		INTO c1046cnt
		FROM
			bil_contr
		WHERE
			caseno = pcaseno
			AND
			bilcunit = '1046';
		IF c1046cnt = 0 THEN --not 1046
			return;
		END IF;
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			caseno = pcaseno;
		OPEN get_diet_acntwk_date;
		LOOP
			<< xxx_diet >> FETCH get_diet_acntwk_date INTO diet_date;
			EXIT WHEN get_diet_acntwk_date%notfound;
			SELECT
				SUM (self_amt * qty * emg_per) --只看自付部份
			INTO totalsum
			FROM
				bil_acnt_wk
			WHERE
				caseno = pcaseno
				AND
				bildate = diet_date
				AND
				fee_kind = '02'
				AND
				clerk = 'DDAILY';
         --AND (SUBSTR(PRICE_CODE, 5, 3) NOT IN ('TCM') OR --排除陪客餐
         --     SUBSTR(PRICE_CODE, 1, 4) NOT IN ('DITG'));
      --NHI3:精神科日間 申報 50,治療伙 160,普通 130        
      --考慮有切身份，這裡判斷改變 BY KUO 1020220
      --IF BILROOTREC.HFINACL='NHI3' THEN 
			SELECT
				SUM (self_amt * qty * emg_per) --只看自付部份
			INTO totalsum
			FROM
				bil_acnt_wk
			WHERE
				caseno = pcaseno
				AND
				bildate = diet_date
				AND
				fee_kind = '02'
				AND
				clerk = 'DDAILY';
         --住診無健保肺結核病特約代碼1046補助方式(住診身份代碼NHI5，就醫序號IC09)：普通飲食支付標準代碼 E4001B 180點/天，
         --治療飲食支付標準代碼 E4002B 200點/天，超出部分由病患自付，免部分負擔，其餘申報方式方式比照全民健康保險相關規定辦理。
         --DBMS_OUTPUT.PUT_LINE('ONHI3:'||DIET_DATE);
			diet_kind   := 'COMM';
			nhiapply    := 180;
			OPEN get_diet_kind (diet_date);
			LOOP
				FETCH get_diet_kind INTO tdiet_kind;
				EXIT WHEN get_diet_kind%notfound;
				IF tdiet_kind = 'TREA' THEN --有一餐為治療伙即為治療伙,NHI3(福)
					diet_kind   := tdiet_kind;
					nhiapply    := 200;
				END IF;
			END LOOP;
			CLOSE get_diet_kind;
			IF totalsum >= nhiapply THEN --超過才申報,不管天數都可以
				SELECT DISTINCT
					e_level
				INTO
					acntwk_rec
				.e_level
				FROM
					bil_acnt_wk
				WHERE
					caseno = pcaseno
					AND
					fee_kind = '02'
					AND
					bildate = diet_date;
            --UPDATE BIL_FEEMST, BIL_FEE_DTL NHI3(福)
				IF acntwk_rec.e_level = '1' THEN
					UPDATE bil_feemst
					SET
						tot_gl_amt = tot_gl_amt - nhiapply,
						emg_exp_amt1 = emg_exp_amt1 + nhiapply
					WHERE
						caseno = pcaseno;
				END IF;
				IF acntwk_rec.e_level = '2' THEN
					UPDATE bil_feemst
					SET
						tot_gl_amt = tot_gl_amt - nhiapply,
						emg_exp_amt2 = emg_exp_amt2 + nhiapply
					WHERE
						caseno = pcaseno;
				END IF;
				IF acntwk_rec.e_level = '3' THEN
					UPDATE bil_feemst
					SET
						tot_gl_amt = tot_gl_amt - nhiapply,
						emg_exp_amt3 = emg_exp_amt3 + nhiapply
					WHERE
						caseno = pcaseno;
				END IF;
				UPDATE bil_feedtl
				SET
					total_amt = total_amt - nhiapply
				WHERE
					caseno = pcaseno
					AND
					fee_type = '02'
					AND
					pfincode = 'CIVC';
				SELECT
					COUNT (*)
				INTO v_day
				FROM
					bil_feedtl
				WHERE
					caseno = pcaseno
					AND
					fee_type = '02'
					AND
					pfincode = 'LABI';
				IF v_day > 0 THEN
					UPDATE bil_feedtl
					SET
						total_amt = total_amt + nhiapply
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'LABI';
				ELSE
					SELECT
						*
					INTO feerec
					FROM
						bil_feedtl
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'CIVC';
					feerec.pfincode    := 'LABI';
					feerec.total_amt   := nhiapply;
					INSERT INTO bil_feedtl VALUES feerec;
				END IF;
            --INSERT BIL_ACNT_WK NHI3(福)
				SELECT
					MAX (acnt_seq) + 1
				INTO maxacntseq
				FROM
					bil_acnt_wk
				WHERE
					caseno = pcaseno;
				OPEN get_acnk_wk (diet_date);
				FETCH get_acnk_wk INTO acntwk_rec;
				IF get_acnk_wk%found THEN
					acntwk_rec.price_code     := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
					acntwk_rec.ins_fee_code   := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
					acntwk_rec.acnt_seq       := maxacntseq;
					acntwk_rec.tqty           := -1;
					acntwk_rec.qty            := -1;
					acntwk_rec.self_amt       := nhiapply;
					acntwk_rec.insu_amt       := 0;
					acntwk_rec.self_flag      := 'N';
					acntwk_rec.pfincode       := 'CIVC';
					acntwk_rec.order_doc      := 'YES';
					INSERT INTO bil_acnt_wk VALUES acntwk_rec;
					IF nhiapply = 180 THEN
						acntwk_rec.ins_fee_code := 'E4001B';
					ELSE
						acntwk_rec.ins_fee_code := 'E4002B';
					END IF;
					acntwk_rec.acnt_seq       := maxacntseq + 1;
					acntwk_rec.tqty           := 1;
					acntwk_rec.qty            := 1;
					acntwk_rec.self_amt       := 0;
					acntwk_rec.insu_amt       := nhiapply;
					acntwk_rec.self_flag      := 'N';
					acntwk_rec.pfincode       := 'LABI';
					acntwk_rec.order_doc      := 'YES';
					INSERT INTO bil_acnt_wk VALUES acntwk_rec;
					COMMIT WORK;
				END IF;
				CLOSE get_acnk_wk;
			ELSE --沒超過可以申報的
          --NULL;
          --有以下情況全天申報:DITIA001-DITIA006(含三餐)001為普通，餘治療
          --改成都可申報 by kuo 20121203
				applyflag := 'Y';
				IF applyflag = 'Y' THEN --可申報
					SELECT DISTINCT
						e_level
					INTO
						acntwk_rec
					.e_level
					FROM
						bil_acnt_wk
					WHERE
						caseno = pcaseno
						AND
						fee_kind = '02'
						AND
						bildate = diet_date;
            --UPDATE BIL_FEEMST, BIL_FEE_DTL NHI3(福),自費比申報少
					IF acntwk_rec.e_level = '1' THEN
               --DBMS_OUTPUT.PUT_LINE('ONHI3: TOTALSUM='||TOTALSUM||',NHIAPPLY='||NHIAPPLY);
						UPDATE bil_feemst
						SET
							tot_gl_amt = tot_gl_amt - totalsum,
							emg_exp_amt1 = emg_exp_amt1 + nhiapply
						WHERE
							caseno = pcaseno;
					END IF;
					IF acntwk_rec.e_level = '2' THEN
						UPDATE bil_feemst
						SET
							tot_gl_amt = tot_gl_amt - totalsum,
							emg_exp_amt2 = emg_exp_amt2 + nhiapply
						WHERE
							caseno = pcaseno;
					END IF;
					IF acntwk_rec.e_level = '3' THEN
						UPDATE bil_feemst
						SET
							tot_gl_amt = tot_gl_amt - totalsum,
							emg_exp_amt3 = emg_exp_amt3 + nhiapply
						WHERE
							caseno = pcaseno;
					END IF;
					UPDATE bil_feedtl
					SET
						total_amt = total_amt - totalsum
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'CIVC';
					SELECT
						COUNT (*)
					INTO v_day
					FROM
						bil_feedtl
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'LABI';
            --DBMS_OUTPUT.PUT_LINE('APPLYFLAG: TOTALSUM='||TOTALSUM||',NHIAPPLY='||NHIAPPLY||',V_DAY='||V_DAY);   
					IF v_day > 0 THEN
						UPDATE bil_feedtl
						SET
							total_amt = total_amt + nhiapply
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'LABI';
					ELSE
						SELECT
							*
						INTO feerec
						FROM
							bil_feedtl
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'CIVC';
						feerec.pfincode    := 'LABI';
              --DBMS_OUTPUT.PUT_LINE('APPLYFLAG: FEEREC.TOTAL_AMT='||FEEREC.TOTAL_AMT);
              --FEEREC.TOTAL_AMT:=TOTALSUM;
						feerec.total_amt   := nhiapply;
              --FEEREC.TOTAL_AMT:=FEEREC.TOTAL_AMT+NHIAPPLY;
						INSERT INTO bil_feedtl VALUES feerec;
					END IF;
            --INSERT BIL_ACNT_WK NHI3(福),自費比申報少
					SELECT
						MAX (acnt_seq) + 1
					INTO maxacntseq
					FROM
						bil_acnt_wk
					WHERE
						caseno = pcaseno;
					OPEN get_acnk_wk (diet_date);
					FETCH get_acnk_wk INTO acntwk_rec;
					IF get_acnk_wk%found THEN
						acntwk_rec.price_code     := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
						acntwk_rec.ins_fee_code   := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
						acntwk_rec.acnt_seq       := maxacntseq;
						acntwk_rec.tqty           := -1;
						acntwk_rec.qty            := -1;
						acntwk_rec.self_amt       := totalsum;
						acntwk_rec.insu_amt       := 0;
						acntwk_rec.self_flag      := 'N';
						acntwk_rec.pfincode       := 'CIVC';
						acntwk_rec.order_doc      := 'NO';
						INSERT INTO bil_acnt_wk VALUES acntwk_rec;
						IF nhiapply = 130 THEN
							acntwk_rec.ins_fee_code := 'F0002C';
						ELSE
							acntwk_rec.ins_fee_code := 'F0003C';
						END IF;
						acntwk_rec.acnt_seq       := maxacntseq + 1;
						acntwk_rec.tqty           := 1;
						acntwk_rec.qty            := 1;
						acntwk_rec.self_amt       := 0;
						acntwk_rec.insu_amt       := nhiapply;
						acntwk_rec.self_flag      := 'N';
						acntwk_rec.pfincode       := 'LABI';
						acntwk_rec.order_doc      := 'NO';
						INSERT INTO bil_acnt_wk VALUES acntwk_rec;
						COMMIT WORK;
					END IF;
					CLOSE get_acnk_wk;
				END IF;
			END IF;--超過才申報,不管天數都可以
         --GOTO XXX_DIET;            
		END LOOP;
		CLOSE get_diet_acntwk_date;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END diet_1046;

  --膳食for職,福,榮調整 BY KUO 20121114
	PROCEDURE diet_nhi346_adjust (
		pcaseno VARCHAR2
	) IS
		CURSOR get_diet_acntwk_date IS
		SELECT DISTINCT
			bildate
		FROM
			bil_acnt_wk
		WHERE
			caseno = pcaseno
			AND
			fee_kind = '02'
			AND
			(clerk = 'DDAILY'
         --OR PRICE_CODE='DITPE001')
			 OR
			 price_code LIKE 'DITPE%') --20170912有新增DITPE開頭給精神科使用的碼，為更改依據 by kuo
         --AND SUBSTR(PRICE_CODE,1,4) in ('DITP','DITI')  --三餐
         --AND SUBSTR(PRICE_CODE,5,1) in ('A','B','C','D') --三餐全，早午晚
         --AND (SUBSTR(PRICE_CODE, 5, 3) NOT IN ('TCM') OR --排除陪客餐
         --     SUBSTR(PRICE_CODE, 1, 4) NOT IN ('DITG'))
         --AND BILDATE > TO_DATE('20121231','YYYYMMDD') 
		ORDER BY
			bildate;
		CURSOR get_acnk_wk (
			pbildate DATE
		) IS
		SELECT
			*
		FROM
			bil_acnt_wk
		WHERE
			caseno = pcaseno
			AND
			fee_kind = '02'
			AND
			clerk = 'DDAILY'
         --AND SUBSTR(PRICE_CODE,1,4) IN ('DITP','DITI')  --三餐
         --AND SUBSTR(PRICE_CODE,5,1) in ('A','B','C','D') --三餐全，早午晚
         --AND (SUBSTR(PRICE_CODE, 5, 3) NOT IN ('TCM') OR --排除陪客餐
         --     SUBSTR(PRICE_CODE, 1, 4) NOT IN ('DITG'))
			AND
			bildate = pbildate;
		CURSOR get_diet_kind (
			pbildate DATE
		) IS
		SELECT
			b.pfincode
		FROM
			bil_acnt_wk   a,
			bil_dietset   b
		WHERE
			a.caseno = pcaseno
			AND
			a.price_code = b.pfkey
			AND
			a.fee_kind = '02'
			AND
			a.clerk = 'DDAILY'
         --AND SUBSTR(A.PRICE_CODE,1,4) IN ('DITP','DITI')  --三餐
         --AND SUBSTR(A.PRICE_CODE,5,1) IN ('A','B','C','D') --三餐全，早午晚
         --AND (SUBSTR(A.PRICE_CODE, 5, 3) NOT IN ('TCM') OR --排除陪客餐
         --     SUBSTR(A.PRICE_CODE, 1, 4) NOT IN ('DITG'))
			AND
			a.bildate = pbildate;
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		acntwk_rec       bil_acnt_wk%rowtype;
		bilrootrec       bil_root%rowtype;
		feerec           bil_feedtl%rowtype;
		vtot_gl_amt      NUMBER;
		diet_date        DATE;
		totalsum         NUMBER;
		nhi4self         NUMBER;
		nhiapply         NUMBER;
		maxacntseq       NUMBER;
		v_lastdate       DATE;
		v_day            NUMBER;
		v_fincode        VARCHAR2 (10);
		diet_kind        VARCHAR2 (4);
		tdiet_kind       VARCHAR2 (4);
		applyflag        VARCHAR2 (01);
		pfincl           VARCHAR2 (04);
	BEGIN
		v_program_name   := 'biling_calculate_PKG.DIET_NHI346_ADJUST';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
    --考慮到有切身份的問題，不使用 BY KUO 1020220
    --IF BILROOTREC.HFINACL NOT IN ('NHI3','NHI4','NHI6') THEN
    --   RETURN;
    --END IF;
		SELECT
			*
		INTO bilrootrec
		FROM
			bil_root
		WHERE
			caseno = pcaseno;
		OPEN get_diet_acntwk_date;
		LOOP
			<< xxx_diet >> FETCH get_diet_acntwk_date INTO diet_date;
			EXIT WHEN get_diet_acntwk_date%notfound;
      --考慮有切身份，換在這裡判斷 BY KUO 1020220
			pfincl := f_getnhrangeflag (pcaseno, diet_date, '2');
      --DBMS_OUTPUT.PUT_LINE(DIET_DATE||':'||PFINCL);
			IF pfincl NOT IN (
				'NHI3',
				'NHI4',
				'NHI6'
			) THEN
				GOTO xxx_diet;
			END IF;
			SELECT
				SUM (self_amt * qty * emg_per) --只看自付部份
			INTO totalsum
			FROM
				bil_acnt_wk
			WHERE
				caseno = pcaseno
				AND
				bildate = diet_date
				AND
				fee_kind = '02'
				AND
				clerk = 'DDAILY';
         --AND (SUBSTR(PRICE_CODE, 5, 3) NOT IN ('TCM') OR --排除陪客餐
         --     SUBSTR(PRICE_CODE, 1, 4) NOT IN ('DITG'));
      --NHI3:精神科日間 申報 50,治療伙 160,普通 130        
      --考慮有切身份，這裡判斷改變 BY KUO 1020220
      --IF BILROOTREC.HFINACL='NHI3' THEN 
			IF pfincl = 'NHI3' THEN
				SELECT
					SUM (self_amt * qty * emg_per) --只看自付部份
				INTO totalsum
				FROM
					bil_acnt_wk
				WHERE
					caseno = pcaseno
					AND
					bildate = diet_date
            --AND PRICE_CODE='DITPE001';
					AND
					price_code LIKE 'DITPE%'; --20170912有新增DITPE開頭給精神科使用的碼，為更改依據 by kuo
				SELECT
					COUNT (*)
				INTO v_day
				FROM
					bil_acnt_wk
				WHERE
					caseno = pcaseno
             --AND PRICE_CODE='DITPE001'
					AND
					price_code LIKE 'DITPE%' --20170912有新增DITPE開頭給精神科使用的碼，為更改依據 by kuo
					AND
					bildate = diet_date;
				IF v_day = 1 AND totalsum > 0 THEN --NHI3 精神科日間 申報 50
            --DBMS_OUTPUT.PUT_LINE('IN PDW ONHI3:'||DIET_DATE||',TOTALSUM:'||TOTALSUM);
					SELECT
						*
					INTO acntwk_rec
					FROM
						bil_acnt_wk
					WHERE
						caseno = pcaseno
               --AND PRICE_CODE='DITPE001'
						AND
						price_code LIKE 'DITPE%' --20170912有新增DITPE開頭給精神科使用的碼，為更改依據 by kuo
						AND
						bildate = diet_date;
					UPDATE bil_acnt_wk
					SET
						self_amt = self_amt - 50
					WHERE
						caseno = pcaseno
						AND
						acnt_seq = acntwk_rec.acnt_seq;
					COMMIT WORK;
					SELECT
						MAX (acnt_seq) + 1
					INTO maxacntseq
					FROM
						bil_acnt_wk
					WHERE
						caseno = pcaseno;
					acntwk_rec.acnt_seq    := maxacntseq;
					acntwk_rec.self_amt    := 0;
					acntwk_rec.insu_amt    := 50;
					acntwk_rec.self_flag   := 'N';
					acntwk_rec.pfincode    := 'LABI';
					INSERT INTO bil_acnt_wk VALUES acntwk_rec;
					COMMIT WORK;
            --UPDATE BIL_FEEMST, BIL_FEE_DTL
					IF acntwk_rec.e_level = '1' THEN
						UPDATE bil_feemst
						SET
							tot_gl_amt = tot_gl_amt - 50,
							emg_exp_amt1 = emg_exp_amt1 + 50
						WHERE
							caseno = pcaseno;
					END IF;
					IF acntwk_rec.e_level = '2' THEN
						UPDATE bil_feemst
						SET
							tot_gl_amt = tot_gl_amt - 50,
							emg_exp_amt2 = emg_exp_amt2 + 50
						WHERE
							caseno = pcaseno;
					END IF;
					IF acntwk_rec.e_level = '3' THEN
						UPDATE bil_feemst
						SET
							tot_gl_amt = tot_gl_amt - 50,
							emg_exp_amt3 = emg_exp_amt3 + 50
						WHERE
							caseno = pcaseno;
					END IF;
					UPDATE bil_feedtl
					SET
						total_amt = total_amt - 50
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'CIVC';
					SELECT
						COUNT (*)
					INTO v_day
					FROM
						bil_feedtl
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'LABI';
					IF v_day > 0 THEN
						UPDATE bil_feedtl
						SET
							total_amt = total_amt + 50
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'LABI';
					ELSE
						SELECT
							*
						INTO feerec
						FROM
							bil_feedtl
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'CIVC';
						feerec.pfincode    := 'LABI';
						feerec.total_amt   := 50;
						INSERT INTO bil_feedtl VALUES feerec;
						COMMIT WORK;
					END IF;
					GOTO xxx_diet;
				END IF;--NHI3 精神科日間 申報 50 END
				SELECT
					SUM (self_amt * qty * emg_per) --只看自付部份
				INTO totalsum
				FROM
					bil_acnt_wk
				WHERE
					caseno = pcaseno
					AND
					bildate = diet_date
					AND
					fee_kind = '02'
					AND
					clerk = 'DDAILY';
         --NHI3治療伙 160,普通 130 判斷 這裡就只調整 BIL_FEEMST AND BIL_FEEDTL,BIL_ACNT_WK一天一筆
         --DBMS_OUTPUT.PUT_LINE('ONHI3:'||DIET_DATE);
				diet_kind   := 'COMM';
				nhiapply    := 130;
				OPEN get_diet_kind (diet_date);
				LOOP
					FETCH get_diet_kind INTO tdiet_kind;
					EXIT WHEN get_diet_kind%notfound;
					IF tdiet_kind = 'TREA' THEN --有一餐為治療伙即為治療伙,NHI3(福)
						diet_kind   := tdiet_kind;
						nhiapply    := 160;
					END IF;
				END LOOP;
				CLOSE get_diet_kind;
				IF totalsum >= nhiapply THEN --超過才申報,不管天數都可以
					SELECT DISTINCT
						e_level
					INTO
						acntwk_rec
					.e_level
					FROM
						bil_acnt_wk
					WHERE
						caseno = pcaseno
						AND
						fee_kind = '02'
						AND
						bildate = diet_date;
            --UPDATE BIL_FEEMST, BIL_FEE_DTL NHI3(福)
					IF acntwk_rec.e_level = '1' THEN
						UPDATE bil_feemst
						SET
							tot_gl_amt = tot_gl_amt - nhiapply,
							emg_exp_amt1 = emg_exp_amt1 + nhiapply
						WHERE
							caseno = pcaseno;
					END IF;
					IF acntwk_rec.e_level = '2' THEN
						UPDATE bil_feemst
						SET
							tot_gl_amt = tot_gl_amt - nhiapply,
							emg_exp_amt2 = emg_exp_amt2 + nhiapply
						WHERE
							caseno = pcaseno;
					END IF;
					IF acntwk_rec.e_level = '3' THEN
						UPDATE bil_feemst
						SET
							tot_gl_amt = tot_gl_amt - nhiapply,
							emg_exp_amt3 = emg_exp_amt3 + nhiapply
						WHERE
							caseno = pcaseno;
					END IF;
					UPDATE bil_feedtl
					SET
						total_amt = total_amt - nhiapply
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'CIVC';
					SELECT
						COUNT (*)
					INTO v_day
					FROM
						bil_feedtl
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'LABI';
					IF v_day > 0 THEN
						UPDATE bil_feedtl
						SET
							total_amt = total_amt + nhiapply
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'LABI';
					ELSE
						SELECT
							*
						INTO feerec
						FROM
							bil_feedtl
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'CIVC';
						feerec.pfincode    := 'LABI';
						feerec.total_amt   := nhiapply;
						INSERT INTO bil_feedtl VALUES feerec;
					END IF;
            --INSERT BIL_ACNT_WK NHI3(福)
					SELECT
						MAX (acnt_seq) + 1
					INTO maxacntseq
					FROM
						bil_acnt_wk
					WHERE
						caseno = pcaseno;
					OPEN get_acnk_wk (diet_date);
					FETCH get_acnk_wk INTO acntwk_rec;
					IF get_acnk_wk%found THEN
						acntwk_rec.price_code     := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
						acntwk_rec.ins_fee_code   := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
						acntwk_rec.acnt_seq       := maxacntseq;
						acntwk_rec.tqty           := -1;
						acntwk_rec.qty            := -1;
						acntwk_rec.self_amt       := nhiapply;
						acntwk_rec.insu_amt       := 0;
						acntwk_rec.self_flag      := 'N';
						acntwk_rec.pfincode       := 'CIVC';
						acntwk_rec.order_doc      := 'YES';
						INSERT INTO bil_acnt_wk VALUES acntwk_rec;
						IF nhiapply = 130 THEN
							acntwk_rec.ins_fee_code := 'F0002C';
						ELSE
							acntwk_rec.ins_fee_code := 'F0003C';
						END IF;
						acntwk_rec.acnt_seq       := maxacntseq + 1;
						acntwk_rec.tqty           := 1;
						acntwk_rec.qty            := 1;
						acntwk_rec.self_amt       := 0;
						acntwk_rec.insu_amt       := nhiapply;
						acntwk_rec.self_flag      := 'N';
						acntwk_rec.pfincode       := 'LABI';
						acntwk_rec.order_doc      := 'YES';
						INSERT INTO bil_acnt_wk VALUES acntwk_rec;
						COMMIT WORK;
					END IF;
					CLOSE get_acnk_wk;
				ELSE --沒超過可以申報的
          --NULL;
          --有以下情況全天申報:DITIA001-DITIA006(含三餐)001為普通，餘治療
          --改成都可申報 by kuo 20121203
					applyflag := 'Y';
          /*
          SELECT COUNT(*)
           INTO V_DAY
           FROM BIL_ACNT_WK
           WHERE CASENO=PCASENO
             AND PRICE_CODE IN ('DITIB002','DITIC002','DITID002','DITIB003','DITIC003','DITID004','DITIB004','DITIC004','DITID004','DITIB005','DITIC005','DITID005','DITIB006','DITIC006','DITID006')
             AND BILDATE=DIET_DATE;
          IF V_DAY > 0 THEN --治療伙判斷
             NHIAPPLY:=160;
             APPLYFLAG:='Y';
          ELSE   --普通伙
             SELECT COUNT(*)
               INTO V_DAY
               FROM BIL_ACNT_WK
              WHERE CASENO=PCASENO
                AND PRICE_CODE IN ('DITIB001','DITIC001','DITID001')
                AND BILDATE=DIET_DATE;
             IF V_DAY > 0 THEN
                APPLYFLAG:='Y';
             END IF;   
          END IF;
          */
					IF applyflag = 'Y' THEN --可申報
						SELECT DISTINCT
							e_level
						INTO
							acntwk_rec
						.e_level
						FROM
							bil_acnt_wk
						WHERE
							caseno = pcaseno
							AND
							fee_kind = '02'
							AND
							bildate = diet_date;
            --UPDATE BIL_FEEMST, BIL_FEE_DTL NHI3(福),自費比申報少
						IF acntwk_rec.e_level = '1' THEN
               --DBMS_OUTPUT.PUT_LINE('ONHI3: TOTALSUM='||TOTALSUM||',NHIAPPLY='||NHIAPPLY);
							UPDATE bil_feemst
							SET
								tot_gl_amt = tot_gl_amt - totalsum,
								emg_exp_amt1 = emg_exp_amt1 + nhiapply
							WHERE
								caseno = pcaseno;
						END IF;
						IF acntwk_rec.e_level = '2' THEN
							UPDATE bil_feemst
							SET
								tot_gl_amt = tot_gl_amt - totalsum,
								emg_exp_amt2 = emg_exp_amt2 + nhiapply
							WHERE
								caseno = pcaseno;
						END IF;
						IF acntwk_rec.e_level = '3' THEN
							UPDATE bil_feemst
							SET
								tot_gl_amt = tot_gl_amt - totalsum,
								emg_exp_amt3 = emg_exp_amt3 + nhiapply
							WHERE
								caseno = pcaseno;
						END IF;
						UPDATE bil_feedtl
						SET
							total_amt = total_amt - totalsum
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'CIVC';
						SELECT
							COUNT (*)
						INTO v_day
						FROM
							bil_feedtl
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'LABI';
            --DBMS_OUTPUT.PUT_LINE('APPLYFLAG: TOTALSUM='||TOTALSUM||',NHIAPPLY='||NHIAPPLY||',V_DAY='||V_DAY);   
						IF v_day > 0 THEN
							UPDATE bil_feedtl
							SET
								total_amt = total_amt + nhiapply
							WHERE
								caseno = pcaseno
								AND
								fee_type = '02'
								AND
								pfincode = 'LABI';
						ELSE
							SELECT
								*
							INTO feerec
							FROM
								bil_feedtl
							WHERE
								caseno = pcaseno
								AND
								fee_type = '02'
								AND
								pfincode = 'CIVC';
							feerec.pfincode    := 'LABI';
              --DBMS_OUTPUT.PUT_LINE('APPLYFLAG: FEEREC.TOTAL_AMT='||FEEREC.TOTAL_AMT);
              --FEEREC.TOTAL_AMT:=TOTALSUM;
							feerec.total_amt   := nhiapply;
              --FEEREC.TOTAL_AMT:=FEEREC.TOTAL_AMT+NHIAPPLY;
							INSERT INTO bil_feedtl VALUES feerec;
						END IF;
            --INSERT BIL_ACNT_WK NHI3(福),自費比申報少
						SELECT
							MAX (acnt_seq) + 1
						INTO maxacntseq
						FROM
							bil_acnt_wk
						WHERE
							caseno = pcaseno;
						OPEN get_acnk_wk (diet_date);
						FETCH get_acnk_wk INTO acntwk_rec;
						IF get_acnk_wk%found THEN
							acntwk_rec.price_code     := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
							acntwk_rec.ins_fee_code   := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
							acntwk_rec.acnt_seq       := maxacntseq;
							acntwk_rec.tqty           := -1;
							acntwk_rec.qty            := -1;
							acntwk_rec.self_amt       := totalsum;
							acntwk_rec.insu_amt       := 0;
							acntwk_rec.self_flag      := 'N';
							acntwk_rec.pfincode       := 'CIVC';
							acntwk_rec.order_doc      := 'NO';
							INSERT INTO bil_acnt_wk VALUES acntwk_rec;
							IF nhiapply = 130 THEN
								acntwk_rec.ins_fee_code := 'F0002C';
							ELSE
								acntwk_rec.ins_fee_code := 'F0003C';
							END IF;
							acntwk_rec.acnt_seq       := maxacntseq + 1;
							acntwk_rec.tqty           := 1;
							acntwk_rec.qty            := 1;
							acntwk_rec.self_amt       := 0;
							acntwk_rec.insu_amt       := nhiapply;
							acntwk_rec.self_flag      := 'N';
							acntwk_rec.pfincode       := 'LABI';
							acntwk_rec.order_doc      := 'NO';
							INSERT INTO bil_acnt_wk VALUES acntwk_rec;
							COMMIT WORK;
						END IF;
						CLOSE get_acnk_wk;
					END IF;
				END IF;--超過才申報,不管天數都可以
				GOTO xxx_diet;
			END IF;--NHI3
      --NHI6 30天內半數(80,65申報)
      --考慮有切身份，這裡判斷改變 BY KUO 1020220
      --IF BILROOTREC.HFINACL='NHI6' THEN
			IF pfincl = 'NHI6' THEN
				SELECT DISTINCT
					e_level
				INTO
					acntwk_rec
				.e_level
				FROM
					bil_acnt_wk
				WHERE
					caseno = pcaseno
					AND
					fee_kind = '02'
					AND
					bildate = diet_date
					AND
					ROWNUM = 1;
				IF acntwk_rec.e_level = '1' THEN
            --判斷哪個扣80,哪個扣65, NHI6
					diet_kind   := 'COMM';
					nhiapply    := 65;
					OPEN get_diet_kind (diet_date);
					LOOP
						FETCH get_diet_kind INTO tdiet_kind;
						EXIT WHEN get_diet_kind%notfound;
						IF tdiet_kind = 'TREA' THEN --有一餐為治療伙即為治療伙 NHI6
							diet_kind   := tdiet_kind;
							nhiapply    := 80;
						END IF;
					END LOOP;
					CLOSE get_diet_kind;
            --UPDATE FEEMST AND FEEDTL NHI6
					SELECT
						total_amt
					INTO vtot_gl_amt
					FROM
						bil_feedtl
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'CIVC';
             --避免扣成負的 BY KUO 20130510
             --DBMS_OUTPUT.PUT_LINE('NHIAPPLY:'||NHIAPPLY||',VTOT_GL_AMT='||VTOT_GL_AMT);
					IF nhiapply > vtot_gl_amt THEN
						nhiapply := vtot_gl_amt;
					END IF;
					UPDATE bil_feemst
					SET
						tot_gl_amt = tot_gl_amt - nhiapply,
						emg_exp_amt1 = emg_exp_amt1 + nhiapply
					WHERE
						caseno = pcaseno;
					UPDATE bil_feedtl
					SET
						total_amt = total_amt - nhiapply
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'CIVC';
					SELECT
						COUNT (*)
					INTO v_day
					FROM
						bil_feedtl
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'LABI';
					IF v_day > 0 THEN
						UPDATE bil_feedtl
						SET
							total_amt = total_amt + nhiapply
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'LABI';
					ELSE
						SELECT
							*
						INTO feerec
						FROM
							bil_feedtl
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'CIVC';
						feerec.pfincode    := 'LABI';
						feerec.total_amt   := nhiapply;
						INSERT INTO bil_feedtl VALUES feerec;
					END IF;    
            --INSERT BIL_ACNT_WK NHI6
					SELECT
						MAX (acnt_seq) + 1
					INTO maxacntseq
					FROM
						bil_acnt_wk
					WHERE
						caseno = pcaseno;
					OPEN get_acnk_wk (diet_date);
					FETCH get_acnk_wk INTO acntwk_rec;
					IF get_acnk_wk%found THEN
						acntwk_rec.price_code     := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
						acntwk_rec.ins_fee_code   := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
						acntwk_rec.acnt_seq       := maxacntseq;
						acntwk_rec.tqty           := -1;
						acntwk_rec.qty            := -1;
						acntwk_rec.self_amt       := nhiapply;
						acntwk_rec.insu_amt       := 0;
						acntwk_rec.self_flag      := 'N';
						acntwk_rec.pfincode       := 'CIVC';
						INSERT INTO bil_acnt_wk VALUES acntwk_rec;
						IF nhiapply = 65 THEN
							acntwk_rec.ins_fee_code := 'G0001C';
						ELSE
							acntwk_rec.ins_fee_code := 'G0002C';
						END IF;
						acntwk_rec.acnt_seq       := maxacntseq + 1;
						acntwk_rec.tqty           := 1;
						acntwk_rec.qty            := 1;
						acntwk_rec.self_amt       := 0;
						acntwk_rec.insu_amt       := nhiapply;
						acntwk_rec.self_flag      := 'N';
						acntwk_rec.pfincode       := 'LABI';
						INSERT INTO bil_acnt_wk VALUES acntwk_rec;
						COMMIT WORK;
					END IF;
					CLOSE get_acnk_wk;
				END IF;
				GOTO xxx_diet;
			END IF;--NHI6 30天內半數(80,65申報) END
      --就養榮民,調整BIL_FEEMST與BIL_FEEDTL,BIL_ACNT_WK一天一筆
			IF f_checknhdiet (bilrootrec.caseno) = 'Y' THEN
         --依天數向榮家申報 自付:A1=144,A2=139,A3=135,A4=130
				v_lastdate   := last_day (diet_date);
				v_day        := to_number (TO_CHAR (v_lastdate, 'dd'));
				IF v_day = 28 THEN
					nhi4self := 144;
				END IF;
				IF v_day = 29 THEN
					nhi4self := 139;
				END IF;
				IF v_day = 30 THEN
					nhi4self := 135;
				END IF;
				IF v_day = 31 THEN
					nhi4self := 130;
				END IF;
				IF totalsum > nhi4self THEN
					UPDATE bil_feemst
					SET
						tot_gl_amt = tot_gl_amt - totalsum + nhi4self
					WHERE
						caseno = pcaseno;
					UPDATE bil_feedtl
					SET
						total_amt = total_amt - totalsum + nhi4self
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'CIVC';
					SELECT
						COUNT (*)
					INTO v_day
					FROM
						bil_feedtl
					WHERE
						caseno = pcaseno
						AND
						fee_type = '02'
						AND
						pfincode = 'VERN';
					IF v_day > 0 THEN
						UPDATE bil_feedtl
						SET
							total_amt = total_amt + (totalsum - nhi4self)
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'VERN';
					ELSE
						SELECT
							*
						INTO feerec
						FROM
							bil_feedtl
						WHERE
							caseno = pcaseno
							AND
							fee_type = '02'
							AND
							pfincode = 'CIVC';
						feerec.pfincode    := 'VERN';
						feerec.total_amt   := totalsum - nhi4self;
						INSERT INTO bil_feedtl VALUES feerec;
						COMMIT WORK;
					END IF;
					SELECT
						MAX (acnt_seq) + 1
					INTO maxacntseq
					FROM
						bil_acnt_wk
					WHERE
						caseno = pcaseno;
					OPEN get_acnk_wk (diet_date);
					FETCH get_acnk_wk INTO acntwk_rec;
					IF get_acnk_wk%found THEN
						acntwk_rec.price_code     := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
						acntwk_rec.ins_fee_code   := substr (acntwk_rec.price_code, 1, 4) || 'A' || substr (acntwk_rec.price_code, 6, 3);
						acntwk_rec.acnt_seq       := maxacntseq;
						acntwk_rec.tqty           := -1;
						acntwk_rec.qty            := -1;
						acntwk_rec.self_amt       := totalsum - nhi4self;
						acntwk_rec.insu_amt       := 0;
						acntwk_rec.self_flag      := 'N';
						acntwk_rec.pfincode       := 'CIVC';
						INSERT INTO bil_acnt_wk VALUES acntwk_rec;
						acntwk_rec.ins_fee_code   := '';
						acntwk_rec.acnt_seq       := maxacntseq + 1;
						acntwk_rec.tqty           := 1;
						acntwk_rec.qty            := 1;
						acntwk_rec.self_amt       := 0;
						acntwk_rec.insu_amt       := 0;
						acntwk_rec.part_amt       := totalsum - nhi4self;
						acntwk_rec.self_flag      := 'N';
						acntwk_rec.pfincode       := 'VERN';
						INSERT INTO bil_acnt_wk VALUES acntwk_rec;
						COMMIT WORK;
					END IF;
					CLOSE get_acnk_wk;
				ELSE  --NHI4不足部份未討論
					NULL;
				END IF;
			END IF;--就養榮民,調整BIL_FEEMST與BIL_FEEDTL END
		END LOOP;
		CLOSE get_diet_acntwk_date;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END diet_nhi346_adjust;  

  --高危險妊娠註記 by Kuo 20131104
  --所有住院診斷費都要改成DIAG2024
  --before CompAcntWWk
	PROCEDURE diag_2024 (
		pcaseno VARCHAR2
	) IS
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		price            NUMBER;
		vhrp_yn          common.pat_adm_case.hrp_yn%TYPE;
	BEGIN
		v_program_name   := 'biling_calculate_PKG.DIAG_2024';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		SELECT
			pfprice1
		INTO price
		FROM
			cpoe.dbpfile
		WHERE
			pfkey = 'DIAG2024';
		vhrp_yn          := 'N';
    --判斷是否高危險妊娠註記 Start by Kuo 20131104
		SELECT
			hrp_yn
		INTO vhrp_yn
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = pcaseno;
    --判斷是否高危險妊娠註記 End
    --dbms_output.put_line('HRP_YN='||VHRP_YN);
		IF vhrp_yn = 'Y' THEN
			UPDATE bil_occur
			SET
				pf_key = 'DIAG2024',
				charge_amount = price
			WHERE
				caseno = pcaseno
				AND
				pf_key LIKE 'DIAG%'
				AND
				operator_name = 'dailyBatch';
			COMMIT WORK;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			ROLLBACK WORK;
			DELETE FROM biling_spl_errlog
			WHERE
				session_id = v_session_id
				AND
				prog_name = v_program_name;
			INSERT INTO biling_spl_errlog (
				session_id,
				sys_date,
				prog_name,
				err_code,
				err_msg,
				err_info,
				source_seq
			) VALUES (
				v_session_id,
				SYSDATE,
				v_program_name,
				v_error_code,
				v_error_msg,
				v_error_info,
				v_source_seq
			);
			COMMIT WORK;
	END diag_2024;

	-- 設定 1060 算帳身分
	PROCEDURE set_1060_financial (
		i_caseno VARCHAR2
	) IS
	BEGIN
		FOR r IN (
			SELECT
				*
			FROM
				bil_contr
			WHERE
				caseno = i_caseno
				AND
				bilcunit = '1060'
		) LOOP
			INSERT INTO tmp_fincal VALUES (
				r.caseno,
				'LABI',
				r.bilcbgdt,
				r.bilcendt
			);
		END LOOP;
	END;

	-- 調整 1060 帳款分攤
	PROCEDURE adjust_1060_acnt_wk (
		i_caseno VARCHAR2
	) IS
		max_acnt_seq     bil_acnt_wk.acnt_seq%TYPE;
		trea_diet_flag   VARCHAR2 (1);
	BEGIN
		-- 1060 特約生效期間
		FOR r_bil_contr IN (
			SELECT
				*
			FROM
				bil_contr
			WHERE
				caseno = i_caseno
				AND
				bilcunit = '1060'
		) LOOP 
			-- 健保金額調至 1060 分攤單位
			UPDATE bil_acnt_wk
			SET
				pfincode = '1060',
				part_amt = insu_amt,
				insu_amt = 0
			WHERE
				caseno = r_bil_contr.caseno
				AND
				pfincode = 'LABI'
				AND
				trunc (bildate) BETWEEN r_bil_contr.bilcbgdt AND r_bil_contr.bilcendt;	

			-- 每日自費膳食總額
			FOR r_bildate_sum IN (
				SELECT
					caseno,
					bildate,
					SUM (self_amt * emg_per * qty) AS total_amt
				FROM
					bil_acnt_wk
				WHERE
					caseno = r_bil_contr.caseno
					AND
					bildate BETWEEN r_bil_contr.bilcbgdt AND r_bil_contr.bilcendt
					AND
					fee_kind = '02'
					AND
					clerk = 'DDAILY'
					AND
					pfincode = 'CIVC'
				GROUP BY
					caseno,
					bildate
			) LOOP
				-- 當日是否存在治療伙
				SELECT
					CASE
						WHEN COUNT (*) > 0 THEN
							'Y'
						ELSE
							'N'
					END
				INTO trea_diet_flag
				FROM
					bil_dietset
				WHERE
					pfkey IN (
						SELECT
							price_code
						FROM
							bil_acnt_wk
						WHERE
							caseno = r_bildate_sum.caseno
							AND
							bildate = r_bildate_sum.bildate
							AND
							fee_kind = '02'
							AND
							clerk = 'DDAILY'
					)
					AND
					pfincode = 'TREA';

				-- 每日自費膳食
				FOR r_bil_acnt_wk IN (
					SELECT
						*
					FROM
						bil_acnt_wk
					WHERE
						caseno = r_bildate_sum.caseno
						AND
						bildate = r_bildate_sum.bildate
						AND
						fee_kind = '02'
						AND
						clerk = 'DDAILY'
						AND
						pfincode = 'CIVC'
					ORDER BY
						price_code
				) LOOP
					-- 沖帳自費膳食金額
					SELECT
						MAX (acnt_seq)
					INTO max_acnt_seq
					FROM
						bil_acnt_wk
					WHERE
						caseno = r_bildate_sum.caseno;
					r_bil_acnt_wk.acnt_seq       := max_acnt_seq + 1;
					r_bil_acnt_wk.price_code     := substr (r_bil_acnt_wk.price_code, 1, 4) || 'A' || substr (r_bil_acnt_wk.price_code, 6);
					r_bil_acnt_wk.ins_fee_code   := substr (r_bil_acnt_wk.price_code, 1, 4) || 'A' || substr (r_bil_acnt_wk.price_code, 6);
					r_bil_acnt_wk.tqty           := -1;
					r_bil_acnt_wk.qty            := -1;
					r_bil_acnt_wk.self_amt       := r_bildate_sum.total_amt;
					r_bil_acnt_wk.insu_amt       := 0;
					r_bil_acnt_wk.self_flag      := 'N';
					r_bil_acnt_wk.pfincode       := 'CIVC';
					INSERT INTO bil_acnt_wk VALUES r_bil_acnt_wk;

					-- 申報 1060 膳食金額
					SELECT
						MAX (acnt_seq)
					INTO max_acnt_seq
					FROM
						bil_acnt_wk
					WHERE
						caseno = r_bildate_sum.caseno;
					r_bil_acnt_wk.acnt_seq       := max_acnt_seq + 1;
					r_bil_acnt_wk.price_code     := substr (r_bil_acnt_wk.price_code, 1, 4) || 'A' || substr (r_bil_acnt_wk.price_code, 6);
					r_bil_acnt_wk.ins_fee_code   :=
						CASE
							WHEN trea_diet_flag = 'Y' THEN
								'E4002B'
							ELSE 'E4001B'
						END;
					r_bil_acnt_wk.tqty           := 1;
					r_bil_acnt_wk.qty            := 1;
					r_bil_acnt_wk.part_amt       :=
						CASE
							WHEN trea_diet_flag = 'Y' THEN
								200
							ELSE 180
						END;
					r_bil_acnt_wk.insu_amt       := 0;
					r_bil_acnt_wk.self_flag      := 'N';
					r_bil_acnt_wk.pfincode       := '1060';
					INSERT INTO bil_acnt_wk VALUES r_bil_acnt_wk;

					-- 每日沖帳申報各一筆總額即可
					EXIT;
				END LOOP;
			END LOOP;
		END LOOP;
	END;

	-- 重整費用明細檔
	PROCEDURE recalculate_feedtl (
		i_caseno VARCHAR2
	) IS
		r_bil_feedtl          bil_feedtl%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
	BEGIN
		-- 刪除費用明細檔
		DELETE FROM bil_feedtl
		WHERE
			caseno = i_caseno;

		-- 重新計算寫入費用明細檔
		FOR r_dtl_sum IN (
			SELECT
				caseno,
				fee_kind,
				pfincode,
				round (SUM (nvl (
					CASE
						WHEN pfincode = 'LABI' THEN
							insu_amt
						WHEN pfincode = 'CIVC' THEN
							self_amt
						ELSE
							part_amt
					END, 0) * emg_per * qty)) AS total_amt
			FROM
				bil_acnt_wk
			WHERE
				caseno = i_caseno
			GROUP BY
				caseno,
				fee_kind,
				pfincode
		) LOOP
			r_bil_feedtl                    := NULL;
			r_bil_feedtl.caseno             := r_dtl_sum.caseno;
			r_bil_feedtl.fee_type           := r_dtl_sum.fee_kind;
			r_bil_feedtl.pfincode           := r_dtl_sum.pfincode;
			r_bil_feedtl.total_amt          := r_dtl_sum.total_amt;
			r_bil_feedtl.created_by         := 'biling';
			r_bil_feedtl.creation_date      := SYSDATE;
			r_bil_feedtl.last_updated_by    := r_bil_feedtl.created_by;
			r_bil_feedtl.last_update_date   := r_bil_feedtl.creation_date;
			INSERT INTO bil_feedtl VALUES r_bil_feedtl;
		END LOOP;

		-- 重整部分負擔
		recalculate_copay (i_caseno);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'recalculate_feedtl';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_caseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
	END;

	-- 重整部分負擔
	PROCEDURE recalculate_copay (
		i_hcaseno VARCHAR2
	) IS
		CURSOR c_pf_baserule (
			i_version          VARCHAR2,
			i_rule_base_date   DATE
		) IS
		SELECT
			*
		FROM
			pf_baserule
		WHERE
			version = i_version
			AND
			start_date <= i_rule_base_date
		ORDER BY
			start_date DESC;
		r_pat_adm_case        common.pat_adm_case%rowtype;
		r_bil_root            bil_root%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
		r_pf_baserule         pf_baserule%rowtype;
		r_bil_feedtl          bil_feedtl%rowtype;
		l_rule_base_date      pf_baserule.start_date%TYPE;
		l_copay_per           NUMBER;
		l_copay_lmt1          pf_baserule.emg_pay_lmt1%TYPE;
		l_copay_fee_type      bil_feedtl.fee_type%TYPE;
		l_copay_amt           bil_feedtl.total_amt%TYPE;
		l_pre_copay_amt1      bil_feedtl.total_amt%TYPE;
		l_copay_disc_per      bil_discdtl.insu_per%TYPE;
		l_copay_disc_amt      bil_feedtl.total_amt%TYPE;
	BEGIN
		-- 取得住院主檔
		SELECT
			*
		INTO r_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = i_hcaseno;

		-- 取得帳務主檔
		SELECT
			*
		INTO r_bil_root
		FROM
			bil_root
		WHERE
			caseno = r_pat_adm_case.hcaseno;

		-- 2012-02-08 之後入院的以出院日為比較基準
		IF r_bil_root.admit_date >= TO_DATE ('2012-02-08', 'YYYY-MM-DD') THEN
			l_rule_base_date := trunc (nvl (r_bil_root.dischg_date, SYSDATE));
		ELSE
			l_rule_base_date := trunc (r_bil_root.admit_date);
		END IF;

		-- 取得部分負擔規則
		OPEN c_pf_baserule ('A', l_rule_base_date);
		FETCH c_pf_baserule INTO r_pf_baserule;
		CLOSE c_pf_baserule;

		-- 計算各階段部分負擔金額
		FOR r_labi_sum IN (
			SELECT
				t2.ec_flag,
				t1.e_level,
				SUM (t1.insu_amt * t1.emg_per * t1.qty) AS sum_amt
			FROM
				(
					SELECT
						*
					FROM
						bil_acnt_wk
					WHERE
						pfincode = 'LABI'
						AND
						biling_calculate_pkg.f_getnhrangeflag (caseno, bildate, '2') = 'NHI0'
						AND
						caseno = r_pat_adm_case.hcaseno
				) t1
				LEFT JOIN (
					SELECT
						*
					FROM
						bil_date
					WHERE
						caseno = r_pat_adm_case.hcaseno
				) t2 ON t1.caseno = t2.caseno
				        AND
				        t1.bildate = t2.bil_date
			GROUP BY
				t2.ec_flag,
				t1.e_level
		) LOOP
			l_copay_per        := NULL;
			l_copay_fee_type   := NULL;
			-- 判斷部分負擔比例、費用類別
			IF r_labi_sum.ec_flag = 'E' THEN
				IF r_labi_sum.e_level = '1' THEN
					l_copay_per        := r_pf_baserule.emg_pay_per1 / 100;
					l_copay_fee_type   := '41';
				ELSIF r_labi_sum.e_level = '2' THEN
					l_copay_per        := r_pf_baserule.emg_pay_per2 / 100;
					l_copay_fee_type   := '42';
				ELSIF r_labi_sum.e_level = '3' THEN
					l_copay_per        := r_pf_baserule.emg_pay_per3 / 100;
					l_copay_fee_type   := '43';
				END IF;
			ELSIF r_labi_sum.ec_flag = 'C' THEN
				IF r_labi_sum.e_level = '1' THEN
					l_copay_per        := r_pf_baserule.chron_pay_per1 / 100;
					l_copay_fee_type   := '51';
				ELSIF r_labi_sum.e_level = '2' THEN
					l_copay_per        := r_pf_baserule.chron_pay_per2 / 100;
					l_copay_fee_type   := '52';
				ELSIF r_labi_sum.e_level = '3' THEN
					l_copay_per        := r_pf_baserule.chron_pay_per3 / 100;
					l_copay_fee_type   := '53';
				ELSIF r_labi_sum.e_level = '4' THEN
					l_copay_per        := r_pf_baserule.chron_pay_per4 / 100;
					l_copay_fee_type   := '54';
				END IF;
			END IF;

			-- 計算部分負擔金額
			l_copay_amt        := r_labi_sum.sum_amt * l_copay_per;

			-- 每次住院部分負擔上限（只有第一階段有上限）
			IF r_labi_sum.e_level = '1' THEN
				l_copay_lmt1 := r_pf_baserule.emg_pay_lmt1;

				-- 14 天內再入院視為同次住院
				IF r_pat_adm_case.hreadmit = 'Y' THEN
					FOR r_pre_bil_boot IN (
						SELECT
							*
						FROM
							bil_root
						WHERE
							trunc (dischg_date) - trunc (r_bil_root.admit_date) <= 14
							AND
							caseno != r_bil_root.caseno
							AND
							hpatnum = r_bil_root.hpatnum
						ORDER BY
							dischg_date DESC
					) LOOP
						SELECT
							nvl (emg_pay_amt1, 0) + nvl (chron_pay_amt1, 0)
						INTO l_pre_copay_amt1
						FROM
							bil_feemst
						WHERE
							caseno = r_pre_bil_boot.caseno;

						-- 只取前一次住院記錄
						EXIT;
					END LOOP;

					-- 上限要扣除上次部分負擔金額
					l_copay_lmt1 := l_copay_lmt1 - l_pre_copay_amt1;
				END IF;

				-- 超過上限以上限計
				IF l_copay_amt > l_copay_lmt1 THEN
					l_copay_amt := l_copay_lmt1;
				END IF;
			END IF;

			-- 油症免部分負擔
			IF r_pat_adm_case.projectcode = '901' THEN
				l_copay_amt := 0;
			END IF;

			-- 折扣部分負擔
			FOR r_bil_discdtl IN (
				SELECT
					*
				FROM
					bil_discdtl
				WHERE
					bilkind = 'B'
					AND
					pftype = l_copay_fee_type
					AND
					insu_per != 0
					AND
					bilkey IN (
						SELECT DISTINCT
							fincalcode
						FROM
							tmp_fincal
						WHERE
							caseno = r_pat_adm_case.hcaseno
					)
				ORDER BY
					insu_per DESC
			) LOOP
				l_copay_disc_per   := r_bil_discdtl.insu_per;
				l_copay_disc_amt   := l_copay_amt * l_copay_disc_per;
				IF l_copay_disc_amt != 0 THEN
					r_bil_feedtl                    := NULL;
					r_bil_feedtl.caseno             := r_pat_adm_case.hcaseno;
					r_bil_feedtl.fee_type           := l_copay_fee_type;
					r_bil_feedtl.pfincode           := r_bil_discdtl.bilkey;
					r_bil_feedtl.total_amt          := round (l_copay_disc_amt);
					r_bil_feedtl.created_by         := 'biling';
					r_bil_feedtl.creation_date      := SYSDATE;
					r_bil_feedtl.last_updated_by    := 'biling';
					r_bil_feedtl.last_update_date   := SYSDATE;
					INSERT INTO bil_feedtl VALUES r_bil_feedtl;
					l_copay_amt                     := l_copay_amt - l_copay_disc_amt;
				END IF;

				-- 只取最高折扣比例
				EXIT;
			END LOOP;

			-- 寫入部分負擔金額
			IF l_copay_amt != 0 THEN
				r_bil_feedtl                    := NULL;
				r_bil_feedtl.caseno             := r_pat_adm_case.hcaseno;
				r_bil_feedtl.fee_type           := l_copay_fee_type;
				r_bil_feedtl.pfincode           := 'CIVC';
				r_bil_feedtl.total_amt          := round (l_copay_amt);
				r_bil_feedtl.created_by         := 'biling';
				r_bil_feedtl.creation_date      := SYSDATE;
				r_bil_feedtl.last_updated_by    := 'biling';
				r_bil_feedtl.last_update_date   := SYSDATE;
				INSERT INTO bil_feedtl VALUES r_bil_feedtl;
			END IF;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'recalculate_copay';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_hcaseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
	END;

	-- 重整費用主檔
	PROCEDURE recalculate_feemst (
		i_hcaseno    VARCHAR2,
		i_end_date   DATE
	) IS
		r_pat_adm_case        common.pat_adm_case%rowtype;
		r_bil_root            bil_root%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
		r_bil_feemst          bil_feemst%rowtype;
	BEGIN
		-- 取得住院主檔
		SELECT
			*
		INTO r_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = i_hcaseno;

		-- 取得帳務主檔
		SELECT
			*
		INTO r_bil_root
		FROM
			bil_root
		WHERE
			caseno = r_pat_adm_case.hcaseno;

		-- 刪除費用主檔
		DELETE FROM bil_feemst
		WHERE
			caseno = r_pat_adm_case.hcaseno;

		-- 初始化費用主檔
		r_bil_feemst.caseno             := r_pat_adm_case.hcaseno;
		r_bil_feemst.st_date            := trunc (r_bil_root.admit_date);
		r_bil_feemst.end_date           :=
			CASE
				WHEN i_end_date > trunc (r_bil_root.dischg_date) THEN
					trunc (r_bil_root.dischg_date)
				ELSE trunc (i_end_date)
			END;
		r_bil_feemst.created_by         := 'biling';
		r_bil_feemst.creation_date      := SYSDATE;
		r_bil_feemst.last_updated_by    := r_bil_feemst.created_by;
		r_bil_feemst.last_update_date   := r_bil_feemst.creation_date;

		-- 急性床天數
		SELECT
			COUNT (*)
		INTO
			r_bil_feemst
		.emg_bed_days
		FROM
			bil_date
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			ec_flag = 'E';

		-- 慢性床天數
		SELECT
			COUNT (*)
		INTO
			r_bil_feemst
		.chron_bed_days
		FROM
			bil_date
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			ec_flag = 'C';

		-- 計算急／慢性各階段健保金額
		FOR r_labi_sum IN (
			SELECT
				t2.ec_flag,
				t1.e_level,
				SUM (t1.insu_amt * t1.emg_per * t1.qty) AS sum_amt
			FROM
				(
					SELECT
						*
					FROM
						bil_acnt_wk
					WHERE
						pfincode = 'LABI'
						AND
						caseno = r_pat_adm_case.hcaseno
				) t1
				LEFT JOIN (
					SELECT
						*
					FROM
						bil_date
					WHERE
						caseno = r_pat_adm_case.hcaseno
				) t2 ON t1.caseno = t2.caseno
				        AND
				        t1.bildate = t2.bil_date
			GROUP BY
				t2.ec_flag,
				t1.e_level
		) LOOP IF r_labi_sum.ec_flag = 'E' THEN
			IF r_labi_sum.e_level = '1' THEN
				r_bil_feemst.emg_exp_amt1 := r_labi_sum.sum_amt;
			ELSIF r_labi_sum.e_level = '2' THEN
				r_bil_feemst.emg_exp_amt2 := r_labi_sum.sum_amt;
			ELSIF r_labi_sum.e_level = '3' THEN
				r_bil_feemst.emg_exp_amt3 := r_labi_sum.sum_amt;
			END IF;
		ELSIF r_labi_sum.ec_flag = 'C' THEN
			IF r_labi_sum.e_level = '1' THEN
				r_bil_feemst.chron_exp_amt1 := r_labi_sum.sum_amt;
			ELSIF r_labi_sum.e_level = '2' THEN
				r_bil_feemst.chron_exp_amt2 := r_labi_sum.sum_amt;
			ELSIF r_labi_sum.e_level = '3' THEN
				r_bil_feemst.chron_exp_amt3 := r_labi_sum.sum_amt;
			ELSIF r_labi_sum.e_level = '4' THEN
				r_bil_feemst.chron_exp_amt4 := r_labi_sum.sum_amt;
			END IF;
		END IF;
		END LOOP;

		-- 計算各階段部分負擔
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.emg_pay_amt1
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			fee_type = '41';
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.emg_pay_amt2
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			fee_type = '42';
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.emg_pay_amt3
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			fee_type = '43';
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.chron_pay_amt1
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			fee_type = '51';
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.chron_pay_amt2
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			fee_type = '52';
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.chron_pay_amt3
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			fee_type = '53';
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.chron_pay_amt4
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			fee_type = '54';

		-- 計算自付部分負擔
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.tot_self_amt
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			fee_type IN (
				'41',
				'42',
				'43',
				'51',
				'52',
				'53',
				'54'
			)
			AND
			pfincode = 'CIVC';

		-- 計算自付自費項目
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.tot_gl_amt
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			fee_type NOT IN (
				'41',
				'42',
				'43',
				'51',
				'52',
				'53',
				'54'
			)
			AND
			pfincode = 'CIVC';

		-- 計算特約總額
		SELECT
			SUM (total_amt)
		INTO
			r_bil_feemst
		.credit_amt
		FROM
			bil_feedtl
		WHERE
			caseno = r_bil_feemst.caseno
			AND
			pfincode NOT IN (
				'LABI',
				'CIVC'
			);

		-- 寫入費用主檔
		INSERT INTO bil_feemst VALUES r_bil_feemst;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'recalculate_feemst';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_hcaseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
	END;
END;

/
