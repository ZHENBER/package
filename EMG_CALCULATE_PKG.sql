CREATE OR REPLACE PACKAGE "EMG_CALCULATE_PKG" IS
  --created by Kuo 981029 for EMG Billing
  --main billing caculate package
  --檢傷分級變數 for 新部份負擔 by kuo 20170216
	triage VARCHAR2 (1);
  --急診分攤主要程式
	PROCEDURE main_process (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2
	);

  --急診計算固定費用
	PROCEDURE emgfixfees (
		pcaseno VARCHAR2
	);

  --急診清除計算程式
	PROCEDURE initdata (
		pcaseno VARCHAR2
	);

  --急診展開身份別至身份暫存檔
	PROCEDURE extandfin (
		pcaseno VARCHAR2
	);

  --急診計算醫令明細
	PROCEDURE acntwkcalculate (
		pcaseno VARCHAR2
	);

  --急診整理帳款
	PROCEDURE compacntwk (
		pcaseno   VARCHAR2,
		poper     VARCHAR2
	);

  --急診計算乘數
	PROCEDURE getemgper (
		pcaseno          VARCHAR2, --住院序
		ppfkey           VARCHAR2, --計價碼
		pfeekind         VARCHAR2, --帳檔計價類別
		pemgflag         VARCHAR2, --急作否
		pfncl            VARCHAR2, --身分別
		ptype            VARCHAR2, --回傳成數
		pdate            DATE, --計價日
		emg_per          OUT   NUMBER, --加乘數
		holiday_per      OUT   NUMBER, --假日加成乘數
		night_per        OUT   NUMBER, --夜間加成乘數
		child_per        OUT   NUMBER, --兒童加成乘數
		urgent_per       OUT   NUMBER, --急作加成乘數
		operation_per    OUT   NUMBER, --手術加成乘數
		anesthesia_per   OUT   NUMBER, --麻醉加成乘數
		materials_per    OUT   NUMBER --材料加成乘數
	);
  --RETURN NUMBER;

  --急診調整應收帳款
	PROCEDURE p_receivablecomp (
		pcaseno VARCHAR2
	);

  --急診優待身份別處理
	PROCEDURE p_disfin (
		pcaseno    VARCHAR2,
		pfinacl    VARCHAR2,
		pdiscfin   OUT VARCHAR2
	);

  --急診健保規則調整
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

  --自付因應身份(榮民),特約調整
	PROCEDURE p_modifityselfpay (
		pcaseno      VARCHAR2,
		pfinacl      VARCHAR2,
		v_acnt_seq   INT
	);

  --取得當日身份別
	FUNCTION f_getnhrangeflag (
		pcaseno    VARCHAR2,
		pdate      DATE,
		pfinflag   VARCHAR2
	) RETURN VARCHAR2;

  -- 將HIS上帳款由IMSDB 轉入
	PROCEDURE emgoccurfromimsdb (
		pcaseno VARCHAR2
	);

  --need add考量合併項主項，把合併項的細項取定價及費用類別逐一新增入emg_occur，再將合併項主項刪除
	PROCEDURE p_emgoccurbycase (
		pcaseno VARCHAR2
	);

  --組合項特殊規則cehck
	FUNCTION special_code_check (
		ppfkey VARCHAR2
	) RETURN VARCHAR2;

  --掛號費入帳
	PROCEDURE emgregfee (
		pcaseno VARCHAR2
	);

  --預估帳       
	PROCEDURE poverdueorder (
		pcaseno VARCHAR2
	);

  --急診每日帳款重算(因應醫收需每日結轉,需每日將有發生帳款的CASENO重算)      
	PROCEDURE daily_process;

  --emg_occur備份
	PROCEDURE bkoccur (
		pcaseno VARCHAR2
	);

  --更新欠款檔 - 重算帳款後是否已無欠款或是欠款金額有異動 
	PROCEDURE p_debt_check (
		pcaseno VARCHAR2
	);

  --取得此急診號的seq_no
	FUNCTION f_get_seq_no (
		pcaseno VARCHAR2
	) RETURN VARCHAR2;

  --追蹤預估醫囑
	PROCEDURE t_ovrordlog (
		pcaseno VARCHAR2
	);
  --帳務未拆(自付為0)部份加入 EMG_BIL_ACNT_WK BY KUO 1000601
	PROCEDURE zero_emg_acnkwk (
		pcaseno VARCHAR2
	);

  --急診申報前重算 BY KUO 1000628
	PROCEDURE emg_recalmon (
		pmonth VARCHAR2
	);

  --急診分攤主要程式--強制以健保計算 BY KUO 1000808
	PROCEDURE main_process_labi (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2
	);

  --國際醫療計算用，整個翻新 BY KUO 20121108
	PROCEDURE contract_es999 (
		pcaseno VARCHAR2
	);

  --急診獎勵用 by kuo 20160405
	PROCEDURE hospinout (
		pcaseno VARCHAR2
	);
	FUNCTION get_outhospno (
		pcaseno VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION emg_prize_trn_diagt (
		diagcode1   VARCHAR2,
		diagcode2   VARCHAR2,
		ud          VARCHAR2
	) RETURN VARCHAR2;

    -- 設定 1060 算帳身分
	PROCEDURE set_1060_financial (
		i_ecaseno VARCHAR2
	);

	-- 調整 1060 帳款分攤
	PROCEDURE adjust_1060_acnt_wk (
		i_ecaseno VARCHAR2
	);

    -- 重整費用明細檔
	PROCEDURE recalculate_feedtl (
		i_caseno VARCHAR2
	);

    -- 重整部分負擔
	PROCEDURE recalculate_copay (
		i_ecaseno VARCHAR2
	);

	-- 調整 1060 部分負擔
	PROCEDURE adjust_1060_copay (
		i_ecaseno VARCHAR2
	);

	-- 重整費用主檔
	PROCEDURE recalculate_feemst (
		i_ecaseno    VARCHAR2,
		i_end_date   DATE
	);

	-- 搬急診帳至住院帳（依計價日期）
	PROCEDURE mer_fee_fro_emg_to_adm (
		i_ecaseno          VARCHAR2,
		i_hcaseno          VARCHAR2,
		i_sta_emocdate     DATE,
		i_end_emocdate     DATE,
		i_is_charge_flag   VARCHAR2 DEFAULT 'N',
		o_msg              OUT VARCHAR2
	);

	-- 搬急診帳至住院帳（依醫囑序號）
	PROCEDURE mer_fee_fro_emg_to_adm (
		i_aordseq   IN    VARCHAR2,
		i_eordseq   IN    VARCHAR2,
		o_msg       OUT   VARCHAR2
	);

	-- （待刪除）搬急診帳至住院帳（依醫囑序號）
	PROCEDURE emg_ord2adm_ord_bil (
		aordseq   VARCHAR2,
		eordseq   VARCHAR2
	);

	-- （待刪除）emg_ord2adm_ord_bil 沖帳用
	PROCEDURE emg_minus_occ (
		ecaseno   VARCHAR2,
		pordseq   VARCHAR2
	);
END;

/


CREATE OR REPLACE PACKAGE BODY "EMG_CALCULATE_PKG" IS

  --急診帳款計算主程式段
  --by Kuo 981014 Started
  --SOURCE: EMGOCCUR, PAT_EMG_CASEN(FOR CONTRACT), EMGADJST_MST, EMGADJST_DTL
  --TEMP  : TMP_FINCAL  身份暫存檔
  --OUTPUT: EMG_BIL_ACNT_WK 分攤細項
  --        EMG_BIL_FEE_MST 分攤總和
  --        EMG_BIL_FEE_DTL 分攤分類與身份明細
  --        EMG_BIL_BILLMST 帳單/收費主檔
  --        EMG_BIL_BILLDTL 帳單/收費明細
  --        BIL_DEBITREC欠款使住院相同
  --7(健保),9(民眾),E(有職榮),1(無職榮)
  --急診身份一個身份到底，無分段問題
  --榮民是否需要判斷:common.vtandept
	PROCEDURE main_process (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2
	) IS
    --變數宣告區

    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		emgbildebtrec    emg_bil_debt_rec%rowtype;
		nhis             NUMBER;
		v_count          NUMBER;
		recalculate      VARCHAR2 (1) := 'Y';
	BEGIN
    --增加HIS欠款不重算的判斷(add by amber 20110401)
		BEGIN
			SELECT
				*
			INTO emgbildebtrec
			FROM
				emg_bil_debt_rec
			WHERE
				caseno = pcaseno;
			IF emgbildebtrec.created_by = 'HIS' THEN
				recalculate   := 'N';
				pmessageout   := '前HIS的帳 不算';
			END IF;
			IF emgbildebtrec.created_by = 'No_Calculate' THEN
				recalculate   := 'N';
				pmessageout   := 'No_Calculate';
			END IF;
		EXCEPTION
			WHEN no_data_found THEN
				NULL;
			WHEN OTHERS THEN
				NULL;
		END;
    --前HIS的帳不算<20110215
		SELECT
			COUNT (*)
		INTO nhis
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno
			AND
			emglvdt < TO_DATE ('20110215', 'YYYYMMDD')
			AND
			emglvdt IS NOT NULL;
		IF nhis = 1 THEN
			recalculate   := 'N';
			pmessageout   := '前HIS的帳<20110215 不算';
		END IF;
    --000000000A 不算
 		/*SELECT
			COUNT (*)
		INTO nhis
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno
			AND
			emghhist = '000000000A';
		IF nhis = 1 THEN
			recalculate   := 'N';
			pmessageout   := '000000000A 不算';
		END IF;*/
    --找不到不算 by kuo 20140915
		SELECT
			COUNT (*)
		INTO v_count
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;
		IF v_count = 0 THEN
			recalculate := 'N';
       --PMESSAGEOUT := '無此CASE:'||PCASENO;
		END IF;
		IF recalculate = 'Y' THEN

      --設定程式名稱及session_id
			v_program_name   := 'emg_calculate_PKG.main_process';
			v_session_id     := userenv ('SESSIONID');
			v_source_seq     := trim (pcaseno);

      --在重算前先將該caseno的emg_occur備份
      --dbms_output.put_line('bkOccur');
			bkoccur (trim (pcaseno));

      --check if case not exist, return

      --刪除原有計算資料
      --dbms_output.put_line('initdata');
			initdata (trim (pcaseno));

      --展開身份別
      --dbms_output.put_line('extanfin');
			extandfin (trim (pcaseno));

      --入固定費用到emg_occur
      --dbms_output.put_line('EMGFixFees');
			emgfixfees (trim (pcaseno));

      --預估入賬
      --dbms_output.put_line('pOverDueOrder');
			poverdueorder (trim (pcaseno));

      --從IMSDB 轉入HIS上帳款
      --dbms_output.put_line('emgOccurFromImsdb');
			emgoccurfromimsdb (trim (pcaseno));

      --need add考量合併項主項，把合併項的細項取定價及費用類別逐一新增入emg_occur，再將合併項主項刪除
      --dbms_output.put_line('p_emgOccurByCase');
			p_emgoccurbycase (pcaseno => TRIM (pcaseno));

      		-- 計算計價項目明細檔
			compacntwk (trim (pcaseno), poper);
			contract_es999 (pcaseno);

			-- 重整費用明細檔 
			recalculate_feedtl (pcaseno);

			-- 應收帳款調整
			p_receivablecomp (pcaseno => TRIM (pcaseno));

			-- 重整費用主檔
			recalculate_feemst (pcaseno, SYSDATE);

      --刪掉 EMG_OCCUR是預估入帳
      --將emg_occur預估資料刪除
			DELETE cpoe.emg_occur
			WHERE
				caseno = TRIM (pcaseno)
				AND
				emuserid = 'OVRORDER';

      --更新欠款檔 - 重算帳款後是否已無欠款或是欠款金額有異動(add by amber 20110420)   
			p_debt_check (pcaseno => TRIM (pcaseno));
			COMMIT WORK;
      --預估醫囑追蹤
      --T_OVRORDLOG(pCaseNo);
      --加入自付為0的記錄FOR 醫收
			zero_emg_acnkwk (pcaseno);
			pmessageout      := 'OK';
      --dbms_output.put_line(pmessageout);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := trim (pcaseno);
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			pmessageout    := sqlcode || ',' || sqlerrm;
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
	END; --Main_Process

  ------

  --展開固定費用的計算
  --1151 -- 台中市警察局酒測 全部只能算 400，所有固定費用取消 by kuo 20160201，目前折讓部份不明 ...
  --1151 -- 20160101 開始改為將 90578604 無論哪種狀況都算到 1151 by kuo 20161227
  --1152 -- 彰化縣政府警察局酒測 依實際狀況計算，需算掛號費 by kuo 20160201
  --1152 比照 1151 by kuo 20161227
  --1193 比照 1151 by kuo 20170517
	PROCEDURE emgfixfees (
		pcaseno VARCHAR2
	) IS
		CURSOR cur_disge IS
		SELECT
			*
		FROM
			common.pat_emg_discharge
		WHERE
			ecaseno = pcaseno
			AND
			edisstat IN (
				'L',
				'I',
				'E'
			)
			AND
			canceled = 'N'
		ORDER BY
			edisdt ASC;
		CURSOR cur_dbpfile (
			ppfkey VARCHAR2
		) IS
		SELECT
			*
		FROM
			cpoe.dbpfile
		WHERE
			pfkey = ppfkey;
    --找pfmlog
		CURSOR cur_pfmlog (
			ppfkey   VARCHAR2,
			pdate    DATE
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
					pfmlog.pflprice <> 0
					AND
					pfmlog.pfldbtyp = 'A'
			) --modify by tenya 990923)
			AND
			pfmlog.pfldbtyp = 'A'; --modify by kuo 981221
		pfmlogrec         pfmlog%rowtype;
		patemgcaserec     common.pat_emg_casen%rowtype;
		patemgdisgerec    common.pat_emg_discharge%rowtype;
		emgoccrec         cpoe.emg_occur%rowtype;
		dbpfilerec        cpoe.dbpfile%rowtype;
		v_date            DATE;
		v_enddate         DATE;
		v_max_date        DATE;
		v_day             INTEGER;
		v_cnt             INTEGER;
		v_holiday         VARCHAR2 (01);
		v_degree          VARCHAR2 (01); --檢傷等級
		v_pfkey           VARCHAR2 (12);
		v_udcount         INTEGER; -- 用藥 count
		v_ct_udcount      INTEGER; -- CT 用藥 count
		v_tpn_udcount     INTEGER; -- TPN 用藥 count
		ffix              VARCHAR2 (01);
		l_fward_pfkey     cpoe.dbpfile.pfkey%TYPE; --第一天病房費計價碼要入 WARDER1，其它天入 WARDER
		l_fnurs_pfkey     cpoe.dbpfile.pfkey%TYPE; --第一天護理費計價碼要入 NURSER1，其它天入 NURSER

    --錯誤訊息用途
		v_program_name    VARCHAR2 (80);
		v_session_id      NUMBER (10);
		v_error_code      VARCHAR2 (20);
		v_error_msg       VARCHAR2 (400);
		v_error_info      VARCHAR2 (600);
		v_source_seq      VARCHAR2 (20);
		e_user_exception EXCEPTION;
		pmessage          VARCHAR (1000);
		vemg_pat_source   common.pat_emg_triage.emg_pat_source%TYPE;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'emg_calculate_PKG.EMGFixFees';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		v_cnt            := 0;
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;
		IF patemgcaserec.emglvdt IS NULL THEN
			patemgcaserec.emglvdt := SYSDATE;
		END IF;
		OPEN cur_disge;
		LOOP
			FETCH cur_disge INTO patemgdisgerec;
			EXIT WHEN cur_disge%notfound;
		END LOOP;
		CLOSE cur_disge;

    --刪除相關固定費用，含掛號費、藥師費
		DELETE FROM cpoe.emg_occur
		WHERE
			caseno = pcaseno
			AND
			emchtyp1 IN (
				'01',
				'03',
				'04',
				'05',
				'37'
			)
			AND
			(emuserid IS NULL
			 OR
			 emuserid != 'NHIMOVE');

    --Add 國際醫療服務費 by kuo 20150721 for S995   
		IF patemgcaserec.emgspeu1 IN (
			'S999',
			'S995'
		) THEN
			DELETE FROM cpoe.emg_occur
			WHERE
				caseno = pcaseno
				AND
				emchcode = '91711115'; --91711115, 類別18
		END IF;
		COMMIT WORK;

    --1151 -- 台中市警察局酒測 全部只能算 400，所有固定費用取消 by kuo 20160128，目前折讓部份不明 ...
    --1151,1152 -- 遇到時若是民眾只能入特殊診察費(DIAGALOC),門診掛號費 00000002,90578604,全部算到1151
    --1193 比照 1151 by kuo 20170517
		IF patemgcaserec.emgspeu1 IN (
			'1151',
			'1152',
			'1193'
		) AND patemgcaserec.emg1fncl = '9' THEN
			OPEN cur_dbpfile ('00000002');
			FETCH cur_dbpfile INTO dbpfilerec;
			IF cur_dbpfile%notfound THEN
				dbpfilerec.pfprice1   := 120;
				dbpfilerec.pricety1   := '37';
			END IF;
			CLOSE cur_dbpfile;
			emgoccrec.caseno     := pcaseno;
			emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
			v_cnt                := v_cnt + 1;
			emgoccrec.emocdate   := trunc (patemgcaserec.emgdt);
			emgoccrec.embldate   := trunc (patemgcaserec.emgdt);
			emgoccrec.ordseq     := '0000';
			emgoccrec.emchrgcr   := '+';
			emgoccrec.emchcode   := '00000002';
			emgoccrec.emchtyp1   := dbpfilerec.pricety1;
			emgoccrec.emchqty1   := 1;
			emgoccrec.emchamt1   := dbpfilerec.pfprice1;
			emgoccrec.emchtyp2   := '99';
			emgoccrec.emchtyp4   := '99';
			emgoccrec.emchemg    := 'R';
       --EmgOccRec.EMCHIDEP := patemgcaseRec.EMGNS; --強制收入歸屬科(4 BYTES)
			emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --強制收入歸屬科(4 BYTES)
			emgoccrec.emchstat   := patemgcaserec.emgns; --消耗地點(4 BYTES)
			emgoccrec.card_no    := 'BILLING';
			emgoccrec.emocomb    := 'N';
       --EmgOccRec.EMOCSECT := patemgcaseRec.EMGNS; --計價科別(4 BYTES)
			emgoccrec.emocsect   := patemgcaserec.emgsect; --計價科別(4 BYTES)
			emgoccrec.emocns     := patemgcaserec.emgns; --病房(4 BYTES)
			emgoccrec.emoedept   := patemgcaserec.emgns; --開立科別(4 BYTES, EMG ONLY)
			emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
       --dbms_output.put_line('insert REGISTER to date:'||trunc(patemgcaseRec.EMGDT));
			INSERT INTO cpoe.emg_occur VALUES emgoccrec;
       --add DIAGALOC
			OPEN cur_dbpfile ('DIAGALOC');
			FETCH cur_dbpfile INTO dbpfilerec;
			IF cur_dbpfile%notfound THEN
				dbpfilerec.pfprice1   := 120;
				dbpfilerec.pricety1   := '03';
			END IF;
			CLOSE cur_dbpfile;
			emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
			v_cnt                := v_cnt + 1;
			emgoccrec.emchcode   := 'DIAGALOC';
			emgoccrec.emchtyp1   := dbpfilerec.pricety1;
			emgoccrec.emchqty1   := 1;
			emgoccrec.emchamt1   := dbpfilerec.pfprice1;
			INSERT INTO cpoe.emg_occur VALUES emgoccrec;
			COMMIT WORK;
			return;
		END IF;
		v_date           := trunc (patemgcaserec.emgdt);
		IF patemgdisgerec.edisdt IS NULL THEN
			v_enddate := trunc (SYSDATE);
		ELSE
			v_enddate := trunc (patemgdisgerec.edisdt);
		END IF;
		v_day            := 0;
    --dbms_output.put_line('start date:' || v_date || ' to ' || v_enddate);
		LOOP
      --入固定費用
			EXIT WHEN v_date > v_enddate;
			BEGIN
        --假日加成
				SELECT
					udholdt
				INTO v_holiday
				FROM
					cpoe.udhltbl
				WHERE
					udhdate = v_date;
			EXCEPTION
				WHEN OTHERS THEN
					v_holiday := 'N';
			END;
			ffix     := 'N';
      --入病房費與護理費,算出不算進
      --入院超過8小時才算病房費及護理費
      --出院日大於入院日
			IF v_date <> trunc (patemgcaserec.emglvdt) AND (patemgcaserec.emglvdt - patemgcaserec.emgdt) * 24 >= 6 AND trunc (patemgcaserec
			.emglvdt) > trunc (patemgcaserec.emgdt) THEN
				ffix := 'Y';
				IF patemgcaserec.emgdt > TO_DATE ('20171001', 'YYYYMMDD') THEN --病房與護理費第一天用 by kuo 20171002
					v_day := v_day + 1;
				END IF;
			END IF;
      --且出院日等於入院日且超過8小時-->應該是6小時
			IF v_date = trunc (patemgcaserec.emgdt) AND (patemgcaserec.emglvdt - patemgcaserec.emgdt) * 24 >= 6 AND trunc (patemgcaserec.emglvdt
			) = trunc (patemgcaserec.emgdt) THEN
				ffix := 'Y';
				IF patemgcaserec.emgdt > TO_DATE ('20171001', 'YYYYMMDD') THEN --病房與護理費第一天用 by kuo 20171002
					v_day := v_day + 1;
				END IF;
			END IF;
			IF ffix = 'Y' THEN   
				--20200423 頭日要入 WARDER1 與 NURSER1
				l_fward_pfkey   := 'WARDER';
				l_fnurs_pfkey   := 'NURSER';
				IF patemgcaserec.emgdt >= TO_DATE ('20171001', 'YYYYMMDD') AND v_day = 1 THEN --第一天使用這兩個
					l_fward_pfkey   := 'WARDER1';
					l_fnurs_pfkey   := 'NURSER1';
				END IF;
				IF patemgcaserec.emgbedno <> '000' THEN
					OPEN cur_dbpfile (l_fward_pfkey);
					FETCH cur_dbpfile INTO dbpfilerec;
					CLOSE cur_dbpfile;
					emgoccrec.caseno     := pcaseno;
					emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
					v_cnt                := v_cnt + 1;
					emgoccrec.emocdate   := v_date;
					emgoccrec.embldate   := v_date;
					emgoccrec.ordseq     := '0000';
					emgoccrec.emchrgcr   := '+';
					emgoccrec.emchcode   := dbpfilerec.pfkey; --l_fward_pfkey
					emgoccrec.emchtyp1   := dbpfilerec.pricety1;
					emgoccrec.emchqty1   := 1;
					emgoccrec.emchamt1   := dbpfilerec.pfprice1;
					emgoccrec.emchtyp2   := '99';
					emgoccrec.emchtyp4   := '99';
					emgoccrec.emchemg    := 'R';
					emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --強制收入歸屬科(4 BYTES)
					emgoccrec.emchstat   := patemgcaserec.emgns; --消耗地點(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emocsect   := patemgcaserec.emgsect; --計價科別(4 BYTES)
					emgoccrec.emocns     := patemgcaserec.emgns; --病房(4 BYTES)
					emgoccrec.emoedept   := patemgcaserec.emgsect; --開立科別(4 BYTES, EMG ONLY)
					emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert WARDER to date:'||v_date);
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
					OPEN cur_dbpfile (l_fnurs_pfkey);
					FETCH cur_dbpfile INTO dbpfilerec;
					CLOSE cur_dbpfile;
					emgoccrec.caseno     := pcaseno;
					emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
					v_cnt                := v_cnt + 1;
					emgoccrec.emocdate   := v_date;
					emgoccrec.embldate   := v_date;
					emgoccrec.ordseq     := '0000';
					emgoccrec.emchrgcr   := '+';
					emgoccrec.emchcode   := dbpfilerec.pfkey;--l_fnurs_pfkey
					emgoccrec.emchtyp1   := dbpfilerec.pricety1;
					emgoccrec.emchqty1   := 1;
					emgoccrec.emchamt1   := dbpfilerec.pfprice1;
					emgoccrec.emchtyp2   := '99';
					emgoccrec.emchtyp4   := '99';
					emgoccrec.emchemg    := 'R';
					emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --強制收入歸屬科(4 BYTES)
					emgoccrec.emchstat   := patemgcaserec.emgns; --消耗地點(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emocsect   := patemgcaserec.emgsect; --計價科別(4 BYTES)
					emgoccrec.emocns     := patemgcaserec.emgns; --病房(4 BYTES)
					emgoccrec.emoedept   := patemgcaserec.emgsect; --開立科別(4 BYTES, EMG ONLY)
					emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert NURSER to date:'||v_date);
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				END IF;
			END IF; --END v_date <> trunc(patemgcaseRec.EMGDT)

      --入診察費算進又算出
      --EMGOPDPT='Y'--門診換藥,EMGREGFG='Y' --僅收掛號費
      --dbms_output.put_line('Diag Fee:'||patemgcaseRec.EMGTYPE||','||patemgcaseRec.EMGOPDPT||','||patemgcaseRec.EMGREGFG);
      --IF (PATEMGCASEREC.EMGOPDPT IS NULL OR PATEMGCASEREC.EMGOPDPT <> 'Y') AND
			IF (patemgcaserec.emgregfg IS NULL OR patemgcaserec.emgregfg <> 'Y') AND patemgcaserec.emgtype IN (
				'2',
				'4'
			) THEN
				BEGIN
					SELECT
						common.pat_emg_triage.degree,
						common.pat_emg_triage.emg_pat_source
					INTO
						v_degree,
						vemg_pat_source
					FROM
						common.pat_emg_triage
					WHERE
						hcaseno = pcaseno;
				EXCEPTION
					WHEN OTHERS THEN
						v_degree := '';
				END;
        --add by kuo 20170320
				triage      := v_degree;
				IF triage = '' THEN
					triage := '5';
				END IF; 
        --dbms_output.put_line('triage degree:'||v_degree);
				v_pfkey     := '';
				IF v_degree = '1' THEN
					v_pfkey := 'DIAG0201';
				ELSIF v_degree = '2' THEN
					v_pfkey := 'DIAG0202';
				ELSIF v_degree = '3' THEN
					v_pfkey := 'DIAG0203';
				ELSIF v_degree = '4' THEN
					v_pfkey := 'DIAG0204';
				ELSIF v_degree = '5' THEN
					v_pfkey := 'DIAG0225';
				ELSIF v_degree IS NOT NULL THEN
					v_pfkey := 'DIAGER';
				END IF;
				IF patemgcaserec.emgsect = 'PSY' THEN
					v_pfkey := 'DIAG1021';
				END IF;
        --國際醫療S999 BY KUO 20121128
        --國際醫療S995 BY KUO 20150721
				IF patemgcaserec.emgspeu1 IN (
					'S999',
					'S995'
				) THEN
					v_pfkey := 'DIAGINT0';
				END IF;
        --職傷亦按檢傷分類分級收費
        --職傷於20140101回歸正常診察費與加成 by kuo 20140220,有申請單再來異動, update by kuo 20140225
				IF patemgcaserec.emgcopay = '006' AND patemgcaserec.emgpayfg = '1' AND patemgcaserec.emglvdt < TO_DATE ('20140101', 'YYYYMMDD'
				) THEN
        --IF patemgcaseRec.EMGCOPAY = '006' AND patemgcaseRec.EMGPAYFG = '1' THEN
					v_pfkey := 'DIAG1045';
					IF v_degree = '1' THEN
						v_pfkey := 'DIAG1047';
					ELSIF v_degree = '2' THEN
						v_pfkey := 'DIAG1048';
					ELSIF v_degree = '3' THEN
						v_pfkey := 'DIAG1049';
					ELSIF v_degree = '4' THEN
						v_pfkey := 'DIAG1050';
					ELSIF v_degree IS NOT NULL THEN
						v_pfkey := 'DIAG1045';
					END IF;
				END IF;

        --急診夜間及例假日,國定假日加成應於COMPUWAT GETEMGPER中實做,這裡只單純進計價
				v_holiday   := 'N';
				IF v_pfkey IN (
					'DIAGER',
					'DIAG0201',
					'DIAG0202',
					'DIAG0203',
					'DIAG0204',
					'DIAG1021',
					'DIAG1047',
					'DIAG1048',
					'DIAG1049',
					'DIAG1050'
				) THEN
					BEGIN
						SELECT
							udholdt
						INTO v_holiday
						FROM
							cpoe.udhltbl
						WHERE
							udhdate = v_date;
					EXCEPTION
						WHEN OTHERS THEN
							v_holiday := 'N';
					END;
				END IF;
				IF TO_CHAR (patemgcaserec.emgdt, 'HH24MI') >= '2200' OR TO_CHAR (patemgcaserec.emgdt, 'HH24MI') <= '0600' OR v_holiday = 'Y' THEN
          --職傷亦按檢傷分類轉碼
					IF v_pfkey = 'DIAG1047' THEN
						v_pfkey := 'DIAG1104';
					ELSIF v_pfkey = 'DIAG1048' THEN
						v_pfkey := 'DIAG1107';
					ELSIF v_pfkey = 'DIAG1049' THEN
						v_pfkey := 'DIAG1110';
					ELSIF v_pfkey = 'DIAG1050' THEN
						v_pfkey := 'DIAG1113';
					END IF;
				END IF;

        --診察費第二天以後 $200計算，入院超過 20小時才算
				IF v_date <> trunc (patemgcaserec.emgdt) THEN
					IF (patemgcaserec.emglvdt - patemgcaserec.emgdt) * 24 >= 24 THEN
						v_pfkey := 'DIAGER@@';
            --國際醫療S999 BY KUO 20121128
            --Add by kuo 20150721 for S995
						IF patemgcaserec.emgspeu1 IN (
							'S999',
							'S995'
						) THEN
							v_pfkey := 'DIAGINT0';
						END IF;
					ELSE
						v_pfkey := NULL;
					END IF;
				END IF;
				IF v_pfkey IS NOT NULL THEN
					OPEN cur_dbpfile (v_pfkey);
					FETCH cur_dbpfile INTO dbpfilerec;
					IF cur_dbpfile%notfound THEN
						dbpfilerec.pfprice1   := 478;
						dbpfilerec.pricety1   := '03';
					END IF;
					CLOSE cur_dbpfile;
					emgoccrec.caseno     := pcaseno;
					emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
					v_cnt                := v_cnt + 1;
					emgoccrec.emocdate   := v_date;
					emgoccrec.embldate   := v_date;
					emgoccrec.ordseq     := '0000';
					emgoccrec.emchrgcr   := '+';
					emgoccrec.emchcode   := v_pfkey;
					emgoccrec.emchtyp1   := dbpfilerec.pricety1;
					emgoccrec.emchqty1   := 1;
					emgoccrec.emchamt1   := dbpfilerec.pfprice1;
					emgoccrec.emchtyp2   := '99';
					emgoccrec.emchtyp4   := '99';
					emgoccrec.emchemg    := 'R';
					emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --強制收入歸屬科(4 BYTES)
					emgoccrec.emchstat   := patemgcaserec.emgns; --消耗地點(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emocsect   := patemgcaserec.emgsect; --計價科別(4 BYTES)
					emgoccrec.emocns     := patemgcaserec.emgns; --病房(4 BYTES)
					emgoccrec.emoedept   := patemgcaserec.emgsect; --開立科別(4 BYTES, EMG ONLY)
					emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert '||v_pfkey||' to date:'||v_date);
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				END IF; --IF v_pfkey IS NOT NULL
			END IF; --IF patemgcaseRec.EMGOPDPT <> 'Y' AND...診察費

      --入藥師費
			IF patemgcaserec.emg1fncl = '7' THEN
				SELECT
					COUNT (*)
				INTO v_udcount
				FROM
					cpoe.emg_occur ce
				WHERE
					ce.emchtyp1 = '06'
					AND
					trunc (ce.embldate) = trunc (v_date)
					AND
					ce.caseno = pcaseno
					AND
					ce.empayfg != 'I';
				IF v_udcount > 0 THEN
					OPEN cur_dbpfile ('PHAR5201');
					FETCH cur_dbpfile INTO dbpfilerec;
					CLOSE cur_dbpfile;
					emgoccrec.caseno     := pcaseno;
					emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
					v_cnt                := v_cnt + 1;
					emgoccrec.emocdate   := v_date;
					emgoccrec.embldate   := v_date;
					emgoccrec.ordseq     := '0000';
					emgoccrec.emchrgcr   := '+';
					emgoccrec.emchcode   := 'PHAR5201';
					emgoccrec.emgerat    := 0.00;
					emgoccrec.emgcrat    := 0.00;
					emgoccrec.emchtyp1   := dbpfilerec.pricety1;
					emgoccrec.emchqty1   := 1;
					emgoccrec.emchamt1   := dbpfilerec.pfprice1;
					emgoccrec.emchidep   := '';--'PHAR'; --強制收入歸屬科(4 BYTES)
					emgoccrec.emchstat   := 'PHAR'; --消耗地點(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emchemg    := 'R';
					emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert REGISTER to date:'||trunc(patemgcaseRec.EMGDT));
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				END IF; -- v_udcount end
				SELECT
					COUNT (*)
				INTO v_ct_udcount
				FROM
					cpoe.emg_occur   ce
					JOIN cpoe.uddrugpf    ud ON substr (ce.emchcode, 4, 5) = ud.udddrgcode
				WHERE
					ce.emchtyp1 = '06'
					AND
					trunc (ce.embldate) = trunc (v_date)
					AND
					ce.caseno = pcaseno
					AND
					ce.empayfg != 'I'
					AND
					(ud.uddstock = 'Y'
					 OR
					 ud.uddstock = 'Z');
				IF v_ct_udcount > 0 THEN
					OPEN cur_dbpfile ('PHAR5221');
					FETCH cur_dbpfile INTO dbpfilerec;
					CLOSE cur_dbpfile;
					emgoccrec.caseno     := pcaseno;
					emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
					v_cnt                := v_cnt + 1;
					emgoccrec.emocdate   := v_date;
					emgoccrec.embldate   := v_date;
					emgoccrec.ordseq     := '0000';
					emgoccrec.emchrgcr   := '+';
					emgoccrec.emchcode   := 'PHAR5221';
					emgoccrec.emgerat    := 0.00;
					emgoccrec.emgcrat    := 0.00;
					emgoccrec.emchtyp1   := dbpfilerec.pricety1;
					emgoccrec.emchqty1   := 1;
					emgoccrec.emchamt1   := dbpfilerec.pfprice1;
					emgoccrec.emchidep   := '';--'PHAR'; --強制收入歸屬科(4 BYTES)
					emgoccrec.emchstat   := 'PHAR'; --消耗地點(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emchemg    := 'R';
					emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert REGISTER to date:'||trunc(patemgcaseRec.EMGDT));
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				END IF; -- v_ct_udcount end
				SELECT
					COUNT (*)
				INTO v_tpn_udcount
				FROM
					cpoe.emg_occur   ce
					JOIN cpoe.uddrugpf    ud ON substr (ce.emchcode, 4, 5) = ud.udddrgcode
				WHERE
					ce.emchtyp1 = '06'
					AND
					trunc (ce.embldate) = trunc (v_date)
					AND
					ce.caseno = pcaseno
					AND
					ce.empayfg != 'I'
					AND
					ud.uddstock = 'T';
				IF v_tpn_udcount > 0 THEN
					OPEN cur_dbpfile ('PHAR5220');
					FETCH cur_dbpfile INTO dbpfilerec;
					CLOSE cur_dbpfile;
					emgoccrec.caseno     := pcaseno;
					emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
					v_cnt                := v_cnt + 1;
					emgoccrec.emocdate   := v_date;
					emgoccrec.embldate   := v_date;
					emgoccrec.ordseq     := '0000';
					emgoccrec.emchrgcr   := '+';
					emgoccrec.emchcode   := 'PHAR5220';
					emgoccrec.emgerat    := 0.00;
					emgoccrec.emgcrat    := 0.00;
					emgoccrec.emchtyp1   := dbpfilerec.pricety1;
					emgoccrec.emchqty1   := 1;
					emgoccrec.emchamt1   := dbpfilerec.pfprice1;
					emgoccrec.emchidep   := '';--'PHAR'; --強制收入歸屬科(4 BYTES)
					emgoccrec.emchstat   := 'PHAR'; --消耗地點(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emchemg    := 'R';
					emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert REGISTER to date:'||trunc(patemgcaseRec.EMGDT));
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				END IF; -- v_ct_udcount end
			END IF; --藥師費 end
			v_date   := v_date + 1;
		END LOOP;
    --掛號費
    --EMGREGFEE(pCaseNo);
		IF patemgcaserec.emgregfg <> '1' OR patemgcaserec.emgregfg IS NULL THEN
			IF patemgcaserec.emgregfg <> '2' OR patemgcaserec.emgregfg IS NULL THEN
        --門診轉急診輸血病患不算掛號費,谷關居民不算掛號費
        --EMGOPDPT ,VEMG_PAT_SOURCE='C'--門轉急當日免掛號費
				IF patemgcaserec.emgoblod = 'Y' OR patemgcaserec.emgspeu1 = '1061' OR patemgcaserec.emgopdpt = 'Y' OR vemg_pat_source = 'C' THEN
					return;
				END IF;
			END IF;
      /*
      OPEN CUR_PFMLOG('REGISTER',PATEMGCASEREC.EMGDT);
      FETCH CUR_PFMLOG INTO PFMLOGREC;
      IF CUR_PFMLOG%NOTFOUND THEN
         OPEN CUR_DBPFILE('REGISTER');
         FETCH CUR_DBPFILE INTO DbpfileRec;
         IF CUR_DBPFILE%NOTFOUND THEN
            IF TO_CHAR(PATEMGCASEREC.EMGDT,'YYYYMMDD') < '20111001' THEN
               DBPFILEREC.PFPRICE1 := 170;
               DBPFILEREC.PRICETY1 := '37';
            ELSE
               DBPFILEREC.PFPRICE1 := 270;
               DBPFILEREC.PRICETY1 := '37';
            END IF;
         ELSE   
               DBPFILEREC.PFPRICE1 := PFMLOGREC.PFLPRICE;
               DBPFILEREC.PRICETY1 := '37';
         END IF;
         CLOSE CUR_DBPFILE;
      END IF;
      CLOSE CUR_PFMLOG;
      */
			OPEN cur_dbpfile ('REGISTER');
			FETCH cur_dbpfile INTO dbpfilerec;
			IF cur_dbpfile%notfound THEN
				dbpfilerec.pfprice1   := 170;
				dbpfilerec.pricety1   := '37';
			END IF;
			CLOSE cur_dbpfile;
			emgoccrec.caseno     := pcaseno;
			emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
			v_cnt                := v_cnt + 1;
			emgoccrec.emocdate   := trunc (patemgcaserec.emgdt);
			emgoccrec.embldate   := trunc (patemgcaserec.emgdt);
			emgoccrec.ordseq     := '0000';
			emgoccrec.emchrgcr   := '+';
			emgoccrec.emchcode   := 'REGISTER';
			emgoccrec.emchtyp1   := dbpfilerec.pricety1;
			emgoccrec.emchqty1   := 1;
			emgoccrec.emchamt1   := dbpfilerec.pfprice1;
			emgoccrec.emchtyp2   := '99';
			emgoccrec.emchtyp4   := '99';
			emgoccrec.emchemg    := 'R';
      --EmgOccRec.EMCHIDEP := patemgcaseRec.EMGNS; --強制收入歸屬科(4 BYTES)
			emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --強制收入歸屬科(4 BYTES)
			emgoccrec.emchstat   := patemgcaserec.emgns; --消耗地點(4 BYTES)
			emgoccrec.card_no    := 'BILLING';
			emgoccrec.emocomb    := 'N';
      --EmgOccRec.EMOCSECT := patemgcaseRec.EMGNS; --計價科別(4 BYTES)
			emgoccrec.emocsect   := patemgcaserec.emgsect; --計價科別(4 BYTES)
			emgoccrec.emocns     := patemgcaserec.emgns; --病房(4 BYTES)
			emgoccrec.emoedept   := patemgcaserec.emgns; --開立科別(4 BYTES, EMG ONLY)
			emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
      --dbms_output.put_line('insert REGISTER to date:'||trunc(patemgcaseRec.EMGDT));
			INSERT INTO cpoe.emg_occur VALUES emgoccrec;

      --國際醫療S999 BY KUO 20121128,加收服務費
      --Add 國際醫療服務費 by kuo 20150721 for S995
			IF patemgcaserec.emgspeu1 IN (
				'S999',
				'S995'
			) THEN
				emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
				v_cnt                := v_cnt + 1;
				emgoccrec.emchcode   := '91711115'; --91711115, 類別18
				emgoccrec.emchtyp1   := '18';
				emgoccrec.emchamt1   := 480;
				INSERT INTO cpoe.emg_occur VALUES emgoccrec;
			END IF;
		END IF; --IF patemgcaseRec.EMGREGFG <> '1'
		COMMIT WORK;
    --自動入急診獎勵 by kuo 20160511
		hospinout (pcaseno);
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line (v_program_name || ',' || v_source_seq || ',' || v_error_code || ',' || v_error_info);
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
	END; --EMGFixFees

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
		subject          VARCHAR (120);
		message          VARCHAR2 (32767);
		v_cnt            INTEGER;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'emg_calculate_PKG.initData';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		DELETE FROM emg_bil_feedtl
		WHERE
			caseno = pcaseno;
		DELETE FROM emg_bil_feemst
		WHERE
			caseno = pcaseno;
		DELETE FROM tmp_fincal
		WHERE
			caseno = pcaseno;

    --在刪除前,若有之後的帳款資料,儲存至歷史中
		emg_calculate_pkg.bkoccur (pcaseno);
		DELETE FROM emg_bil_acnt_wk
		WHERE
			caseno = pcaseno;
		DELETE FROM emg_bil_occur_trans
		WHERE
			caseno = pcaseno;

    --刪掉 檢驗組合項拆出項目
		DELETE cpoe.emg_occur
		WHERE
			caseno = TRIM (pcaseno)
			AND
			emapply = 'C';
		COMMIT WORK;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := pcaseno;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line (v_program_name || ',' || v_source_seq || ',' || v_error_code || ',' || v_error_info);
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
	END; --PROCEDURE initData(pCaseNo varchar2)

  --展開身份別至身份暫存檔
	PROCEDURE extandfin (
		pcaseno VARCHAR2
	) IS
		CURSOR cur_disge IS
		SELECT
			*
		FROM
			common.pat_emg_discharge
		WHERE
			ecaseno = pcaseno
			AND
			edisstat IN (
				'L',
				'I',
				'E'
			)
			AND
			canceled = 'N'
		ORDER BY
			edisdt ASC;
		patemgcaserec    common.pat_emg_casen%rowtype;
		patemgdisgerec   common.pat_emg_discharge%rowtype;
		v_other_fincal   VARCHAR2 (04);
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
		v_program_name          := 'emg_calculate_PKG.extandFin';
		v_session_id            := userenv ('SESSIONID');
		v_source_seq            := pcaseno;
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;

    --修改tmp_fincal.end_date,會發生出院時需繳費,但隔日算帳後又變成不需繳費
    --因為急診是一個身份到底,將end_date改為2999/12/31(update by amber 20110421)
    --patemgdisgeRec.EDISDT := SYSDATE;
		patemgdisgerec.edisdt   := TO_DATE ('2999/12/31', 'YYYY/MM/DD');
    /*
    OPEN CUR_DISGE;
    LOOP
      FETCH CUR_DISGE into patemgdisgeRec;
      EXIT WHEN CUR_DISGE%NOTFOUND;
    END LOOP;
    */
    --身份一
		IF patemgcaserec.emg1fncl = '7' THEN
			INSERT INTO tmp_fincal (
				caseno,
				fincalcode,
				st_date,
				end_date
			) VALUES (
				pcaseno,
				'LABI',
				trunc (patemgcaserec.emgdt),
				patemgdisgerec.edisdt
			);
		ELSE
			IF patemgcaserec.emg1fncl = '9' THEN
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					'CIVC',
					trunc (patemgcaserec.emgdt),
					patemgdisgerec.edisdt
				);
			END IF;
		END IF;
    --身份二
		IF patemgcaserec.emg2fncl IS NOT NULL THEN
			IF patemgcaserec.emg2fncl IN (
				'E',
				'1'
			) THEN
				p_disfin (pcaseno => pcaseno, pfinacl => 'VTAN', pdiscfin => v_other_fincal);
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					v_other_fincal,
					trunc (patemgcaserec.emgdt),
					patemgdisgerec.edisdt
				);
			END IF;
			IF patemgcaserec.emg2fncl = '6' THEN
				INSERT INTO tmp_fincal (
					caseno,
					fincalcode,
					st_date,
					end_date
				) VALUES (
					pcaseno,
					'EMPL',
					trunc (patemgcaserec.emgdt),
					patemgdisgerec.edisdt
				);
			END IF;
		END IF;
    --特約
		IF patemgcaserec.emgspeu1 IS NOT NULL THEN
			INSERT INTO tmp_fincal (
				caseno,
				fincalcode,
				st_date,
				end_date
			) VALUES (
				pcaseno,
				patemgcaserec.emgspeu1,
				trunc (patemgcaserec.emgdt),
				patemgdisgerec.edisdt
			);
		END IF;
		IF patemgcaserec.emgspeu2 IS NOT NULL THEN
			INSERT INTO tmp_fincal (
				caseno,
				fincalcode,
				st_date,
				end_date
			) VALUES (
				pcaseno,
				patemgcaserec.emgspeu2,
				trunc (patemgcaserec.emgdt),
				patemgdisgerec.edisdt
			);
		END IF;
		set_1060_financial (pcaseno);
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line (v_program_name || ',' || v_error_code || ',' || v_error_info);
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
	END; --PROCEDURE extandFin(pCaseNo varchar2)

  --分攤帳款
	PROCEDURE compacntwk (
		pcaseno   VARCHAR2,
		poper     VARCHAR2
	) IS
		CURSOR cur_4 IS
		SELECT
			*
		FROM
			cpoe.emg_occur
		WHERE
			caseno = pcaseno
			AND
			emocomb = 'Y'
		ORDER BY
			emchtyp1,
			emocdate;
		CURSOR cur_occur IS
		SELECT
			*
		FROM
			cpoe.emg_occur
		WHERE
			caseno = pcaseno
			AND
			emchqty1 <> 0
            -- 為組合項新增
			AND
			(emapply != 'N'
			 OR
			 emapply IS NULL)
		ORDER BY
			emchtyp1,
			emocdate;
		CURSOR cur_disc (
			pbiltype   VARCHAR2,
			pcaseno    VARCHAR2,
			feetype    VARCHAR2,
			bildate    DATE
		) IS
		SELECT
			bil_discdtl.salf_per,
			bil_discdtl.bilkey,
			bil_discdtl.insu_per
		FROM
			bil_discdtl,
			tmp_fincal
		WHERE
			bil_discdtl.pftype = feetype
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
			bil_discdtl.begymd <= bildate
			AND
			bil_discdtl.endymd >= bildate
			AND
			tmp_fincal.st_date <= bildate
			AND
			tmp_fincal.end_date >= bildate
			AND
			tmp_fincal.caseno = pcaseno
			AND
			tmp_fincal.fincalcode <> 'LABI'
		ORDER BY
			salf_per;

    --為正確提供健保碼改寫 by Kuo 980428
		CURSOR cur_3 (
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
			(pfinoea = 'E'
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
			(pfinoea = 'E'
			 OR
			 pfinoea = '@');
		CURSOR cur_pfclass1 (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfeemep,
			pfopfg,
			pfspexam,
			pfinnseq
		FROM
			pfclass
		WHERE
			pfclass.pfkey = ppfkey
			AND
			pfclass.pfbegindate <= pbildate
			AND
			pfclass.pfenddate >= pbildate
			AND
			pfclass.pfincode = 'LABI'
            -- AND pfclass.
			AND
			(pfclass.pfinoea = 'E'
			 OR
			 pfclass.pfinoea = '@')
		ORDER BY
			pfclass.pfinbdt DESC;
		CURSOR cur_pfclass2 (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfeemep,
			pfopfg,
			pfspexam,
			pfinnseq
		FROM
			pfclass,
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
			AND
			pfclass.pfbegindate <= pbildate
			AND
			pfclass.pfenddate >= pbildate
			AND
			tmp_fincal.fincalcode = 'LABI'
			AND
			tmp_fincal.st_date <= pbildate
			AND
			tmp_fincal.end_date >= pbildate
			AND
			pfclass.pfkey = ppfkey
			AND
			pfclass.pfincode = 'LABI'
			AND
			(pfclass.pfinoea = 'E'
			 OR
			 pfclass.pfinoea = '@')
      --ORDER BY pfclass.pfinbdt DESC;
		UNION
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfeemep,
			pfopfg,
			pfspexam,
			pfinnseq
		FROM
			pfhiscls,
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
			AND
			pfhiscls.pfbegindate <= pbildate
			AND
			pfhiscls.pfenddate >= pbildate
			AND
			tmp_fincal.fincalcode = 'LABI'
			AND
			tmp_fincal.st_date <= pbildate
			AND
			tmp_fincal.end_date >= pbildate
			AND
			pfhiscls.pfkey = ppfkey
			AND
			pfhiscls.pfincode = 'LABI'
			AND
			(pfhiscls.pfinoea = 'E'
			 OR
			 pfhiscls.pfinoea = '@');
		CURSOR cur_pfclass3 (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfclass.pfincode
		FROM
			pfclass,
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
			AND
			pfclass.pfbegindate <= pbildate
			AND
			pfclass.pfenddate >= pbildate
			AND
			tmp_fincal.fincalcode = pfclass.pfincode
			AND
			tmp_fincal.st_date <= pbildate
			AND
			tmp_fincal.end_date >= pbildate
			AND
			pfclass.pfkey = ppfkey
			AND
			pfclass.pfincode <> 'LABI'
			AND
			(pfclass.pfinoea = 'E'
			 OR
			 pfclass.pfinoea = '@')
		ORDER BY
			to_number (pfselpay) ASC;
		CURSOR cur_pfclass5 (
			ppfkey     VARCHAR2,
			pbildate   DATE
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfclass.pfincode
		FROM
			pfclass,
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
			AND
			pfclass.pfbegindate <= pbildate
			AND
			pfclass.pfenddate >= pbildate
			AND
			tmp_fincal.fincalcode = pfclass.pfincode
			AND
			tmp_fincal.st_date <= pbildate
			AND
			tmp_fincal.end_date >= pbildate
			AND
			pfclass.pfkey = ppfkey
			AND
			pfclass.pfincode = 'VTAN'
			AND
			(pfclass.pfinoea = 'E'
			 OR
			 pfclass.pfinoea = '@')
		ORDER BY
			pfclass.pfinnseq DESC,
			to_number (pfselpay) ASC;
		CURSOR cur_vsnhi (
			ppfkey VARCHAR2
		) IS
		SELECT
			vsnhi.labtype
		FROM
			pflabi,
			vsnhi
		WHERE
			pflabi.pfkey = ppfkey
			AND
			vsnhi.labkey = pflabi.pflabcd;
		CURSOR cur_pfclass4 (
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
			pfmlog.pfldate IN (
				SELECT
					MIN (pfmlog.pfldate)
				FROM
					pfmlog
				WHERE
					pfmlog.pfkey = ppfkey
                    --and substr(pfmlog.pfldate,1,6) <= pDate
					AND
					biling_common_pkg.f_get_chdate (substr (pfmlog.pfldate, 1, 6)) >= pdate --MODIFY BY kUO 970616
					AND
					pfmlog.pflprice <> pamt
					AND
					pfmlog.pflprice <> 0
					AND
					pfmlog.pfldbtyp = 'A'
			)
			AND
			pfmlog.pfldbtyp = 'A';

    --尋找可以兒童專科加成60%的醫生名單 by kuo, SQL Provided by 以婷 20140306
    --20171006根據育誠將中文調成代碼更動
    --20171011 copy from adm by kuo
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
		v_program_name        VARCHAR2 (80);
		v_session_id          NUMBER (10);
		v_error_code          VARCHAR2 (20);
		v_error_msg           VARCHAR2 (400);
		v_error_info          VARCHAR2 (600);
		v_source_seq          VARCHAR2 (20);
		e_user_exception EXCEPTION;
		subject               VARCHAR2 (120);
		message               VARCHAR2 (32767);
		cc_feemst             NUMBER (1);
		v_self_price          NUMBER (10, 2); --自費價格(單價)
		v_nh_price            NUMBER (10, 2); --健保價格(單價)
		v_other_price         NUMBER (10, 2); --特約或是特殊身份單價(單價)
		v_other_fincal        VARCHAR2 (10); --特約或是特殊身份(單一計價碼)
		v_price               NUMBER (10, 2); --計價碼定價
		v_salf_per            NUMBER (5, 2); --單一類別bil_discdtl自費折扣成數
		v_fincal              VARCHAR2 (10); --折扣身份
		v_ud_qty              NUMBER (10, 2); --藥品小包裝數量
		v_ud_mstdcl           VARCHAR2 (20); --藥品使用
		v_udd_payself         VARCHAR2 (01); --藥品是否健保(y/n)或是榮民補助(v)
		v_other_amt           NUMBER (10, 1); --特約或是特殊身份總金額(單一計價碼)
		v_nh_amt              NUMBER (10, 1); --健保總金額(單一計價碼)
		v_self_amt            NUMBER (10, 1); --自付總金額(單一計價碼)
		v_emg_per             NUMBER (5, 2); --加成成數
    --v_qty_1       integer;
		v_fee_type            VARCHAR2 (10); --健保類別

    --v_day         INTEGER;

    --v_amt_1       number(10,2);
    --v_amt_2       number(10,2);
    --v_amt_3       number(10,2);
    --v_self_pay    number(10,1);
		v_labprice            NUMBER (10, 1); --健保單價
		v_nh_amt1             NUMBER (10, 1); --健保金額暫存
		v_cnt                 INTEGER;
		v_pf_self_pay         NUMBER (10, 1); --計價碼自付部份
		v_pf_nh_pay           NUMBER (10, 1); --計價碼健保部份
		v_pf_child_pay        NUMBER (10, 1); --計價碼兒童加成部份
		v_labchild            VARCHAR2 (01); --VSNHI 是否兒童加成
		v_ins_fee_code        VARCHAR2 (20); --計價碼對應的健保碼
		v_pfemep              NUMBER (5, 2); --dbpfile裡面紀錄的加成比率
    --院內計價類別
		v_fee_kind            VARCHAR2 (10); --院內計價類別
		v_nhipric             NUMBER (10, 2); --VSNHI健保價
    --v_limit_amt number(10,0);
		v_feemep_flag         VARCHAR2 (01) := 'N'; --pfclass急診是否可計急作flag
		v_pfopfg_flag         VARCHAR2 (01) := 'N'; --pfclass手術否
		v_pfspexam            VARCHAR2 (01) := 'N'; --pfclass特殊檢查否
		v_acnt_seq            NUMBER (5, 0); --計數用
		v_e_level             VARCHAR2 (01) := '1'; --急診無用
    --v_qty          INTEGER;
		v_in_type             VARCHAR2 (02); --emg_occur的 fee_type emgOccurRec.EMCHTYP1;
		v_out_type            VARCHAR2 (02); --轉換費用類別用
		v_pricety1            VARCHAR2 (02); --dbpfile中的類別

    --v_lab_disc_pert number(5,2);
    --v_lab_qty       integer;
		v_labi_qty            INTEGER; --VSNHI數量
    --v_dietselfprice number(8,2);
    --v_dietnhprice   number(8,2);
    --v_dietunit      varchar2(10);
    --v_nh_diet_flag  varchar2(01) := 'N';
    --v_finCode       varchar2(10);

    --記錄是否保持billtemp中的價格之註記
    --註記為'Y'者,不再重新計算 amount
		v_keep_amount_flag    VARCHAR2 (01) := 'N';

    --v_days     integer;
    --v_lastdate date;
		v_birthday            DATE;
		v_disctype            VARCHAR2 (01); --自費(p)或是特殊(b)折扣檔判斷
		v_insu_per            NUMBER (5, 2); --自費(p)或是特殊(b)折扣中健保折扣成數

    --v_breakFlag varchar2(01) := 'N';
    --v_breakTime varchar2(20);
		v_child_flag_1        VARCHAR2 (01);
		v_child_flag_2        VARCHAR2 (01);
		v_child_flag_3        VARCHAR2 (01);
		v_labchild_inc        VARCHAR2 (01); --提升兒童加成急做 add by kuo 20140128
		v_yy                  INTEGER;
		ls_date               VARCHAR2 (10);
		v_mm                  VARCHAR2 (10);
		c_count               NUMBER;
		labilabi              VARCHAR2 (20); --折扣類別比照健保
		pfinseq               VARCHAR2 (04);
		vpfinseq              VARCHAR2 (04);
		vemg_per              NUMBER (10, 3);
		vholiday_per          NUMBER (10, 3);
		vnight_per            NUMBER (10, 3);
		vchild_per            NUMBER (10, 3);
		vurgent_per           NUMBER (10, 3);
		voperation_per        NUMBER (10, 3);
		vanesthesia_per       NUMBER (10, 3);
		vmaterials_per        NUMBER (10, 3);
		vdept                 VARCHAR2 (10);
		maxcopay              NUMBER; --add by kuo 20170320 for 新部份負擔
		vcardno               VARCHAR2 (4); --add by kuo 20171011 for PED
		patemgcaserec         common.pat_emg_casen%rowtype;
		emgfeedtlrec          emg_bil_feedtl%rowtype;
		emgfeemstrec          emg_bil_feemst%rowtype;
		emgoccurrec           cpoe.emg_occur%rowtype;
		emgacntwkrec          emg_bil_acnt_wk%rowtype;
		pfmlogrec             pfmlog%rowtype;
		pfclassrec            pfclass%rowtype;
		emgfeemst_rec_atins   emg_bil_feemst%rowtype;
	BEGIN

    --設定程式名稱及session_id
		v_program_name                  := 'emg_calculate_PKG.CompAcntWk';
		v_session_id                    := userenv ('SESSIONID');
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;

    --1152 -- 彰化縣政府警察局酒測 依實際狀況計算，需算掛號費 by kuo 20160128
    --cancel by kuo 20161227 比照 1151
    /*
    IF PATEMGCASEREC.EMGSPEU1='1152' THEN
       --delete fixed fee exception 37 from cpoe.emg_occur
       DELETE FROM CPOE.EMG_OCCUR  
       WHERE CASENO = PCASENO
       AND EMCHTYP1 IN ('01', '03', '04', '05');

       COMMIT WORK;
    END IF;	
    */
    --修改生日取不到，給一個預設值 by kuo 20141203
		BEGIN
			SELECT
				TO_DATE (hbirthdt, 'YYYYMMDD')
			INTO v_birthday
			FROM
				common.pat_basic
			WHERE
				hhisnum = patemgcaserec.emghhist;
		EXCEPTION
			WHEN OTHERS THEN
				v_birthday := TO_DATE ('19880101', 'yyyymmdd');
		END;
		ls_date                         := biling_common_pkg.f_datebetween (b_date => v_birthday, e_date => patemgcaserec.emgdt);
		v_yy                            := to_number (TO_CHAR (patemgcaserec.emgdt, 'yyyy')) - to_number (TO_CHAR (v_birthday, 'yyyy'));

    --取出病患年齡
    --判斷是否符合兒童加乘( 6歲以下 , 二歲以下 ,六個月以下)
    --年齡大於6歲,就沒有兒童加乘
		IF v_yy > 6 THEN
			v_child_flag_1   := 'N';
			v_child_flag_2   := 'N';
			v_child_flag_3   := 'N';
		ELSE
      --小於六歲大於二歲者
			IF v_yy <= 6 AND to_number (ls_date) > 20000 THEN
				v_child_flag_1 := 'Y';
			ELSE
        --年齡小於一歲,月份又小於六個月
        --v_mm := substr(ls_date,4,2);
				IF substr (ls_date, 1, 2) = '00' AND to_number (substr (ls_date, 4, 2)) < 6 THEN
					v_child_flag_3 := 'Y';
          --小於二歲大於六個月
				ELSE
					v_child_flag_2 := 'Y';
				END IF;
			END IF;
		END IF;

    --準備EMG_bil_feemst,EMG_bil_feedtl
		emgfeemstrec.caseno             := pcaseno;
		emgfeemstrec.st_date            := trunc (patemgcaserec.emgdt);
		SELECT
			MAX (emocdate)
		INTO
			emgfeemstrec
		.end_date
		FROM
			cpoe.emg_occur
		WHERE
			caseno = pcaseno;
		emgfeemstrec.emg_bed_days       := trunc (emgfeemstrec.end_date) - trunc (emgfeemstrec.st_date);
		IF emgfeemstrec.emg_bed_days = 0 THEN
			emgfeemstrec.emg_bed_days := 1;
		END IF;
		emgfeemstrec.emg_exp_amt1       := 0;
		emgfeemstrec.emg_pay_amt1       := 0;
		emgfeemstrec.emg_exp_amt2       := 0;
		emgfeemstrec.emg_pay_amt2       := 0;
		emgfeemstrec.emg_exp_amt3       := 0;
		emgfeemstrec.emg_pay_amt3       := 0;
		emgfeemstrec.tot_self_amt       := 0;
		emgfeemstrec.tot_gl_amt         := 0;
		emgfeemstrec.credit_amt         := 0;
		emgfeemstrec.created_by         := 'biling';
		emgfeemstrec.created_date       := SYSDATE;
		emgfeemstrec.last_updated_by    := 'biling';
		emgfeemstrec.last_update_date   := SYSDATE;
    --v_amt_1 := 0;
    --v_amt_2 := 0;
    --v_amt_3 := 0;
    --v_self_pay := 0;
		v_acnt_seq                      := 0;

    --v_lab_qty := 0;

    --取出可折扣之檢驗項項次?
		INSERT INTO emg_bil_feemst VALUES emgfeemstrec;

    --只收掛號費
		IF patemgcaserec.emgregfg = 'Y' THEN
      --寫一個PROCEDURE入相關掛號費
			emgregfee (pcaseno);
			return;
		END IF;
    --scan emg_occur
		OPEN cur_occur;
		LOOP
			FETCH cur_occur INTO emgoccurrec;
			EXIT WHEN cur_occur%notfound;

      --dbms_output.put_line('c:'||emgOccurRec.EMCHCODE);
			IF emgoccurrec.emchqty1 IS NULL THEN
				emgoccurrec.emchqty1 := 1;
			END IF;
			v_acnt_seq                    := v_acnt_seq + 1;
			emgacntwkrec.acnt_seq         := v_acnt_seq;
			emgacntwkrec.emg_per          := 1;
			emgacntwkrec.emg_flag         := emgoccurrec.emchemg;
			v_feemep_flag                 := 'N';
			v_ins_fee_code                := NULL;
			v_in_type                     := emgoccurrec.emchtyp1;
			IF v_in_type IN (
				'20'
			) THEN
				v_in_type := v_in_type;
			END IF;
			IF emgoccurrec.emchtyp1 IN (
				'38'
			) THEN
				v_in_type := emgoccurrec.emchtyp1;
			END IF;
			v_keep_amount_flag            := 'N';

      --判斷是否為需保留billtemp之價格,不重算者
      --IF EMGOCCURREC.EMCHTYP1 IN ('40', '02', '37', '38') THEN
			IF emgoccurrec.emchtyp1 IN (
				'40',
				'02',
				'38'
			) THEN
				v_keep_amount_flag := 'Y';
			ELSE
				v_keep_amount_flag := 'N';
			END IF;

      --判斷是否為需保留billtemp之價格,不重算者
			IF patemgcaserec.emg1fncl = '9' THEN
        --CIVC
				IF substr (emgoccurrec.ordseq, 12, 4) <> '0000' OR emgoccurrec.emocomb = 'N' THEN
					v_keep_amount_flag := 'N';
				ELSE
					v_keep_amount_flag := 'Y';
				END IF;
			END IF;

      --先抓出dbpfile中的類別
			BEGIN
				SELECT
					dbpfile.pricety1
				INTO v_pricety1
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = emgoccurrec.emchcode;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
			END;
			IF v_pricety1 IS NULL THEN
				v_pricety1 := emgoccurrec.emchtyp1;
			END IF;
			IF emgoccurrec.emchtyp1 IN (
				'10',
				'14'
			) THEN
				IF emgoccurrec.emchtyp1 <> v_pricety1 THEN
					emgoccurrec.emchtyp1 := v_pricety1;
				END IF;
			END IF;
			IF v_in_type IN (
				'07',
				'09'
			) THEN
				v_in_type := v_in_type;
			END IF;
			IF v_in_type IN (
				'11',
				'48',
				'58',
				'59',
				'68'
			) THEN
				IF v_pricety1 = '07' THEN
					v_out_type   := '11';
					v_pricety1   := '11';
				END IF;
			ELSIF v_in_type IN (
				'12',
				'88'
			) THEN
				v_out_type   := '12';
				v_pricety1   := '12';
			ELSIF v_in_type = '13' THEN
				IF v_pricety1 = '08' THEN
					v_out_type   := '13';
					v_pricety1   := '13';
				END IF;
			ELSIF v_in_type = '06' THEN
				v_out_type   := '06';
				v_pricety1   := '06';
			ELSE
				v_out_type := v_pricety1;
			END IF;
			v_fee_kind                    := v_out_type;
			IF emgoccurrec.emchcode IN (
				'80004351',
				'80004025'
			) THEN
				v_fee_kind := v_out_type;
			END IF;
			IF v_keep_amount_flag = 'Y' THEN
        --emgAcntWkRec.Emg_Per:= 
				getemgper (pcaseno => emgoccurrec.caseno, ppfkey => emgoccurrec.emchcode, pfeekind => v_pricety1, pemgflag => emgoccurrec.emchemg
				, pfncl => patemgcaserec.emg1fncl, ptype => '2', pdate => emgoccurrec.embldate, emg_per => vemg_per, holiday_per => vholiday_per
				, night_per => vnight_per, child_per => vchild_per, urgent_per => vurgent_per, operation_per => voperation_per, anesthesia_per
				=> vanesthesia_per, materials_per => vmaterials_per);
			ELSE
        --emgAcntWkRec.Emg_Per:= 
				getemgper (pcaseno => emgoccurrec.caseno, ppfkey => emgoccurrec.emchcode, pfeekind => v_pricety1, pemgflag => emgoccurrec.emchemg
				, pfncl => patemgcaserec.emg1fncl, ptype => '1', pdate => emgoccurrec.embldate, emg_per => vemg_per, holiday_per => vholiday_per
				, night_per => vnight_per, child_per => vchild_per, urgent_per => vurgent_per, operation_per => voperation_per, anesthesia_per
				=> vanesthesia_per, materials_per => vmaterials_per);
			END IF;
			emgacntwkrec.emg_per          := vemg_per;
			emgacntwkrec.holiday_per      := vholiday_per;
			emgacntwkrec.night_per        := vnight_per;
			emgacntwkrec.child_per        := vchild_per;
			emgacntwkrec.urgent_per       := vurgent_per;
			emgacntwkrec.operation_per    := voperation_per;
			emgacntwkrec.anesthesia_per   := vanesthesia_per;
			emgacntwkrec.materials_per    := vmaterials_per;

      --不知道為什麼,但90212608 跟90212609 都不被計算進去
      /*OPEN BY KUO 1000526
      IF emgOccurRec.EMCHCODE = '90212608' OR
         emgOccurRec.EMCHCODE = '90212609' THEN
        emgAcntWkRec.Emg_Per := 0;
      END IF;
      */
			IF emgacntwkrec.emg_per <> 1 THEN
				emgacntwkrec.emg_per := emgacntwkrec.emg_per;
			END IF;

      --收費碼60413200 基本就加 0.65,至少為1.65 在 2008-01-01以後 by Kuo 970505
			IF emgoccurrec.emchcode = '60413200' AND emgoccurrec.emocdate >= TO_DATE ('2008-01-01', 'yyyy-mm-dd') THEN
				emgacntwkrec.emg_per := emgacntwkrec.emg_per + 0.65;
			END IF;
			IF length (v_fee_kind) = 1 THEN
				v_fee_kind := '0' || v_fee_kind;
			END IF;

      /*
      IF emgOccurRec.emocdate > bilRootRec.Dischg_Date THEN
         emgOccurRec.emocdate := trunc(bilRootRec.Dischg_Date);
      END IF ;
      */
			emgacntwkrec.fee_kind         := v_fee_kind;

      --取得單價
      --藥品需抓另一個檔
			IF emgoccurrec.emchtyp1 = '6' OR emgoccurrec.emchtyp1 = '06' AND emgoccurrec.emchcode LIKE '006%' THEN
				BEGIN
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
          --FROM vghtcoe.udndrgoc
					FROM
						cpoe.udndrgoc
					WHERE
						(udnenddate > trunc (emgoccurrec.emocdate)
						 OR
						 udnenddate IS NULL)
						AND
						udnbgndate <= trunc (emgoccurrec.emocdate)
						AND
						udndrgcode = substr (emgoccurrec.emchcode, 4, 5);

          -- 民眾身分, 健保藥費設成 0
					IF patemgcaserec.emg1fncl = '9' OR emgoccurrec.empayfg = 'I' THEN
            --CIVC
						v_nh_price := 0;
					END IF;
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
						udddrgcode = substr (emgoccurrec.emchcode, 4, 5);
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
				IF rtrim (emgoccurrec.emchstat) = 'OR' OR rtrim (emgoccurrec.emchstat) = 'DR' OR rtrim (emgoccurrec.emchstat) = 'PAIN' OR rtrim
				(emgoccurrec.emchstat) = 'PED' OR rtrim (emgoccurrec.emchstat) = 'POR' OR rtrim (emgoccurrec.emchstat) = 'ANE' OR rtrim (emgoccurrec
				.emchstat) = 'ANE1' OR rtrim (emgoccurrec.emchstat) = 'ENT' OR rtrim (emgoccurrec.emchstat) = 'NEPH' THEN
          --特殊藥品計價設定檔
          --如建立於該檔中之資料,需再讀藥品主檔轉換係數
					SELECT
						COUNT (*)
					INTO v_cnt
					FROM
						bil_spec_medlist
					WHERE
						pfkey = substr (emgoccurrec.emchcode, 4, 5);
					IF v_cnt > 0 THEN
						IF emgoccurrec.emchcode IN (
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

        -- dbms_output.put_line('v_udd_payself ' || v_udd_payself );
        -- dbms_output.put_line('f_Getnhrangeflag ' || f_Getnhrangeflag(pCaseNo,emgOccurRec.Emocdate,'1') );
        -- dbms_output.put_line('emgOccurRec.EMCHANES ' || emgOccurRec.EMCHANES );
				IF v_udd_payself = 'Y' AND f_getnhrangeflag (pcaseno, emgoccurrec.emocdate, '1') <> 'CIVC' AND (emgoccurrec.emchanes IS NULL OR
				emgoccurrec.emchanes <> 'PR') AND (emgoccurrec.empayfg IS NULL OR emgoccurrec.empayfg <> 'I') THEN
					v_self_price    := 0;
					v_other_price   := 0;
				END IF;
				IF emgoccurrec.emchanes <> 'PR' THEN
					dbms_output.put_line ('emgOccurRec.EMCHANES <> PR is true ' || emgoccurrec.emchanes);
				END IF;

        --自付
				IF v_udd_payself = 'N' OR f_getnhrangeflag (pcaseno, emgoccurrec.emocdate, '1') = 'CIVC' OR emgoccurrec.emchanes = 'PR' THEN
					v_nh_price      := 0;
					v_other_price   := 0;
          --ADD BY KUO 980430 FOR SOME CONTR LIKE 1031,1034
					IF v_self_price > 0 THEN
						IF emgoccurrec.emchanes = 'PR' THEN
							v_disctype := 'P';
						ELSE
							v_disctype := 'B';
						END IF;
					ELSE
						v_disctype := 'B';
					END IF;
					OPEN cur_disc (v_disctype, pcaseno, emgoccurrec.emchtyp1, trunc (emgoccurrec.emocdate));
					FETCH cur_disc INTO
						v_salf_per,
						v_fincal,
						v_insu_per;
					IF cur_disc%found THEN
						v_other_price    := v_self_price * (1 - v_salf_per);
						v_self_price     := v_self_price * v_salf_per;
						v_nh_price       := 0;
						v_other_fincal   := v_fincal;
					END IF;
					CLOSE cur_disc;
				END IF;

        --榮民
				IF v_udd_payself = 'V' THEN
					IF patemgcaserec.emg2fncl IN (
						'E',
						'1'
					) THEN
						v_other_price    := v_self_price;
						v_nh_price       := 0;
						v_self_price     := 0;
						v_other_fincal   := 'VERT';
					ELSE
						v_nh_price      := 0;
						v_other_price   := 0;
					END IF;
				END IF;
				IF v_self_price > 0 THEN
					IF emgoccurrec.emchanes = 'PR' THEN
						v_disctype := 'P';
					ELSE
						v_disctype := 'B';
					END IF;
          --處理特約部份
					OPEN cur_disc (v_disctype, pcaseno, emgoccurrec.emchtyp1, trunc (emgoccurrec.emocdate));
					FETCH cur_disc INTO
						v_salf_per,
						v_fincal,
						v_insu_per;
					IF cur_disc%found THEN
            --DBMS_OUTPUT.PUT_LINE(emgOccurRec.EMCHCODE||':'||v_salf_per||':'||v_fincal||':'||v_insu_per||','||v_discType);
						v_other_price    := v_self_price * (1 - v_salf_per);
						v_self_price     := v_self_price * v_salf_per;
						v_nh_price       := 0;
						v_other_fincal   := v_fincal;
					END IF;
					CLOSE cur_disc;
				END IF;
			ELSE

        --以上藥費處理
        --先抓出定價
				BEGIN
					SELECT
						dbpfile.pfprice1,
						dbpfile.pfemep
					INTO
						v_price,
						v_pfemep
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = emgoccurrec.emchcode;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;

        --取得歷史檔
        --如果有找到資料則repalce
				OPEN cur_pfmlog (emgoccurrec.emchcode, trunc (emgoccurrec.emocdate), v_price);
				FETCH cur_pfmlog INTO pfmlogrec;
				IF cur_pfmlog%found THEN
					v_price := pfmlogrec.pflprice;
				END IF;
				CLOSE cur_pfmlog;

        --add by kuo 971217 92000010,92000020 special coding
				IF emgoccurrec.emchcode IN (
					'92000010',
					'92000020'
				) THEN
					v_price := emgoccurrec.emchamt1 / emgoccurrec.emchqty1;
          --dbms_output.put_line('PFMLOG:'||v_price);
				END IF;
        --計算健保價,無母嬰問題
				OPEN cur_pfclass2 (emgoccurrec.emchcode, trunc (emgoccurrec.emocdate));
				FETCH cur_pfclass2 INTO
					v_pf_self_pay,
					v_pf_nh_pay,
					v_pf_child_pay,
					v_feemep_flag,
					v_pfopfg_flag,
					v_pfspexam,
					vpfinseq;
				IF cur_pfclass2%notfound THEN
					v_pf_self_pay    := v_price;
					v_pf_nh_pay      := 0;
					v_pf_child_pay   := 0;          
          --IF emgAcntWkRec.Emg_Flag = 'E' and emgAcntWkRec.Emg_per = 1 THEN
          --  emgAcntWkRec.Emg_Per := 1 + (v_pfemep / 100);
          --END IF;
					v_feemep_flag    := 'N';
					v_pfopfg_flag    := 'N';
					v_pfspexam       := 'N';
				END IF;
				CLOSE cur_pfclass2;
				v_nh_price      := v_pf_nh_pay;
				v_self_price    := v_pf_self_pay;
				v_other_price   := 0;

        --伙食費判斷,急診無
        --v_nh_diet_flag := 'N';
				IF v_self_price > 0 THEN
          --需要自付,看看是否有可以折抵1.PFCLASS
					OPEN cur_pfclass3 (emgoccurrec.emchcode, trunc (emgoccurrec.emocdate));
					FETCH cur_pfclass3 INTO
						v_pf_self_pay,
						v_pf_nh_pay,
						v_pf_child_pay,
						v_fincal;
					IF cur_pfclass3%found THEN
						v_other_price    := v_self_price - v_pf_self_pay;
						v_self_price     := v_pf_self_pay;
						v_other_fincal   := v_fincal;
            --IF v_fincal = 'VTAN' and v_insu_per > 0 THEN
						IF v_fincal = 'VTAN' AND v_other_price > 0 THEN
               --為使錯誤不被更正，還是壓一個日期 by kuo 20151116
							IF emgoccurrec.emocdate >= TO_DATE ('20151101', 'YYYYMMDD') THEN
								v_other_fincal := 'VERT';
							END IF;
						END IF;
					ELSE
            --2.自費折扣
						v_disctype := 'B';
						OPEN cur_disc (v_disctype, pcaseno, emgoccurrec.emchtyp1, emgoccurrec.embldate);
						FETCH cur_disc INTO
							v_salf_per,
							v_fincal,
							v_insu_per;
						IF cur_disc%found THEN
              --可以折扣，則要看看單項計價碼由無比照其他規則不可折扣
							IF length (v_fincal) > 4 THEN
								v_fincal := substr (v_fincal, 1, 4);
							END IF;
              --是否比照健保
							c_count          := 0;
							labilabi         := '';
							SELECT
								COUNT (*)
							INTO c_count
							FROM
								pfclass
							WHERE
								pfclass.pfincode || pfinoea = '0' || v_fincal
								AND
								pfclass.pfkey = emgoccurrec.emchcode;
							IF c_count = 1 THEN
								SELECT
									pfoemep || pfeemep || pfaemep || pfselpay || pfreqpay
								INTO labilabi
								FROM
									pfclass
								WHERE
									pfclass.pfincode || pfinoea = '0' || v_fincal
									AND
									pfclass.pfkey = emgoccurrec.emchcode;
							END IF;
              --ADD BY KUO 970813
							IF c_count > 1 THEN
								SELECT
									MAX (pfinnseq)
								INTO pfinseq
								FROM
									pfclass
								WHERE
									pfclass.pfincode || pfinoea = '0' || v_fincal
									AND
									pfclass.pfkey = emgoccurrec.emchcode;
								SELECT
									pfoemep || pfeemep || pfaemep || pfselpay || pfreqpay
								INTO labilabi
								FROM
									pfclass
								WHERE
									pfclass.pfincode || pfinoea = '0' || v_fincal
									AND
									pfclass.pfkey = emgoccurrec.emchcode
									AND
									pfclass.pfinnseq = pfinseq;
							END IF;
							IF labilabi = 'LABILABILABI' OR labilabi = 'VTANVTANVTAN' AND v_fincal = 'VTAN' THEN
                --自付,不可申報輔導會
								v_other_price   := 0;
								v_self_price    := v_self_price - v_other_price;
							ELSE
								v_other_price   := v_self_price * (1 - v_salf_per);
								v_self_price    := v_self_price - v_other_price;
								IF v_fincal = 'VTAN' AND v_insu_per > 0 THEN
									v_fincal := 'VERT';
								END IF;
							END IF;
							v_other_fincal   := v_fincal;
						END IF;
						CLOSE cur_disc;
					END IF;
					CLOSE cur_pfclass3;
				END IF; --需要自付END

        --是否為自費項
				IF emgoccurrec.emchanes = 'PR' THEN
          --榮民是否可以轉為輔導會支付
					OPEN cur_pfclass5 (emgoccurrec.emchcode, trunc (emgoccurrec.emocdate));
					FETCH cur_pfclass5 INTO
						v_pf_self_pay,
						v_pf_nh_pay,
						v_pf_child_pay,
						v_fincal;
					IF cur_pfclass5%found THEN
						v_nh_price       := 0;
						v_other_price    := v_pf_nh_pay;
						v_self_price     := v_pf_self_pay;
						v_other_fincal   := v_fincal;
						IF v_fincal = 'VTAN' AND v_other_price > 0 THEN
							v_other_fincal := 'VERT'; --轉為輔導會
						END IF;
					ELSE            
            --以自費計
						v_self_price    := v_price;
						v_nh_price      := 0;
						v_other_price   := 0;
            --判斷是否折扣身份
						v_disctype      := 'P'; --自費TYPE
						OPEN cur_disc (v_disctype, pcaseno, emgoccurrec.emchtyp1, trunc (emgoccurrec.emocdate));
						FETCH cur_disc INTO
							v_salf_per,
							v_fincal,
							v_insu_per;
						IF cur_disc%found THEN
							v_self_price     := v_price * v_salf_per;
							v_nh_price       := 0;
							v_other_price    := v_price - v_self_price;
							v_other_fincal   := v_fincal;
						END IF;
						CLOSE cur_disc;
					END IF;
					CLOSE cur_pfclass5;
				END IF; --END IF emgOccurRec.EMCHANES = 'PR'
			END IF; --END IFemgOccurRec.EMCHTYP1 = '6' or emgOccurRec.EMCHTYP1 = '06'...

      --手術單價計算
      --                     第一刀     第二刀     第三刀
      --同一刀口,多項          100        50        x
      --不同刀口,同類          100        50       20
      --不同刀口,不同類        100       100       33
      --同一刀口,多項
      --健保身份才要依循
			IF f_getnhrangeflag (pcaseno => pcaseno, pdate => emgoccurrec.emocdate, pfinflag => '1') IN (
				'LABI',
				'CIVC'
			) THEN
				IF emgoccurrec.emchtyp1 = '07' THEN
					IF emgoccurrec.emorcat = '2' THEN
						IF emgoccurrec.emororno = '1' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSIF emgoccurrec.emororno = '2' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0.5;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0;
						END IF;
            --不同刀口,同類
					ELSIF emgoccurrec.emorcat = '3' THEN
						IF emgoccurrec.emororno = '1' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSIF emgoccurrec.emororno = '2' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0.5;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0.2;
						END IF;
            --不同刀口,不同類
					ELSIF emgoccurrec.emorcat = '4' THEN
						IF emgoccurrec.emororno = '1' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSIF emgoccurrec.emororno = '2' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1 / 3;
						END IF;
					ELSIF emgoccurrec.emorcat = '7' THEN --7_多項同類或兩側性手術(1+0.5+0.5+0) by kuo 20171018
						IF emgoccurrec.emororno = '1' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSIF emgoccurrec.emororno IN (
							'2',
							'3'
						) THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0.5;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0;
						END IF;
					ELSIF emgoccurrec.emorcat = '8' THEN --8_多項不同類手術(1+1+0.5+0) by kuo 20171018
						IF emgoccurrec.emororno IN (
							'1',
							'2'
						) THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSIF emgoccurrec.emororno = '3' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0.5;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0;
						END IF;
					ELSIF emgoccurrec.emorcat = '9' THEN --9_多重創傷(ISS>=16)並施行多項胸腹手術(1+1+1+1) by kuo 20171018
						IF emgoccurrec.emororno IN (
							'1',
							'2',
							'3',
							'4'
						) THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0;
						END IF;
					END IF; --END IF emgOccurRec.EMORCAT = '2'
          --併發症,第一刀才算錢
					IF emgoccurrec.emorcomp = 'Y' THEN
						IF emgoccurrec.emororno = '1' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0.5;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0;
						END IF;
					END IF;
				END IF; --END IF emgOccurRec.EMCHTYP1 = '07'
			END IF; --f_getnhrangeflag(pCaseNo => pCaseNo...

      --套餐不計價980303 BY KUO, 急診會有嗎?
			IF emgoccurrec.emchtyp3 = '1' THEN
				v_keep_amount_flag     := 'Y';
				emgoccurrec.emchamt1   := 0;
			END IF;
			IF v_nh_price > 0 THEN
				v_keep_amount_flag := 'N';
			END IF;

      --以EMG_OCCUR金額為主不重取dbpfile金額
			IF v_keep_amount_flag = 'Y' AND v_self_price <> 0 AND v_other_price = 0 THEN
				v_self_price   := emgoccurrec.emchamt1 / emgoccurrec.emchqty1;
				v_self_amt     := emgoccurrec.emchamt1;
        --因為回歸原價,所以要把手材費用歸回手術費中
				IF emgacntwkrec.fee_kind = '11' THEN
					emgacntwkrec.fee_kind   := '07';
					v_fee_kind              := '07';
					v_self_price            := 0;
					v_self_amt              := 0;
				END IF;
			ELSE
				IF emgacntwkrec.fee_kind = '11' THEN
					emgacntwkrec.fee_kind   := '07';
					v_fee_kind              := '07';
					v_other_price           := 0;
					v_self_amt              := 0;
				END IF;
        --IF V_FEE_KIND = '12' THEN
        --  emgOccurRec.EMCHQTY1 := 1;
        --END IF;
			END IF; --END IF v_keep_amount_flag = 'Y'

      --處理新生兒費用轉到NHI--急診無

      --再抓一次PFCLASS LABI部份     
			IF v_self_price > 0 THEN
				OPEN cur_pfclass4 (emgoccurrec.emchcode);
				FETCH cur_pfclass4 INTO pfclassrec;
				IF cur_pfclass4%found THEN
					IF substr (pfclassrec.pfselpay, 6, 3) || substr (pfclassrec.pfreqpay, 1, 1) = 'LABI' THEN
						OPEN cur_pfclass2 (emgoccurrec.emchcode, trunc (emgoccurrec.emocdate));
						FETCH cur_pfclass2 INTO
							v_pf_self_pay,
							v_pf_nh_pay,
							v_pf_child_pay,
							v_feemep_flag,
							v_pfopfg_flag,
							v_pfspexam,
							vpfinseq;
						IF cur_pfclass2%notfound THEN
							v_pf_self_pay    := v_price;
							v_pf_nh_pay      := 0;
							v_pf_child_pay   := 0;
							IF emgacntwkrec.emg_flag = 'E' AND emgacntwkrec.emg_per = 1 THEN
								emgacntwkrec.emg_per := 1 + (v_pfemep / 100);
							END IF;
							v_feemep_flag    := 'N';
							v_pfopfg_flag    := 'N';
							v_pfspexam       := 'N';
						END IF;
						CLOSE cur_pfclass2;
						v_self_price   := v_pf_self_pay;
						v_nh_price     := v_pf_nh_pay;
					END IF;
				END IF;
				CLOSE cur_pfclass4;
			END IF;
			IF emgoccurrec.emchrgcr = '-' THEN
				emgoccurrec.emchqty1 := -1 * emgoccurrec.emchqty1;
			END IF;

      --dbms_output.put_line('emgAcntWkRec.Emg_Per:'|| emgAcntWkRec.Emg_Per);
      --dbms_output.put_line('n:'||v_nh_price||',s:'||v_self_price||',o:'||v_other_price);
			v_self_amt                    := v_self_price * emgoccurrec.emchqty1 * emgacntwkrec.emg_per;
      --v_nh_amt    := v_nh_price    * emgOccurRec.EMCHQTY1 * emgAcntWkRec.Emg_Per * v_lab_disc_pert;
			v_nh_amt                      := v_nh_price * emgoccurrec.emchqty1 * emgacntwkrec.emg_per;
			v_other_amt                   := v_other_price * emgoccurrec.emchqty1 * emgacntwkrec.emg_per;
			emgacntwkrec.caseno           := pcaseno;
      --v_acnt_seq := v_acnt_seq + 1;
      --emgAcntWkRec.Acnt_Seq   := v_acnt_seq ;
      --emgAcntWkRec.Acnt_Seq   := emgOccurRec.Acnt_Seq; ???

      --取emg_occur的pfkey值序號累加,之後醫收會用到此欄位,急診因沒有Acnt_Seq,另做序號(update by amber 20110422)
			emgacntwkrec.seq_no           := f_get_seq_no (pcaseno);
			emgacntwkrec.price_code       := emgoccurrec.emchcode;
			emgacntwkrec.fee_kind         := v_fee_kind;
			emgacntwkrec.qty              := emgoccurrec.emchqty1;
			emgacntwkrec.tqty             := emgoccurrec.emchqty1;
			emgacntwkrec.emg_flag         := emgoccurrec.emchemg;
			emgacntwkrec.emg_per          := emgacntwkrec.emg_per;
			emgacntwkrec.insu_amt         := v_nh_price;
			emgacntwkrec.self_amt         := v_self_price;
			emgacntwkrec.part_amt         := v_other_price;
			IF emgoccurrec.emchanes <> 'PR' OR emgoccurrec.emchanes IS NULL THEN
				emgacntwkrec.self_flag := 'N';
			ELSE
				emgacntwkrec.self_flag := 'Y';
			END IF;
      --dbms_output.put_line(emgAcntWkRec.Self_Flag);
      -- emgAcntWkRec.Order_Doc  :=
			emgacntwkrec.bed_no           := patemgcaserec.emgbedno;
			emgacntwkrec.start_date       := emgoccurrec.emocdate;
			emgacntwkrec.end_date         := emgoccurrec.emocdate;
			emgacntwkrec.nh_type          := v_fee_type;
			emgacntwkrec.cost_code        := emgoccurrec.emchidep;
			emgacntwkrec.keyin_date       := emgoccurrec.embldate;
			emgacntwkrec.ward             := emgoccurrec.emocns;
			emgacntwkrec.clerk            := emgoccurrec.emuserid;
			emgacntwkrec.order_seq        := emgoccurrec.ordseq;
      --emgAcntWkRec.Old_Acnt_Seq := emgOccurRec.Acnt_Seq; ???
			emgacntwkrec.emblpk           := emgoccurrec.emblpk;
			emgacntwkrec.bildate          := emgoccurrec.emocdate;
			emgacntwkrec.stock_code       := emgoccurrec.emocdist;
			emgacntwkrec.dept_code        := emgoccurrec.emocsect;

      --emgAcntWkRec.e_Level := v_e_level; 急診無
      --94005060 always using contract 1155 by kuo 20161024 without entrying contract
			IF emgacntwkrec.price_code = '94005060' THEN
				emgacntwkrec.self_amt   := 0;
				v_other_amt             := v_self_amt;
				v_other_price           := v_self_price;
				v_self_price            := 0;
				v_self_amt              := 0;
				v_other_fincal          := '1155';
			END IF;

      --1151,1152 with 90578604 whenever is PR all count to 1151 by kuo 20161227
      --1193 比照 1151 by kuo 20170517
			IF emgacntwkrec.price_code IN (
				'90578604',
				'DIAGALOC',
				'00000002'
			) AND patemgcaserec.emgspeu1 IN (
				'1151',
				'1152',
				'1193'
			) THEN
				emgacntwkrec.self_amt   := 0;
				IF v_self_amt > 0 THEN
					v_other_amt     := v_self_amt;
					v_other_price   := v_self_price;
				ELSE
					v_other_amt     := v_nh_amt;
					v_other_price   := v_nh_price;
				END IF;
				v_self_price            := 0;
				v_self_amt              := 0;
				v_nh_price              := 0;
				v_nh_amt                := 0;
				v_other_fincal          := patemgcaserec.emgspeu1;
			END IF;
			IF v_nh_amt <> 0 THEN
        --健保藥費
				IF emgoccurrec.emchtyp1 = '6' OR emgoccurrec.emchtyp1 = '06' THEN
					v_acnt_seq                  := v_acnt_seq + 1;
					emgacntwkrec.acnt_seq       := v_acnt_seq;
					emgacntwkrec.ins_fee_code   := v_ins_fee_code;
					emgacntwkrec.self_amt       := 0;
					emgacntwkrec.part_amt       := 0;
					emgacntwkrec.pfincode       := 'LABI';
					emgacntwkrec.bildate        := emgoccurrec.emocdate;
          --Add by Kuo 970507
					IF emgoccurrec.emchrgcr = '-' THEN
						IF emgacntwkrec.insu_amt < 0 THEN
              --MAKE SURE Insu_Amt IS > 0,因為QTY會<0
							emgacntwkrec.insu_amt := emgacntwkrec.insu_amt * -1;
						END IF;
						IF emgacntwkrec.qty > 0 THEN
							emgacntwkrec.qty    := emgacntwkrec.qty * -1;
							emgacntwkrec.tqty   := emgacntwkrec.qty;
						END IF;
					END IF;
          --dbms_output.put_line('i6n');
					INSERT INTO emg_bil_acnt_wk VALUES emgacntwkrec;
				ELSE
          --健保非藥費 ,攤健保碼
					v_nh_amt1   := 0;
					v_emg_per   := emgacntwkrec.emg_per;
					OPEN cur_3 (emgacntwkrec.price_code, vpfinseq);
					LOOP
						FETCH cur_3 INTO
							v_ins_fee_code,
							v_labi_qty;
						EXIT WHEN cur_3%notfound;
						emgacntwkrec.emg_per        := v_emg_per;
            --v_acnt_seq := v_acnt_seq + 1;
            --emgAcntWkRec.Acnt_Seq   := v_acnt_seq ;
						IF v_labi_qty IS NULL THEN
							v_labi_qty := 1;
						END IF;
						emgacntwkrec.ins_fee_code   := rtrim (v_ins_fee_code);
						BEGIN
							SELECT
								vsnhi.labprice,
								vsnhi.nhinpric,
								vsnhi.nhitype,
								vsnhi.labchild,
								vsnhi.labchild_inc
							INTO
								v_labprice,
								v_nhipric,
								v_fee_type,
								v_labchild,
								v_labchild_inc
              --FROM cpoe.vsnhi
							FROM
								vsnhi
							WHERE
								vsnhi.labkey = emgacntwkrec.ins_fee_code
								AND
								(labbdate <= trunc (emgoccurrec.emocdate)
								 OR
								 labbdate IS NULL)
								AND
								labedate >= trunc (emgoccurrec.emocdate);
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

            --add by kuo 20160901以後改到 getEMgPer裡面算
						IF TO_CHAR (patemgcaserec.emgdt, 'YYYYMMDD') < '20160901' THEN
               --如果pfclass 要兒童加成,vsnhi不需加成,要扣回來
							IF v_pf_child_pay > 0 AND v_labchild <> 'Y' THEN
								IF v_child_flag_1 = 'Y' THEN
									emgacntwkrec.emg_per := v_emg_per - 0.2;
								END IF;
								IF v_child_flag_2 = 'Y' THEN
									emgacntwkrec.emg_per := v_emg_per - 0.3;
								END IF;
								IF v_child_flag_3 = 'Y' THEN
									emgacntwkrec.emg_per := v_emg_per - 0.6;
								END IF;
							END IF;

               --add LABCHILD_INC 提升兒童加成急做 add by kuo 20140128
               --時間在VSNHI抓取時已經判斷了
               --因應兩個都有的問題只取大的 by kuo 20140221
							IF v_labchild_inc = 'Y' THEN
								IF v_child_flag_1 = 'Y' THEN
                     --EMGACNTWKREC.EMG_PER := EMGACNTWKREC.EMG_PER+0.6;
									emgacntwkrec.emg_per := 0.6;
								END IF;
								IF v_child_flag_2 = 'Y' THEN
                     --EMGACNTWKREC.EMG_PER := EMGACNTWKREC.EMG_PER+0.8;
									emgacntwkrec.emg_per := 0.8;
								END IF;
								IF v_child_flag_3 = 'Y' THEN
                     --EMGACNTWKREC.EMG_PER := EMGACNTWKREC.EMG_PER+1;
									emgacntwkrec.emg_per := 1;
								END IF;
							END IF;
						END IF;

             --20171001起生效 add by kuo 20171012
            --急診診察費(按檢傷分類)'00201B','00202B','00203B','00204B','00225B',如遇兒科專科醫師加計50%            
						IF emgacntwkrec.ins_fee_code IN (
							'00201B',
							'00202B',
							'00203B',
							'00204B',
							'00225B'
						) AND emgoccurrec.emocdate >= TO_DATE ('20171001', 'YYYYMMDD') THEN
							vcardno := '';
							OPEN ped_cardno (patemgcaserec.emgvsno); --改成VSNO by kuo 20171013
							FETCH ped_cardno INTO vcardno;
							CLOSE ped_cardno;
               --DBMS_OUTPUT.PUT_LINE(VCARDNO);
							IF vcardno IS NOT NULL THEN
								emgacntwkrec.emg_per := emgacntwkrec.emg_per + 0.5;
							ELSE --非兒專醫師之就醫對象，年齡為6個月以上至6歲以下兒童者(就醫年月減出生年月大於等於6個月、小於等於83個月)，另加計50%。(自費用年月109年1月起新增) request by 陳孟琪 20200110, kuo 20200110   
								IF emgoccurrec.emocdate >= TO_DATE ('20201001', 'YYYYMMDD') THEN
									IF v_child_flag_1 = 'Y' OR v_child_flag_2 = 'Y' THEN
										emgacntwkrec.emg_per := emgacntwkrec.emg_per + 0.5;
									END IF;
								END IF;
							END IF;
						END IF;
						emgacntwkrec.insu_amt       := v_labprice;
						emgacntwkrec.nh_type        := v_fee_type;
						emgacntwkrec.qty            := v_labi_qty * emgoccurrec.emchqty1;
						emgacntwkrec.tqty           := v_labi_qty * emgoccurrec.emchqty1;

            --計算衛材成數
            /*MARK BY KUO ,NO NEED TO COUNT ON THIS TIME 1000707
            IF v_fee_type = '12' THEN
              IF v_nhipric < 30000 THEN
                IF v_labprice = v_nhipric THEN
                  emgAcntWkRec.Emg_Per := 1;
                ELSE
                  emgAcntWkRec.Emg_Per := 1.05;
                END IF;
              ELSE
                emgAcntWkRec.Emg_Per := 1;
              END IF;
              emgAcntWkRec.Insu_Amt := v_nhipric;
            END IF;
            */
						IF emgoccurrec.emchrgcr = '-' THEN
							IF emgacntwkrec.insu_amt < 0 THEN
                --MAKE SURE Insu_Amt IS > 0,因為QTY會<0
								emgacntwkrec.insu_amt := emgacntwkrec.insu_amt * -1;
							END IF;
							IF emgacntwkrec.qty > 0 THEN
								emgacntwkrec.qty    := emgacntwkrec.qty * -1;
								emgacntwkrec.tqty   := emgacntwkrec.qty;
							END IF;
						END IF;
						v_nh_amt1                   := v_nh_amt1 + (emgacntwkrec.insu_amt * emgacntwkrec.qty * emgacntwkrec.emg_per);
						emgacntwkrec.self_amt       := 0;
						emgacntwkrec.part_amt       := 0;
						emgacntwkrec.pfincode       := 'LABI';
						emgacntwkrec.bildate        := emgoccurrec.emocdate;
            --dbms_output.put_line('ixn');
						BEGIN
							INSERT INTO emg_bil_acnt_wk VALUES emgacntwkrec;
						EXCEPTION
							WHEN OTHERS THEN
								v_acnt_seq              := v_acnt_seq + 1;
								emgacntwkrec.acnt_seq   := v_acnt_seq;
                --emgAcntWkRec.Seq_No     :=
								emgacntwkrec.pfincode   := 'LABI';
								emgacntwkrec.self_amt   := 0;
								emgacntwkrec.part_amt   := 0;
								INSERT INTO emg_bil_acnt_wk VALUES emgacntwkrec;
						END;
					END LOOP;
					CLOSE cur_3;
					IF v_nh_amt <> v_nh_amt1 AND v_nh_amt1 <> 0 THEN
						v_nh_amt := v_nh_amt1;
					END IF;

          --FOR 健保福
          --因為沒有健保碼又要算健保價,只好硬塞進去....@_@
          --急診無
				END IF; --IF emgOccurRec.Fee_Kind = '6'
			END IF; --IF v_nh_amt <> 0

      --員工 掛號費減免,由折扣檔
      /*
      IF patemgcaseRec.emg2fncl = '6' AND emgOccurRec.EMCHTYP1 = '37' THEN
        v_other_amt    := v_self_amt + v_other_amt;
        v_nh_amt       := 0;
        v_self_amt     := 0;
        v_other_fincal := 'EMPL';
        */ 
        --FOR 健保福 掛號費減免
			IF patemgcaserec.emgcopay = '003' AND emgoccurrec.emchtyp1 = '37' THEN
				v_other_amt      := v_self_amt;
				v_other_price    := v_other_amt;
				v_nh_amt         := 0;
				v_self_amt       := 0;
        --v_other_fincal := 'NHI3';
				v_other_fincal   := 'HOSP';
			END IF;
      --新增第二身份為F,掛號費報輔導會 from 20160301 by kuo
			IF patemgcaserec.emg2fncl = 'F' AND emgoccurrec.emchtyp1 = '37' THEN
				v_other_amt      := v_self_amt;
				v_other_price    := v_other_amt;
				v_nh_amt         := 0;
				v_self_amt       := 0;
				v_other_fincal   := 'VERT';
			END IF;
			IF v_self_amt <> 0 THEN
        --將官病房費優減關於 emg_bil_acnt_wk BY KUO 970430,急診無
				emgacntwkrec.ins_fee_code   := emgacntwkrec.price_code;
				emgacntwkrec.self_flag      := 'Y';
				v_acnt_seq                  := v_acnt_seq + 1;
				emgacntwkrec.acnt_seq       := v_acnt_seq;
				emgacntwkrec.insu_amt       := 0;
				emgacntwkrec.part_amt       := 0;
				emgacntwkrec.self_amt       := v_self_price;
				emgacntwkrec.pfincode       := 'CIVC';
        --emgAcntWkRec.Pfincode     := v_finCode;
				emgacntwkrec.bildate        := emgoccurrec.emocdate;
        --   emgAcntWkRec.Self_Amt := v_self_amt;
        --dbms_output.put_line('ixc');
				INSERT INTO emg_bil_acnt_wk VALUES emgacntwkrec;
			END IF;
			IF v_other_amt <> 0 THEN
				emgacntwkrec.ins_fee_code   := emgacntwkrec.price_code;
				emgacntwkrec.self_flag      := 'Y';
				v_acnt_seq                  := v_acnt_seq + 1;
				emgacntwkrec.acnt_seq       := v_acnt_seq;
				emgacntwkrec.insu_amt       := 0;
				emgacntwkrec.self_amt       := 0;
				emgacntwkrec.part_amt       := v_other_price;
				emgacntwkrec.pfincode       := v_other_fincal;
				emgacntwkrec.bildate        := emgoccurrec.emocdate;
        --dbms_output.put_line('ixo');
				INSERT INTO emg_bil_acnt_wk VALUES emgacntwkrec;
			END IF;

      --UPDATE EMG_bil_feedtl
      --ADD IF CLERK='NHIMOVE' 是屬於急診搬到住院，但是還是要顯示，不能加到FEEDTL
      --IF V_NH_AMT <> 0 THEN
			IF v_nh_amt <> 0 AND (emgacntwkrec.clerk <> 'NHIMOVE' OR emgacntwkrec.clerk IS NULL) THEN
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					emg_bil_feedtl
				WHERE
					emg_bil_feedtl.caseno = pcaseno
					AND
					emg_bil_feedtl.fee_type = v_fee_kind
					AND
					emg_bil_feedtl.pfincode = 'LABI';
				IF v_cnt = 0 THEN
					emgfeedtlrec.caseno             := pcaseno;
					emgfeedtlrec.fee_type           := v_fee_kind;
					emgfeedtlrec.pfincode           := 'LABI';
					emgfeedtlrec.total_amt          := v_nh_amt;
					emgfeedtlrec.created_by         := 'biling';
					emgfeedtlrec.created_date       := SYSDATE;
					emgfeedtlrec.last_updated_by    := 'biling';
					emgfeedtlrec.last_update_date   := SYSDATE;
					INSERT INTO emg_bil_feedtl VALUES emgfeedtlrec;
				ELSE
					UPDATE emg_bil_feedtl
					SET
						total_amt = total_amt + v_nh_amt
					WHERE
						emg_bil_feedtl.caseno = pcaseno
						AND
						emg_bil_feedtl.fee_type = v_fee_kind
						AND
						emg_bil_feedtl.pfincode = 'LABI';
				END IF;
			END IF;
      --ADD IF CLERK='NHIMOVE' 是屬於急診搬到住院，但是還是要顯示，不能加到FEEDTL
			IF v_self_amt <> 0 AND (emgacntwkrec.clerk <> 'NHIMOVE' OR emgacntwkrec.clerk IS NULL) THEN
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					emg_bil_feedtl
				WHERE
					emg_bil_feedtl.caseno = pcaseno
					AND
					emg_bil_feedtl.fee_type = v_fee_kind
					AND
					emg_bil_feedtl.pfincode = 'CIVC';
				IF v_cnt = 0 THEN
					emgfeedtlrec.caseno             := pcaseno;
					emgfeedtlrec.fee_type           := v_fee_kind;
					emgfeedtlrec.pfincode           := 'CIVC';
					emgfeedtlrec.total_amt          := v_self_amt;
					emgfeedtlrec.created_by         := 'biling';
					emgfeedtlrec.created_date       := SYSDATE;
					emgfeedtlrec.last_updated_by    := 'biling';
					emgfeedtlrec.last_update_date   := SYSDATE;
					INSERT INTO emg_bil_feedtl VALUES emgfeedtlrec;
				ELSE
					UPDATE emg_bil_feedtl
					SET
						total_amt = total_amt + v_self_amt
					WHERE
						emg_bil_feedtl.caseno = pcaseno
						AND
						emg_bil_feedtl.fee_type = v_fee_kind
						AND
						emg_bil_feedtl.pfincode = 'CIVC';
				END IF;
			END IF;
      --ADD IF CLERK='NHIMOVE' 是屬於急診搬到住院，但是還是要顯示，不能加到FEEDTL
			IF v_other_amt <> 0 AND (emgacntwkrec.clerk <> 'NHIMOVE' OR emgacntwkrec.clerk IS NULL) THEN
				SELECT
					COUNT (*)
				INTO v_cnt
				FROM
					emg_bil_feedtl
				WHERE
					emg_bil_feedtl.caseno = pcaseno
					AND
					emg_bil_feedtl.fee_type = v_fee_kind
					AND
					emg_bil_feedtl.pfincode = v_other_fincal;
				IF v_cnt = 0 THEN
					emgfeedtlrec.caseno             := pcaseno;
					emgfeedtlrec.fee_type           := v_fee_kind;
					emgfeedtlrec.pfincode           := v_other_fincal;
					emgfeedtlrec.total_amt          := v_other_amt;
					emgfeedtlrec.created_by         := 'biling';
					emgfeedtlrec.created_date       := SYSDATE;
					emgfeedtlrec.last_updated_by    := 'biling';
					emgfeedtlrec.last_update_date   := SYSDATE;
					INSERT INTO emg_bil_feedtl VALUES emgfeedtlrec;
				ELSE
					UPDATE emg_bil_feedtl
					SET
						total_amt = total_amt + v_other_amt
					WHERE
						emg_bil_feedtl.caseno = pcaseno
						AND
						emg_bil_feedtl.fee_type = v_fee_kind
						AND
						emg_bil_feedtl.pfincode = v_other_fincal;
				END IF;
			END IF;
			IF v_nh_amt IS NULL THEN
				v_nh_amt := 0;
			END IF;
			IF v_self_amt IS NULL THEN
				v_self_amt := 0;
			END IF;
      --由於急診無LEVEL之分,一律放在LEVLE1,部份負擔為固定費用
			v_e_level                     := 1;
			emgfeemstrec.emg_exp_amt1     := emgfeemstrec.emg_exp_amt1 + v_nh_amt;
			IF emgacntwkrec.clerk <> 'NHIMOVE' OR emgacntwkrec.clerk IS NULL THEN
				IF f_getnhrangeflag (pcaseno, emgoccurrec.emocdate, '2') = 'NHI0' THEN
          --dbms_output.put_line(v_self_amt);
					UPDATE emg_bil_feemst
					SET
						emg_bil_feemst.emg_exp_amt1 = emg_bil_feemst.emg_exp_amt1 + v_nh_amt,
                 --EMG_bil_feemst.emg_pay_amt1 = EMG_bil_feemst.emg_pay_amt1 + v_nh_amt,
						emg_bil_feemst.tot_gl_amt = emg_bil_feemst.tot_gl_amt + v_self_amt
					WHERE
						emg_bil_feemst.caseno = pcaseno;
				ELSE
          --dbms_output.put_line('NHI0x');
					UPDATE emg_bil_feemst
					SET
						emg_bil_feemst.emg_exp_amt1 = emg_bil_feemst.emg_exp_amt1 + v_nh_amt,
						emg_bil_feemst.tot_gl_amt = emg_bil_feemst.tot_gl_amt + v_self_amt
					WHERE
						emg_bil_feemst.caseno = pcaseno;
				END IF;
			END IF;
		END LOOP;
		CLOSE cur_occur;

    --健保規則檢視 健保身分才做
    /*
    IF patemgcaseRec.emg1fncl = '7' THEN
          p_Transnhrule(pCaseNo => pCaseNo);
    END IF;
    */
		SELECT
			*
		INTO emgfeemstrec
		FROM
			emg_bil_feemst
		WHERE
			emg_bil_feemst.caseno = pcaseno;

    --部份負擔
		IF f_getnhrangeflag (pcaseno, patemgcaserec.emgdt, '2') = 'NHI0' THEN
      -- 牙科部分負擔 150
      -- 新增OS為牙科 by kuo 20151210
      -- add patemgcaseRec.EMGCOPAY='E00' for dent by kuo 20160620
      -- 大科與小科不符和，以小科為主 by kuo 20160620, 20160621生效
      --SELECT EMG_DEPT FROM VGHTC.DB_SECTION_NEW WHERE EMG_USE='Y' and EMG_CLINIC='PER';
      --IF PATEMGCASEREC.EMGDT >= TO_DATE('20160621','YYYYMMDD') THEN
      --改成 20160809
			IF patemgcaserec.emgdt >= TO_DATE ('20160801', 'YYYYMMDD') THEN
				BEGIN
					SELECT
						emg_dept
					INTO vdept
					FROM
						vghtc.db_section_new 
         --WHERE EMG_USE='Y' AND EMG_CLINIC=PATEMGCASEREC.EMGSECT;
					WHERE
						emg_use = 'Y'
						AND
						ename = patemgcaserec.emgsect; --避免判斷不到 by kuo 20160808
				EXCEPTION
					WHEN OTHERS THEN
						vdept := patemgcaserec.emgdept;
				END;
				patemgcaserec.emgdept := vdept;
			END IF;
			IF patemgcaserec.emgdept = 'DENT' OR patemgcaserec.emgsect = 'OS' OR patemgcaserec.emgcopay = 'E00' THEN
				IF emgfeemstrec.emg_exp_amt1 > 150 THEN
					emgfeemstrec.emg_pay_amt1 := 150;
				ELSE
					emgfeemstrec.emg_pay_amt1 := emgfeemstrec.emg_exp_amt1;
				END IF;
			ELSE
        -- 其他科部份負擔 450
        -- 檢傷 1,2 級與來院時間介於0-6之間 450, 其餘檢傷 3-5 550 by kuo 20170216
        -- 時間未定...
        -- 取消時間 by Kuo 20170320
        --生效時間為 20170415
				maxcopay := 550;
        --IF TRIAGE IN ('1','2') OR 
        --   (to_CHAR(patemgcaseRec.EMGDT,'HH24') >= 0 AND to_CHAR(patemgcaseRec.EMGDT,'HH24')<=6) THEN
        --組長要求因主秘要求要暫緩15分鐘...by kuo 20170414
				IF triage IN (
					'1',
					'2'
				) OR patemgcaserec.emgdt <= TO_DATE ('201704150015', 'YYYYMMDDHH24MI') THEN
					maxcopay := 450;
				END IF;
        --以下 450 改成 MaxCoPay by Kuo 20170216
				IF emgfeemstrec.emg_exp_amt1 > maxcopay THEN
					emgfeemstrec.emg_pay_amt1 := maxcopay;
				ELSE
					IF poper = 'Y' THEN
						emgfeemstrec.emg_pay_amt1 := maxcopay;
					ELSE
						emgfeemstrec.emg_pay_amt1 := emgfeemstrec.emg_exp_amt1;
					END IF;
				END IF;
			END IF;
		END IF;
		UPDATE emg_bil_feemst
		SET
			emg_bil_feemst.emg_pay_amt1 = emgfeemstrec.emg_pay_amt1,
			emg_bil_feemst.tot_self_amt = emgfeemstrec.emg_pay_amt1
		WHERE
			emg_bil_feemst.caseno = pcaseno;
		IF emgfeemstrec.emg_pay_amt1 > 0 THEN
			emgfeedtlrec.caseno             := pcaseno;
			emgfeedtlrec.fee_type           := '41';
			emgfeedtlrec.pfincode           := 'CIVC';
			emgfeedtlrec.total_amt          := emgfeemstrec.emg_pay_amt1;
			emgfeedtlrec.created_by         := 'biling';
			emgfeedtlrec.created_date       := SYSDATE;
			emgfeedtlrec.last_updated_by    := 'biling';
			emgfeedtlrec.last_update_date   := SYSDATE;
			INSERT INTO emg_bil_feedtl VALUES emgfeedtlrec;
		END IF;
		v_cnt                           := 0;
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			tmp_fincal
		WHERE
			tmp_fincal.caseno = pcaseno
			AND
			tmp_fincal.fincalcode IN (
				'1059',
				'1062',
				'1058',
				'9520'
			); 
    --add 9520 by kuo 20150629
    --NEW ADD BY KUO 1001211
    --('1058','1054','1039','1060','1083') 舊;
		IF patemgcaserec.emg2fncl IN (
			'E',
			'1',
			'6'
		) OR v_cnt > 0 THEN
			p_modifityselfpay (pcaseno, patemgcaserec.emg2fncl, v_acnt_seq);
		END IF;

    --國際醫療S999 BY KUO 20121128
    --IF patemgcaseRec.EMGSPEU1='S999' THEN
    --   CONTRACT_ES999(PCASENO);
    --END IF;

        -- 分攤單位 LABI 不變，搬帳到住院申報。掛號費調整至 1060 分攤單位。   
		adjust_1060_acnt_wk (pcaseno);
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := emgoccurrec.emchcode || ',' || sqlerrm;
			bil_sendmail ('', '', v_program_name || ' Error', pcaseno || ',' || v_error_code || ',' || v_error_info);
			bil_sendmail ('', 'cc3f@vghtc.gov.tw', v_program_name || ' Error', pcaseno || ',' || v_error_code || ',' || v_error_info);
      --dbms_output.put_line(v_program_name || ',' || v_error_code || ',' ||
      --                     v_error_info);
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
				pcaseno
			);
			COMMIT WORK;
	END; --END CompAcntWk

  --計算醫令明細
	PROCEDURE acntwkcalculate (
		pcaseno VARCHAR2
	) IS
		CURSOR cur_master IS
		SELECT
			fee_kind
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
		GROUP BY
			fee_kind;
		CURSOR cur_1 (
			pfeekind VARCHAR2
		) IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.fee_kind = pfeekind
		ORDER BY
			fee_kind,
			price_code,
			start_date,
			cir_code,
			qty,
			emg_flag,
			self_flag,
			bed_no;
		CURSOR cur_2 (
			pfeekind VARCHAR2
		) IS
		SELECT
			price_code,
			fee_kind,
			emg_flag,
			self_flag,
			bed_no,
			stock_code,
			MIN (start_date),
			MAX (end_date),
			insu_amt,
			self_amt,
			part_amt,
			SUM (tqty)
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.fee_kind = pfeekind
		GROUP BY
			emg_bil_acnt_wk.price_code,
			emg_bil_acnt_wk.fee_kind,
			emg_bil_acnt_wk.emg_flag,
			emg_bil_acnt_wk.self_flag,
			emg_bil_acnt_wk.bed_no,
			emg_bil_acnt_wk.stock_code,
			emg_bil_acnt_wk.start_date,
			emg_bil_acnt_wk.end_date,
			emg_bil_acnt_wk.insu_amt,
			emg_bil_acnt_wk.self_amt,
			emg_bil_acnt_wk.part_amt;
		CURSOR cur_3 (
			pfeekind VARCHAR2
		) IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.fee_kind = pfeekind;

    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_fee_kind       VARCHAR2 (10);
		emgacntwkrec     emg_bil_acnt_wk%rowtype;
		currec_2         cur_2%rowtype;
		emgacntdetrec    emg_bil_acntdet%rowtype;
    --emgAcntDetWkRec emg_acntdet%ROWTYPE;
		v_cnt            INTEGER;
		v_seqno          INTEGER;
		v_tqty           NUMBER (8, 2);
		v_flag           VARCHAR2 (01) := 'N';
	BEGIN
    --設定程式名稱及session_id
		v_program_name         := 'emg_calculate_PKG.AcntWkCalculate';
		v_session_id           := userenv ('SESSIONID');
		v_source_seq           := pcaseno;

    --依各類別取出acntwk資料作匯總,寫入醫令明細中
		emgacntdetrec.caseno   := pcaseno;
		v_seqno                := 0;
		OPEN cur_master;
		LOOP
			FETCH cur_master INTO v_fee_kind;
			EXIT WHEN cur_master%notfound;

      --藥費
      /*TRIM(ntwks_ipd_seq) = TRIM(saves_ipd_seq) AND (ntwks_self_flag) = TRIM(saves_self_flag) AND (ntwks_fee_type) = TRIM(saves_fee_type) AND (ntwks_fee_kind) = TRIM(saves_fee_kind) AND (ntwks_ins_fee_code) = TRIM(saves_ins_fee_code) AND  = saved_insu_amt AND  = saved_part_amt AND  = saved_self_amt AND &(ntwkd_qty = saved_qty OR ntwkd_qty < 0 OR saved_qty < 0) AND (ntwks_bed_no) = TRIM(saves_bed_no) AND  = saved_emg_per AND (ntwks_emg_flag) = TRIM(saves_emg_flag) AND (ntwks_cir_code) = TRIM(saves_cir_code) AND (ntwks_start_date) = TRIM(ls_next_start_date ) AND (ntwks_out_med_flag) = TRIM(saves_out_med_flag))*/
      --  IF v_fee_kind = '13' THEN
			v_cnt                      := 0;
			v_tqty                     := 0;
			OPEN cur_1 (v_fee_kind);
			LOOP
				EXIT WHEN cur_1%notfound;
				FETCH cur_1 INTO emgacntwkrec;
				v_cnt := v_cnt + 1;
				IF v_cnt = 1 THEN
					emgacntdetrec.self_flag      := emgacntwkrec.self_flag;
          -- emgAcntDetWkRec.Racnt_No     := emgAcntWkRec.
          -- emgAcntDetWkRec.Order_Type   := emgAcntWkRec
					emgacntdetrec.ins_fee_code   := emgacntwkrec.ins_fee_code;
					emgacntdetrec.emg_per        := emgacntwkrec.emg_per;
					emgacntdetrec.qty            := emgacntwkrec.qty;
					emgacntdetrec.cir_code       := emgacntwkrec.cir_code;
					emgacntdetrec.path_code      := emgacntwkrec.path_code;
					emgacntdetrec.dept_code      := emgacntwkrec.dept_code;
					emgacntdetrec.bed_no         := emgacntwkrec.bed_no;
					emgacntdetrec.start_date     := emgacntwkrec.start_date;
					emgacntdetrec.end_date       := emgacntwkrec.end_date;
					emgacntdetrec.tqty           := emgacntwkrec.tqty;
          --emgAcntDetWkRec.Tamt         := bilA
					emgacntdetrec.insu_amt       := emgacntwkrec.insu_amt;
					emgacntdetrec.start_date     := emgacntwkrec.start_date;
					emgacntdetrec.self_amt       := emgacntwkrec.self_amt;
					emgacntdetrec.start_time     := emgacntwkrec.start_time;
					emgacntdetrec.end_time       := emgacntwkrec.end_time;
				END IF;
				IF emgacntdetrec.ins_fee_code = emgacntwkrec.ins_fee_code AND emgacntdetrec.self_flag = emgacntwkrec.self_flag
          --  AND emgAcntDetRec.Cir_Code     = emgAcntDetWkRec.Cir_Code
				 AND emgacntdetrec.emg_per = emgacntwkrec.emg_per AND emgacntdetrec.self_amt = emgacntwkrec.self_amt AND emgacntdetrec.insu_amt =
				emgacntwkrec.insu_amt THEN
					v_flag                   := 'Y';
					emgacntdetrec.end_date   := emgacntwkrec.end_date;
					emgacntdetrec.end_time   := emgacntwkrec.end_time;
					v_tqty                   := v_tqty + emgacntwkrec.tqty;
          --v_self_amt := v_self_amt + (emgAcntWkRec.Self_Amt * emgAcntWkRec.Emg_Per *
				ELSE
					v_seqno                      := v_seqno + 1;
					emgacntdetrec.seq_no         := v_seqno;
					emgacntdetrec.racnt_no       := v_fee_kind;
					emgacntdetrec.order_type     := '2';
					emgacntdetrec.tqty           := v_tqty;
					IF emgacntdetrec.self_flag = 'Y' THEN
						emgacntdetrec.tamt := v_tqty * emgacntwkrec.self_amt;
					ELSE
						emgacntdetrec.tamt := v_tqty * emgacntwkrec.insu_amt;
					END IF;
					IF emgacntwkrec.self_flag = 'Y' THEN
						IF emgacntwkrec.price_code LIKE '006%' THEN
							BEGIN
								SELECT
									udndrgoc.udnmftdgnm
								INTO
									emgacntdetrec
								.full_name
                --FROM vghtcoe.udndrgoc
								FROM
									cpoe.udndrgoc
								WHERE
									(udnenddate >= emgacntwkrec.start_date
									 OR
									 udnenddate IS NULL)
									AND
									udnbgndate <= emgacntwkrec.start_date
									AND
									udndrgcode = substr (emgacntwkrec.price_code, 4, 5);
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
									emgacntdetrec
								.full_name
								FROM
									cpoe.dbpfile
								WHERE
									dbpfile.pfkey = emgacntwkrec.price_code;
							EXCEPTION
								WHEN OTHERS THEN
									emgacntdetrec.full_name := '';
							END;
						END IF;
					ELSE
						IF emgacntwkrec.price_code LIKE '006%' THEN
							BEGIN
								SELECT
									udndrgoc.udnmftdgnm
								INTO
									emgacntdetrec
								.full_name
                --FROM vghtcoe.udndrgoc
								FROM
									cpoe.udndrgoc
								WHERE
									(udnenddate >= emgacntwkrec.start_date
									 OR
									 udnenddate IS NULL)
									AND
									udnbgndate <= emgacntwkrec.start_date
									AND
									udndrgcode = substr (emgacntwkrec.price_code, 4, 5);
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
									emgacntdetrec
								.full_name
                --FROM cpoe.VSNHI
								FROM
									vsnhi
								WHERE
									vsnhi.labkey = emgacntwkrec.ins_fee_code
									AND
									(labedate >= emgacntwkrec.start_date
									 OR
									 labedate IS NULL)
									AND
									labbdate <= emgacntwkrec.start_date;
							EXCEPTION
								WHEN OTHERS THEN
									emgacntdetrec.full_name := '';
							END;
						END IF;
					END IF;
					INSERT INTO emg_bil_acntdet VALUES emgacntdetrec;
					v_tqty                       := 0;
					emgacntdetrec.self_flag      := emgacntwkrec.self_flag;
					emgacntdetrec.ins_fee_code   := emgacntwkrec.ins_fee_code;
					emgacntdetrec.emg_per        := emgacntwkrec.emg_per;
					emgacntdetrec.qty            := emgacntwkrec.qty;
					emgacntdetrec.cir_code       := emgacntwkrec.cir_code;
					emgacntdetrec.path_code      := emgacntwkrec.path_code;
					emgacntdetrec.dept_code      := emgacntwkrec.dept_code;
					emgacntdetrec.bed_no         := emgacntwkrec.bed_no;
          -- emgAcntDetRec.Start_Date   := emgAcntWkRec.Start_Date;
          --emgAcntDetRec.End_Date     := emgAcntWkRec.End_Date;
					emgacntdetrec.tqty           := v_tqty;
					emgacntdetrec.insu_amt       := emgacntwkrec.insu_amt;
					emgacntdetrec.self_amt       := emgacntwkrec.self_amt;
					emgacntdetrec.start_time     := emgacntwkrec.start_time;
					emgacntdetrec.end_time       := emgacntwkrec.end_time;
				END IF;

        --IF v_flag = 'Y' THEN

        --END IF ;
			END LOOP;
			CLOSE cur_1;
			v_seqno                    := v_seqno + 1;
			emgacntdetrec.seq_no       := v_seqno;
			emgacntdetrec.racnt_no     := v_fee_kind;
			emgacntdetrec.order_type   := '2';
			emgacntdetrec.tqty         := v_tqty;
			IF emgacntdetrec.self_flag = 'Y' THEN
				emgacntdetrec.tamt := v_tqty * emgacntwkrec.self_amt;
			ELSE
				emgacntdetrec.tamt := v_tqty * emgacntwkrec.insu_amt;
			END IF;
			INSERT INTO emg_bil_acntdet VALUES emgacntdetrec;

      -- END IF ;

      --  ELSE

      /*TRIM(ntwks_ipd_seq) = TRIM(saves_ipd_seq) AND (ntwks_self_flag) = TRIM(saves_self_flag) AND (ntwks_fee_type) = TRIM(saves_fee_type) AND (ntwks_fee_kind) = TRIM(saves_fee_kind) AND (ntwks_ins_fee_code) = TRIM(saves_ins_fee_code) AND  = saved_insu_amt AND  = saved_part_amt AND  = saved_self_amt AND (ntwks_bed_no) = TRIM(saves_bed_no) AND  = saved_emg_per AND (ntwks_emg_flag) = TRIM(saves_emg_flag) AND (ntwks_cir_code) = TRIM(saves_cir_code) )*/
      --   END IF ;
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
	END; --AcntWkCalculate

  --計算乘數
	PROCEDURE getemgper (
		pcaseno          VARCHAR2, --住院序
		ppfkey           VARCHAR2, --計價碼
		pfeekind         VARCHAR2, --帳檔計價類別
		pemgflag         VARCHAR2, --急作否
		pfncl            VARCHAR2, --身分別
		ptype            VARCHAR2, --'1'算全部成數 '2',只算急作成數
		pdate            DATE,
		emg_per          OUT   NUMBER, --加乘數
		holiday_per      OUT   NUMBER, --假日加成乘數
		night_per        OUT   NUMBER, --夜間加成乘數
		child_per        OUT   NUMBER, --兒童加成乘數
		urgent_per       OUT   NUMBER, --急作加成乘數
		operation_per    OUT   NUMBER, --手術加成乘數
		anesthesia_per   OUT   NUMBER, --麻醉加成乘數
		materials_per    OUT   NUMBER --材料加成乘數
	) --計價日
	 IS
    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_date           DATE;
		v_cnt            INTEGER;
		pemgper          NUMBER (10, 3);

    --自費金額
		v_pf_self_pay    NUMBER (10, 2);
    --申報金額
		v_pf_nh_pay      NUMBER (10, 2);
    --兒童加乘
		v_pf_child_pay   NUMBER (10, 2);
    --住院可急作否
		v_feemep_flag    VARCHAR2 (01);
    --手術否
		v_pfopfg_flag    VARCHAR2 (01);
    --特殊檢驗否
		v_pfspexam       VARCHAR2 (01);
		v_child_flag_1   VARCHAR2 (01) := 'N';
		v_child_flag_2   VARCHAR2 (01) := 'N';
		v_child_flag_3   VARCHAR2 (01) := 'N';
		patemgcaserec    common.pat_emg_casen%rowtype;
		ls_date          VARCHAR2 (10);
		v_nh_type        VARCHAR2 (02);
		vnh_lbchild      VARCHAR2 (01);--提升兒童加成 by kuo 201600824
		vnh_child        VARCHAR2 (01);--兒童加成 by kuo 201600824
		vlabkey          VARCHAR2 (12);--復健健保碼兒童加成用 by kuo 20191120
		v_holiday        VARCHAR2 (01);
		v_hweek          CHAR (1);

    --出生年齡(健保規定年齡部份計算為年-年)
    --月份才是年月日
		v_yy             NUMBER (5, 2);
		v_birthday       DATE;
		or_emper         NUMBER; -- add by kuo 20140822
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
			vsnhi.labbdate <= pdate
			AND
			vsnhi.labedate >= pdate;
		CURSOR cur_1 (
			ppfkey VARCHAR2
		) IS
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfeemep,
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
			pfbegindate <= pdate
			AND
			pfenddate >= pdate
		UNION
		SELECT
			to_number (pfselpay) / 100,
			to_number (pfreqpay) / 100,
			to_number (pfchild),
			pfeemep,
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
			pfbegindate <= pdate
			AND
			pfenddate >= pdate;
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
			impl_date <= pdate
			AND
			end_date >= pdate;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'emg_calculate_PKG.getEmgPer';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		pemgper          := 1;
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;

    --急診診察費加成,職傷亦按檢傷分類轉碼不算
		v_holiday        := 'N';
		IF ppfkey IN (
			'DIAGER',
			'DIAG0201',
			'DIAG0202',
			'DIAG0203',
			'DIAG0204',
			'DIAG1021',
			'DIAG1047',
			'DIAG1048',
			'DIAG1049',
			'DIAG1050',
			'DIAG0225'
		) THEN
			BEGIN
				SELECT
					udholdt,
					udhweek
				INTO
					v_holiday,
					v_hweek
				FROM
					cpoe.udhltbl
				WHERE
					udhdate = trunc (patemgcaserec.emgdt);
			EXCEPTION
				WHEN OTHERS THEN
					v_holiday := 'N';
			END;

      --自990101開始,夜間加成為50%
			IF TO_CHAR (patemgcaserec.emgdt, 'HH24MI') >= '2200' OR TO_CHAR (patemgcaserec.emgdt, 'HH24MI') <= '0600'
      --OR v_Holiday='Y' 
			 THEN
        --99/09/01起,   精神科夜間及例假日均加成 20%
        --1001213 改回 50% BY KUO 
        --IF patemgcaseRec.Emgdept = 'PSY' THEN
        --  pEmgPer   := pEmgPer + 0.2;
        --  NIGHT_PER := 0.2;
        --ELSE
          --add OS 為牙科 by kuo 20151210
          --mark by kuo 20160411 request by 羅潁瓊,牙科夜間比照西醫
          --IF (PATEMGCASEREC.EMGDEPT = 'DENT' OR PATEMGCASEREC.EMGSECT='OS') AND PFEEKIND='03' THEN --牙科診察費無夜間加成
          --   NULL;
          --ELSE
				pemgper     := pemgper + 0.5;
				night_per   := 0.5;
          --END IF;
          --pEmgPer   := pEmgPer + 0.5;
          --NIGHT_PER := 0.5;
        --END IF;
			ELSE
				IF v_holiday = 'Y' OR (v_hweek = '6' AND TO_CHAR (patemgcaserec.emgdt, 'HH24MI') >= '1200') OR (v_hweek = '6' AND TO_CHAR (patemgcaserec
				.emgdt, 'YYYYMMDD') >= '20171001') THEN --新增20171001起星期六凌晨算假日加成 by kuo 20170929
					pemgper       := pemgper + 0.2;
					holiday_per   := 0.2;
				END IF;
			END IF;
      --RETURN pEmgPer;
		END IF;

    -- 74700371  加成 37% 自 990602 起
    --從此取消 by kuo 20130422
    --IF pFncl = '7' AND pPFkey IN ('74700371', '74770844') THEN
    --  pEmgPer       := pEmgPer + 0.37;
    --  MATERIALS_PER := 0.37;
    --END IF;

    --手材
    --修改生日取不到，給一個預設值 by kuo 20141203
		BEGIN
			SELECT
				TO_DATE (hbirthdt, 'YYYYMMDD')
			INTO v_birthday
			FROM
				common.pat_basic
			WHERE
				hhisnum = patemgcaserec.emghhist;
		EXCEPTION
			WHEN OTHERS THEN
				v_birthday := TO_DATE ('19880101', 'yyyymmdd');
		END;
    --v_yy := TO_NUMBER(to_char(patemgcaseRec.emgdt,'yyyy')) - TO_NUMBER(to_char(v_birthday,'yyyy')) ;
		v_yy             := to_number ((patemgcaserec.emgdt - v_birthday) / 365);
		OPEN cur_vsnhi (ppfkey);
		FETCH cur_vsnhi INTO
			v_nh_type,
			vnh_child,
			vnh_lbchild,
			vlabkey;
		CLOSE cur_vsnhi;
		OPEN cur_1 (ppfkey);
		FETCH cur_1 INTO
			v_pf_self_pay,
			v_pf_nh_pay,
			v_pf_child_pay,
			v_feemep_flag,
			v_pfopfg_flag,
			v_pfspexam;
		IF cur_1%found THEN

      --取出病患年齡
      --健保年齡還算以月為主
      --兒童加成改為依計價日期看加成而非住院日期 BY KUO 1010224,以10102離院日開始
			IF TO_CHAR (patemgcaserec.emglvdt, 'YYYYMM') = '201202' THEN
				ls_date := biling_common_pkg.f_datebetween (TO_DATE ((TO_CHAR (v_birthday, 'YYYYMM') || '01'), 'YYYYMMDD'), TO_DATE ((TO_CHAR
				(pdate, 'YYYYMM') || '01'), 'YYYYMMDD'));
         --ls_date := biling_common_pkg.f_datebetween(b_date => v_birthday,
         --                                           E_DATE => PATEMGCASEREC.EMGDT);
         --DBMS_OUTPUT.PUT_LINE('to_number(ls_date):'||TO_NUMBER(LS_DATE));
			ELSE
				ls_date := biling_common_pkg.f_datebetween (TO_DATE ((TO_CHAR (v_birthday, 'YYYYMM') || '01'), 'YYYYMMDD'), TO_DATE ((TO_CHAR
				(patemgcaserec.emgdt, 'YYYYMM') || '01'), 'YYYYMMDD'));
        --add by kuo 20160824, 201609以後生效的算法,依月算
				IF TO_CHAR (patemgcaserec.emgdt, 'YYYYMM') >= '201609' THEN
					v_yy      := to_number (TO_CHAR (pdate, 'yyyy')) - to_number (TO_CHAR (v_birthday, 'yyyy'));
					ls_date   := round (months_between (TO_DATE (TO_CHAR (pdate, 'YYYYMM') || '01', 'YYYYMMDD'), TO_DATE (TO_CHAR (v_birthday, 'YYYYMM'
					) || '01', 'YYYYMMDD')), 0);
				END IF;
         --ls_date := biling_common_pkg.f_datebetween(b_date => v_birthday,
         --                                           E_DATE => PATEMGCASEREC.EMGDT);
         --DBMS_OUTPUT.PUT_LINE('to_number(ls_date):'||TO_NUMBER(LS_DATE));
			END IF;
      --old one marked by kuo 1010229
      --LS_DATE := BILING_COMMON_PKG.F_DATEBETWEEN(B_DATE => TO_DATE((TO_CHAR(V_BIRTHDAY,'YYYYMM')||'01'),'YYYYMMDD'),
      --                                           E_DATE => TO_DATE((TO_CHAR(PATEMGCASEREC.EMGDT,'YYYYMM')||'01'),'YYYYMMDD'));
      --ls_date := biling_common_pkg.f_datebetween(b_date => v_birthday,
      --                                           e_date => patemgcaseRec.emgdt);

      --判斷是否符合兒童加乘( 6歲以下 , 二歲以下 ,六個月以下)
      --年齡大於6歲,就沒有兒童加乘
      --民眾身分不計算兒童加成
      --1.< 6m 者 ，+60%
      --2.大於等於6m，小於等於23m 者，+30%
      --3.大於等於24m，小於等於83m者，+20%
			IF pfncl = '7' AND v_birthday IS NOT NULL THEN
				v_child_flag_1   := 'N';
				v_child_flag_2   := 'N';
				v_child_flag_3   := 'N';
				IF v_yy > 6 THEN
					v_child_flag_1   := 'N';
					v_child_flag_2   := 'N';
					v_child_flag_3   := 'N';
				ELSE
          --小於六歲大於二歲者
          --IF v_yy <= 6 AND v_yy > 2 THEN
					IF TO_CHAR (patemgcaserec.emgdt, 'YYYYMM') < '201609' THEN
						IF v_yy <= 6 AND to_number (ls_date) >= 20000 THEN
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
        --add by kuo 20160824, 201609以後生效的算法,依月算
				IF TO_CHAR (patemgcaserec.emgdt, 'YYYYMM') >= '201609' THEN
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
			ELSE
        --民眾身分無兒童加成
        --民眾身分無兒童加成取消 by kuo 從20121115開始
				IF v_yy > 6 THEN
					v_child_flag_1   := 'N';
					v_child_flag_2   := 'N';
					v_child_flag_3   := 'N';
				ELSE
          --小於六歲大於二歲者
          --IF v_yy <= 6 AND v_yy > 2 THEN
					IF v_yy <= 6 AND to_number (ls_date) >= 20000 THEN
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
        --民眾身分無兒童加成 20121115之前,改成20121113之前
				IF pdate < TO_DATE ('20121113', 'YYYYMMDD') THEN
					v_child_flag_1   := 'N';
					v_child_flag_2   := 'N';
					v_child_flag_3   := 'N';
				END IF;
			END IF;

      --住院可報急作,且有急作註記者
			IF v_feemep_flag = 'Y' AND pemgflag = 'E' THEN
        --手術,接生加成
				IF pfeekind IN (
					'07',
					'08'
				) OR v_nh_type = '07' THEN
					pemgper      := pemgper + 0.3;
					urgent_per   := 0.3;
				ELSE
          -- 健保身分 急做加成 0.2
					IF pfncl = '7' THEN
            --手術急作加成率是30%.
						IF v_pfopfg_flag = 'Y' THEN
							pemgper      := pemgper + 0.3;
							urgent_per   := 0.3;
						ELSE
							pemgper      := pemgper + 0.2;
							urgent_per   := 0.2;
						END IF;
					ELSE
            -- 民眾身分 急作加成 0.3
						pemgper      := pemgper + 0.3;
						urgent_per   := 0.3;
					END IF;
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
        --內含材料，不加成 80011890 add by kuo 1000525
        --add new 80005349 by kuo 1010726
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
						pemgper         := pemgper + 0.53;
						operation_per   := 0.53;
					END IF;
				END IF;
        --特殊加成 by kuo 20140822
				OPEN get_or_emper (ppfkey);
				FETCH get_or_emper INTO or_emper;
				IF get_or_emper%found THEN
					pemgper         := pemgper + or_emper;
					operation_per   := operation_per + or_emper;
				END IF;
				CLOSE get_or_emper;
			END IF;
			IF ptype = '2' THEN
				emg_per := pemgper;
				return;
			END IF;

      --麻醉加成
			IF pfeekind = '09' OR v_nh_type = '11' THEN
				CASE
					WHEN pemgflag = 'C' THEN
						pemgper          := pemgper + 0.2;
						anesthesia_per   := 0.2;
					WHEN pemgflag IN (
						'D',
						'L'
					) THEN
						pemgper          := pemgper + 0.3;
						anesthesia_per   := 0.3;
					WHEN pemgflag IN (
						'A',
						'E',
						'I'
					) THEN
						pemgper          := pemgper + 0.5;
						anesthesia_per   := 0.5;
					WHEN pemgflag = 'J' THEN
						pemgper          := pemgper + 0.6;
						anesthesia_per   := 0.6;
					WHEN pemgflag = 'B' THEN
						pemgper          := pemgper + 0.7;
						anesthesia_per   := 0.7;
					WHEN pemgflag IN (
						'G',
						'K'
					) THEN
						pemgper          := pemgper + 0.8;
						anesthesia_per   := 0.8;
					WHEN pemgflag = 'H' THEN
						pemgper          := pemgper + 1;
						anesthesia_per   := 1;
					ELSE
						pemgper := pemgper;
				END CASE;
			END IF;

      --加重兒童加成與加成
			IF TO_CHAR (patemgcaserec.emgdt, 'YYYYMM') >= '201609' THEN
        --dbpfile 未設定兒童加乘金額者,無兒童加乘,多判斷VSNHI裡面要有兒童加成才行 by kuo 20160824
				IF v_pf_child_pay > 0 AND v_pf_child_pay IS NOT NULL AND vnh_child = 'Y' THEN
          --兒童加成(6歲以下)
					IF v_child_flag_1 = 'Y' THEN
						pemgper     := pemgper + 0.2;
						child_per   := 0.2;
					END IF;
          --兒童加成(2歲以下)
					IF v_child_flag_2 = 'Y' THEN
						pemgper     := pemgper + 0.3;
						child_per   := 0.3;
					END IF;
          --兒童加成(六個月以下)
					IF v_child_flag_3 = 'Y' THEN
            --復健健保碼範圍:41000-44599 兒童加成 X≦ 23M(小於等於23M) 30% by kuo 20191120
						IF substr (vlabkey, 1, 5) >= '41000' AND substr (vlabkey, 1, 5) <= '44599' THEN
							pemgper     := pemgper + 0.3;
							child_per   := 0.3;
						ELSE
							pemgper     := pemgper + 0.6;
							child_per   := 0.6;
						END IF;
            --20160401以後六個月以下診察費改為100%(+1) request by 徐宗鈴 by kuo 20160331
						IF patemgcaserec.emgdt >= TO_DATE ('20160401', 'YYYYMMDD') THEN
							IF pfeekind = '03' THEN
								pemgper     := pemgper - 0.6 + 1;
								child_per   := 1;
							END IF;
						END IF;
					END IF;
				ELSE
          --六個月以下,手術加成60
					IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') THEN
						pemgper     := pemgper + 0.6;
						child_per   := 0.6;
					END IF;
				END IF;  
        --兒童加重加成
				IF vnh_lbchild = 'Y' THEN
           --兒童加成(6歲以下)
					IF v_child_flag_1 = 'Y' THEN
						pemgper     := pemgper + 0.6;
						child_per   := child_per + 0.6;
					END IF;
          --兒童加成(2歲以下)
					IF v_child_flag_2 = 'Y' THEN
						pemgper     := pemgper + 0.8;
						child_per   := child_per + 0.8;
					END IF;
          --兒童加成(六個月以下)
					IF v_child_flag_3 = 'Y' THEN
						pemgper     := pemgper + 1;
						child_per   := child_per + 1;
					END IF;
				END IF;
			ELSE 
        --dbpfile 未設定兒童加乘金額者,無兒童加乘
				IF v_pf_child_pay > 0 AND v_pf_child_pay IS NOT NULL THEN
          --兒童加成(6歲以下)
					IF v_child_flag_1 = 'Y' THEN
						pemgper     := pemgper + 0.2;
						child_per   := 0.2;
					END IF;
          --兒童加成(2歲以下)
					IF v_child_flag_2 = 'Y' THEN
						pemgper     := pemgper + 0.3;
						child_per   := 0.3;
					END IF;
          --兒童加成(六個月以下)
					IF v_child_flag_3 = 'Y' THEN
						pemgper     := pemgper + 0.6;
						child_per   := 0.6;
            --20160401以後六個月以下診察費改為100%(+1) request by 徐宗鈴 by kuo 20160331
						IF patemgcaserec.emgdt >= TO_DATE ('20160401', 'YYYYMMDD') THEN
							IF pfeekind = '03' THEN
								pemgper     := pemgper - 0.6 + 1;
								child_per   := 1;
							END IF;
						END IF;
					END IF;
				ELSE
          --六個月以下,手術加成60
					IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') THEN
						pemgper     := pemgper + 0.6;
						child_per   := 0.6;
					END IF;
				END IF;
			END IF;

      --手材併入手術主項不另列
			IF pfeekind = '11' THEN
				pemgper          := 0;
				anesthesia_per   := 0;
			END IF;
      --以下成數為固定成數
      --麻材
			IF pfeekind IN (
				'12'
			) THEN
        --add 55101401, 55101400 不算麻材 by kuo 20180221
				IF ppfkey IN (
					'55101401',
					'55101400'
				) THEN
					pemgper          := 0;
					anesthesia_per   := 0;
				ELSE
					pemgper          := 0.5;
					anesthesia_per   := 0.5;
				END IF;
			END IF;

      --手材
			IF pfeekind IN (
				'13'
			) THEN
				pemgper         := 0.53;
				materials_per   := 0.53;
			END IF;

      --END IF ; --type 2 end
		ELSE
      --CUR_1 NOT FOUND
			pemgper := 1;
		END IF; --CUR_1%FOUND
		CLOSE cur_1;

    --dbms_output.put_line('pEmgPer ' || pEmgPer);
		emg_per          := pemgper;
    --RETURN pEmgPer;
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
	END; --getEmgPer

  --調整應收帳款
	PROCEDURE p_receivablecomp (
		pcaseno VARCHAR2
	) IS

    --取出應收帳款調整主檔
		CURSOR cur_mst IS
		SELECT
			*
		FROM
			emg_bil_adjst_mst
		WHERE
			emg_bil_adjst_mst.caseno = pcaseno
		ORDER BY
			emg_bil_adjst_mst.last_update_date;
		CURSOR cur_mst1 IS
		SELECT
			*
		FROM
			emg_bil_adjst_mst
		WHERE
			emg_bil_adjst_mst.donee_caseno = pcaseno
		ORDER BY
			emg_bil_adjst_mst.last_update_date;

    --取出有被調整到的類別
		CURSOR cur_dtl (
			padjstseqno VARCHAR2
		) IS
		SELECT
			*
		FROM
			emg_bil_adjst_dtl
		WHERE
			emg_bil_adjst_dtl.adjst_seqno = padjstseqno
			AND
			emg_bil_adjst_dtl.fee_kind BETWEEN '01' AND '43'
			AND
			emg_bil_adjst_dtl.after_to_amt <> 0;

    --取出原有應收帳款金額
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			emg_bil_feemst
		WHERE
			emg_bil_feemst.caseno = pcaseno;

    --取出原有應收帳款金額
		CURSOR cur_2 (
			pfincode VARCHAR2
		) IS
		SELECT
			*
		FROM
			emg_bil_feedtl
		WHERE
			emg_bil_feedtl.caseno = pcaseno
			AND
			emg_bil_feedtl.pfincode = pfincode;
		emgadjstmstrec      emg_bil_adjst_mst%rowtype;
		emgadjstdtlrec      emg_bil_adjst_dtl%rowtype;
		emgfeedtlrec        emg_bil_feedtl%rowtype;
		emgfeemstrec        emg_bil_feemst%rowtype;
		emgfeemstrecdonee   emg_bil_feemst%rowtype;
		emgfeedtlrecdonee   emg_bil_feedtl%rowtype;
		cnt                 NUMBER; --add by kuo 20150624
		blcnt               NUMBER; --add by kuo 20150812

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
		v_program_name   := 'emg_calculate_PKG.p_receivableComp';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		SELECT
			*
		INTO emgfeemstrec
		FROM
			emg_bil_feemst
		WHERE
			emg_bil_feemst.caseno = pcaseno;

    --取出該病患應收帳款調整檔資料
		OPEN cur_mst;
		LOOP
			FETCH cur_mst INTO emgadjstmstrec;
			EXIT WHEN cur_mst%notfound;
			OPEN cur_dtl (emgadjstmstrec.adjst_seqno);
			LOOP
				FETCH cur_dtl INTO emgadjstdtlrec;
				EXIT WHEN cur_dtl%notfound;
				emgadjstmstrec.blfrunit := rtrim (ltrim (emgadjstmstrec.blfrunit));
        --取出原有類別資料
				BEGIN
					SELECT
						*
					INTO emgfeedtlrec
					FROM
						emg_bil_feedtl
					WHERE
						emg_bil_feedtl.caseno = pcaseno
						AND
						emg_bil_feedtl.fee_type = TRIM (emgadjstdtlrec.fee_kind)
						AND
						emg_bil_feedtl.pfincode = emgadjstmstrec.blfrunit;
					UPDATE emg_bil_feedtl
					SET
						emg_bil_feedtl.total_amt = emg_bil_feedtl.total_amt - emgadjstdtlrec.after_to_amt
					WHERE
						emg_bil_feedtl.caseno = pcaseno
						AND
						emg_bil_feedtl.fee_type = emgadjstdtlrec.fee_kind
						AND
						emg_bil_feedtl.pfincode = emgadjstmstrec.blfrunit;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
				IF emgadjstmstrec.blfrunit = 'CIVC' THEN
					IF emgadjstdtlrec.fee_kind BETWEEN '41' AND '43' THEN
						emgfeemstrec.tot_self_amt := emgfeemstrec.tot_self_amt - emgadjstdtlrec.after_to_amt;
						UPDATE emg_bil_feemst
						SET
							emg_bil_feemst.tot_self_amt = emgfeemstrec.tot_self_amt
						WHERE
							emg_bil_feemst.caseno = pcaseno;
					ELSE
						emgfeemstrec.tot_gl_amt := emgfeemstrec.tot_gl_amt - emgadjstdtlrec.after_to_amt;
						UPDATE emg_bil_feemst
						SET
							emg_bil_feemst.tot_gl_amt = nvl (emgfeemstrec.tot_gl_amt, 0)
						WHERE
							emg_bil_feemst.caseno = pcaseno;
					END IF;
				ELSE
					emgfeemstrec.credit_amt := nvl (emgfeemstrec.credit_amt, 0) - emgadjstdtlrec.after_to_amt;
					UPDATE emg_bil_feemst
					SET
						emg_bil_feemst.credit_amt = emgfeemstrec.credit_amt
					WHERE
						emg_bil_feemst.caseno = pcaseno;
				END IF;

        --取出新身份別的資料,修改金額
				BEGIN
					SELECT
						*
					INTO emgfeedtlrec
					FROM
						emg_bil_feedtl
					WHERE
						emg_bil_feedtl.caseno = pcaseno
						AND
						emg_bil_feedtl.fee_type = emgadjstdtlrec.fee_kind
						AND
						emg_bil_feedtl.pfincode = emgadjstmstrec.bltounit;
					emgfeedtlrec.total_amt := emgfeedtlrec.total_amt + emgadjstdtlrec.after_to_amt;
					UPDATE emg_bil_feedtl
					SET
						emg_bil_feedtl.total_amt = emgfeedtlrec.total_amt
					WHERE
						emg_bil_feedtl.caseno = pcaseno
						AND
						emg_bil_feedtl.fee_type = emgadjstdtlrec.fee_kind
						AND
						emg_bil_feedtl.pfincode = emgadjstmstrec.bltounit;
				EXCEPTION
          --無資料則新增一筆
					WHEN no_data_found THEN
						emgfeedtlrec.caseno      := pcaseno;
						emgfeedtlrec.fee_type    := emgadjstdtlrec.fee_kind;
						emgfeedtlrec.pfincode    := emgadjstmstrec.bltounit;
						emgfeedtlrec.total_amt   := emgadjstdtlrec.after_to_amt;
						INSERT INTO emg_bil_feedtl VALUES emgfeedtlrec;
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
				IF emgadjstmstrec.bltounit = 'CIVC' THEN
					emgfeemstrec.tot_gl_amt := emgfeemstrec.tot_gl_amt + emgadjstdtlrec.after_to_amt;
					UPDATE emg_bil_feemst
					SET
						emg_bil_feemst.tot_gl_amt = emgfeemstrec.tot_gl_amt
					WHERE
						emg_bil_feemst.caseno = pcaseno;
				ELSE
					emgfeemstrec.credit_amt := emgfeemstrec.credit_amt + emgadjstdtlrec.after_to_amt;
					UPDATE emg_bil_feemst
					SET
						emg_bil_feemst.credit_amt = emgfeemstrec.credit_amt
					WHERE
						emg_bil_feemst.caseno = pcaseno;
				END IF;
			END LOOP;
			CLOSE cur_dtl;
		END LOOP;
		CLOSE cur_mst;

    --取出該病患應收帳款調整檔資料
		OPEN cur_mst1;
		LOOP
			FETCH cur_mst1 INTO emgadjstmstrec;
			EXIT WHEN cur_mst1%notfound;
			IF emgadjstmstrec.bltounit = 'TRAN' THEN
				SELECT
					*
				INTO emgfeemstrecdonee
				FROM
					emg_bil_feemst
				WHERE
					emg_bil_feemst.caseno = emgadjstmstrec.donee_caseno;
			END IF;
			OPEN cur_dtl (emgadjstmstrec.adjst_seqno);
			LOOP
				FETCH cur_dtl INTO emgadjstdtlrec;
				EXIT WHEN cur_dtl%notfound;

        --如調整之分攤單位別為器官移植
				IF emgadjstmstrec.bltounit = 'TRAN' THEN
					IF emgadjstmstrec.blfrunit = 'CIVC' THEN
						emgfeemstrecdonee.tot_gl_amt := emgfeemstrecdonee.tot_gl_amt + emgadjstdtlrec.after_to_amt;
					ELSE
						emgfeemstrecdonee.credit_amt := nvl (emgfeemstrecdonee.credit_amt, 0) + emgadjstdtlrec.after_to_amt;
					END IF;
					BEGIN
						SELECT
							*
						INTO emgfeedtlrecdonee
						FROM
							emg_bil_feedtl
						WHERE
							emg_bil_feedtl.caseno = emgadjstmstrec.donee_caseno
							AND
							emg_bil_feedtl.pfincode = emgadjstmstrec.blfrunit
							AND
							emg_bil_feedtl.fee_type = '44';
						UPDATE emg_bil_feedtl
						SET
							total_amt = total_amt + emgadjstdtlrec.after_to_amt
						WHERE
							emg_bil_feedtl.caseno = emgadjstmstrec.donee_caseno
							AND
							emg_bil_feedtl.pfincode = emgadjstmstrec.blfrunit
							AND
							emg_bil_feedtl.fee_type = '44';
					EXCEPTION
						WHEN no_data_found THEN
							emgfeedtlrecdonee.caseno             := emgadjstmstrec.donee_caseno;
							emgfeedtlrecdonee.fee_type           := '44';
							emgfeedtlrecdonee.pfincode           := emgadjstmstrec.blfrunit;
							emgfeedtlrecdonee.total_amt          := emgadjstdtlrec.after_to_amt;
							emgfeedtlrecdonee.created_by         := emgadjstmstrec.last_updated_by;
							emgfeedtlrecdonee.created_date       := emgadjstmstrec.last_update_date;
							emgfeedtlrecdonee.last_updated_by    := emgadjstmstrec.last_updated_by;
							emgfeedtlrecdonee.last_update_date   := SYSDATE;
							INSERT INTO emg_bil_feedtl VALUES emgfeedtlrecdonee;
					END;
				END IF;
			END LOOP;
			CLOSE cur_dtl;
			UPDATE emg_bil_feemst
			SET
				emg_bil_feemst.tot_gl_amt = emgfeemstrecdonee.tot_gl_amt,
				emg_bil_feemst.credit_amt = emgfeemstrecdonee.credit_amt
			WHERE
				emg_bil_feemst.caseno = emgadjstmstrec.donee_caseno;
		END LOOP;
		CLOSE cur_mst1;

    --榮民高就診超過90次(>90)掛號費自付 by kuo 20150624, 20150701生效
    --改抓ic卡卡格 EMGICARD by kuo 20150812
    --20151231 ended by kuo 20160307
    --要改成20160701-20161231
    --改成20170701-20171231 request by 甘家宓與蘇河吉 by kuo 20170420
		BEGIN
			SELECT
				to_number (emgicard)
			INTO blcnt
			FROM
				common.pat_emg_casen
			WHERE
				ecaseno = pcaseno;
      --AND EMGDT >=TO_DATE('20160701','YYYYMMDD') AND EMGDT <= TO_DATE('20161231','YYYYMMDD');
      --AND EMGDT >=TO_DATE('20170701','YYYYMMDD') AND EMGDT <= TO_DATE('20171231','YYYYMMDD');
		EXCEPTION
			WHEN OTHERS THEN
				blcnt := 0;
		END;
		IF blcnt > 90 THEN
			SELECT
				COUNT (*)
			INTO cnt
			FROM
				common.pat_emg_casen     a,
				common.pat_certificate   b,
				common.pat_basic         c
			WHERE
				a.ecaseno = pcaseno
				AND
				a.emghhist = c.hhisnum
				AND
				c.hidno = b.hhisnum
				AND
				TO_CHAR (a.emgdt, 'YYYYMMDD') >= b.begin_date
				AND
				TO_CHAR (a.emgdt, 'YYYYMMDD') <= b.end_date --AND TO_NUMBER(A.ENCAGGREGATE) > 90 mark by kuo 20150812
				AND
				b.certify_type = '03'
				AND
				b.cancel_yn = 'N';
         --AND A.EMGDT >= TO_DATE('20170701','YYYYMMDD')
         --AND A.EMGDT <= TO_DATE('20171231','YYYYMMDD');
         --AND A.EMGDT >= TO_DATE('20160701','YYYYMMDD')
         --AND A.EMGDT <= TO_DATE('20161231','YYYYMMDD');
			IF cnt > 0 THEN 
         --update EMG_BIL_ACNT_WK;
				UPDATE emg_bil_acnt_wk
				SET
					self_amt = part_amt,
					part_amt = 0,
					pfincode = 'CIVC'
				WHERE
					caseno = pcaseno
					AND
					fee_kind = '37'
					AND
					pfincode = 'VERT';
         --update EMG_bil_feedtl
				UPDATE emg_bil_feedtl
				SET
					pfincode = 'CIVC'
				WHERE
					caseno = pcaseno
					AND
					fee_type = '37';
				COMMIT WORK;
         --update EMG_bil_feemst
				UPDATE emg_bil_feemst
				SET
					tot_self_amt = (
						SELECT
							SUM (total_amt)
						FROM
							emg_bil_feedtl
						WHERE
							caseno = pcaseno
							AND
							pfincode = 'CIVC'
					)
				WHERE
					caseno = pcaseno;
				COMMIT WORK;
			END IF;
		END IF; --BLCNT > 90
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
	END; --p_receivableComp

  --優待身份別處理
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
		patemgcaserec    common.pat_emg_casen%rowtype;
		e_user_exception EXCEPTION;
		v_hvtfincl       VARCHAR2 (01);
		v_hvtrnkcd       VARCHAR2 (02);
		v_hpatnum        VARCHAR2 (10);
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			common.vtandept
		WHERE
			vtidno IN (
				SELECT
					hidno
				FROM
					common.pat_basic
				WHERE
					hhisnum IN (
						SELECT
							emghhist
						FROM
							common.pat_emg_casen
						WHERE
							ecaseno = pcaseno
					)
			);
		vtandeptrec      common.vtandept%rowtype;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'emg_calculate_PKG.p_disfin';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		IF pfinacl = 'VTAN' THEN
			SELECT
				*
			INTO patemgcaserec
			FROM
				common.pat_emg_casen
			WHERE
				ecaseno = pcaseno;
			pdiscfin := '';
      /*
      OPEN CUR_1;
      FETCH CUR_1 INTO vtandeptRec;

      IF CUR_1%NOTFOUND THEN
         pDiscFin := '';
         RETURN;
      END IF ;
      CLOSE CUR_1;
      */

      --無職榮
			IF patemgcaserec.emg2fncl = '1' THEN
        --將官
				IF patemgcaserec.vtrnk IN (
					'01',
					'02'
				) THEN
					pdiscfin := 'VTAM';
				ELSE
					pdiscfin := pfinacl;
				END IF;
				return;
			END IF;
      --有職榮
			IF patemgcaserec.emg2fncl = 'E' THEN
        --將官 (03 少將無優待 BY KUO
				IF patemgcaserec.vtrnk IN (
					'01',
					'02'
				) THEN
					pdiscfin := 'VTAM';
					return;
				END IF;
        --上校
				IF patemgcaserec.vtrnk = '04' THEN
					pdiscfin := 'VT04';
					return;
				END IF;
        --校級
				IF patemgcaserec.vtrnk IN (
					'05',
					'06'
				) THEN
					pdiscfin := 'VT05';
					return;
				END IF;
        --尉級
				IF patemgcaserec.vtrnk IN (
					'07',
					'08',
					'09',
					'10'
				) THEN
					pdiscfin := 'VT07';
					return;
				END IF;
        --士官兵
				IF patemgcaserec.vtrnk IN (
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
					return;
				END IF;

        --00於20160101開始與 11 相同 request by 姬小姐 by kuo 20160323
				IF patemgcaserec.vtrnk IN (
					'00'
				) AND patemgcaserec.emgdt >= TO_DATE ('20160116', 'YYYYMMDD') THEN
					pdiscfin := 'VT11';
					return;
				END IF;
				IF patemgcaserec.vtrnk IS NOT NULL THEN
					pdiscfin := 'VT04'; --以最高計
					return;
				END IF;
				pdiscfin := 'VTAN';
				return;
			ELSE
				pdiscfin := pfinacl;
			END IF;
		ELSIF pfinacl = '6' THEN
			pdiscfin := 'EMPL';
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
	END; --p_disfin

  --健保規則調整
	PROCEDURE p_transnhrule (
		pcaseno VARCHAR2
	) IS

    --抓出有在規則轉換設定中有資料的主項健保碼
		CURSOR cur_1 IS
		SELECT
			bil_nhrule_set.ins_fee_code1
		FROM
			emg_bil_acnt_wk,
			bil_nhrule_set
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.ins_fee_code LIKE bil_nhrule_set.ins_fee_code1 || '%'
			AND
			length (emg_bil_acnt_wk.ins_fee_code) <= 7
			AND
			emg_bil_acnt_wk.self_flag = 'N'
			AND
			emg_bil_acnt_wk.insu_amt > 0
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
		CURSOR cur_3 (
			pinsfeecode VARCHAR2
		) IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.self_flag = 'N'
			AND
			emg_bil_acnt_wk.insu_amt > 0
			AND
			length (emg_bil_acnt_wk.ins_fee_code) <= 7
			AND
			emg_bil_acnt_wk.ins_fee_code LIKE pinsfeecode || '%';

    --抓出每日帳款筆數
		CURSOR cur_4 (
			pinsfeecode VARCHAR2
		) IS
		SELECT
			emg_bil_acnt_wk.start_date
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.ins_fee_code LIKE pinsfeecode || '%'
			AND
			length (emg_bil_acnt_wk.ins_fee_code) <= 7
			AND
			emg_bil_acnt_wk.insu_amt > 0
			AND
			emg_bil_acnt_wk.self_flag = 'N'
		GROUP BY
			emg_bil_acnt_wk.start_date;
		CURSOR cur_5 (
			pinsfeecode   VARCHAR2,
			pdate         DATE
		) IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.ins_fee_code LIKE pinsfeecode || '%'
			AND
			length (emg_bil_acnt_wk.ins_fee_code) <= 7
			AND
			emg_bil_acnt_wk.self_flag = 'N'
			AND
			emg_bil_acnt_wk.insu_amt > 0
			AND
			emg_bil_acnt_wk.start_date = pdate;

    --7.每日33046B2次轉33088B,三次以上轉成33089B
		CURSOR cur_7 IS
		SELECT
			emg_bil_acnt_wk.start_date,
			COUNT (*)
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.ins_fee_code = '33046B'
			AND
			emg_bil_acnt_wk.self_flag = 'N'
			AND
			emg_bil_acnt_wk.insu_amt > 0
      --and bil_acnk_wk.qty = 1
		GROUP BY
			emg_bil_acnt_wk.start_date
		HAVING
			COUNT (*) >= 2;
		CURSOR cur_7_1 (
			pstartdate DATE
		) IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.start_date = pstartdate
			AND
			emg_bil_acnt_wk.self_flag = 'N'
			AND
			emg_bil_acnt_wk.insu_amt > 0
			AND
			emg_bil_acnt_wk.ins_fee_code = '33046B';

    --8.取出所有單價>30000的衛材
		CURSOR cur_8 IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.nh_type = '12'
			AND
			emg_bil_acnt_wk.self_flag = 'N'
			AND
			emg_bil_acnt_wk.insu_amt > 0
			AND
			emg_bil_acnt_wk.insu_amt >= 30000;

    --9.尿常規申報規則(按天計)
		CURSOR cur_9 IS
		SELECT
			emg_bil_acnt_wk.start_date,
			SUM (emg_bil_acnt_wk.qty * emg_bil_acnt_wk.emg_per * emg_bil_acnt_wk.insu_amt)
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.self_flag = 'N'
            --AND emg_bil_acnt_wk.insu_amt > 0
			AND
			emg_bil_acnt_wk.ins_fee_code BETWEEN '06001C' AND '06017B'
		GROUP BY
			emg_bil_acnt_wk.start_date
		HAVING
			SUM (emg_bil_acnt_wk.qty * emg_bil_acnt_wk.emg_per * emg_bil_acnt_wk.insu_amt) >= 75;
		CURSOR cur_9_1 (
			pstartdate DATE
		) IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.start_date = pstartdate
			AND
			emg_bil_acnt_wk.self_flag = 'N'
			AND
			emg_bil_acnt_wk.insu_amt > 0
			AND
			emg_bil_acnt_wk.ins_fee_code BETWEEN '06001C' AND '06017B';

    --10.血液常規併項修正(同日)
		CURSOR cur_10 IS
		SELECT
			start_date
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.insu_amt > 0
			AND
			emg_bil_acnt_wk.ins_fee_code = '08001C'
		GROUP BY
			start_date;
		CURSOR cur_10_1 (
			pstartdate    DATE,
			pinsfeecode   VARCHAR2
		) IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.start_date = pstartdate
			AND
			emg_bil_acnt_wk.insu_amt > 0
			AND
			emg_bil_acnt_wk.ins_fee_code = pinsfeecode;
		CURSOR cur_11 (
			pstartdate DATE
		) IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.start_date = pstartdate
			AND
			emg_bil_acnt_wk.insu_amt > 0
			AND
			emg_bil_acnt_wk.ins_fee_code = '02006K';
		CURSOR cur_14 IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.ins_fee_code IN (
				'32001C',
				'32007C',
				'32009C',
				'32011C',
				'32013C',
				'32015C',
				'32017C',
				'32022C'
			);
		bilnhrulesetrec   bil_nhrule_set%rowtype;
		emgacntwkrec      emg_bil_acnt_wk%rowtype;
		v_ins_fee_code    VARCHAR2 (20);
		v_cnt             INTEGER;
		v_qty             INTEGER;
		v_qty1            INTEGER;
		v_qty2            INTEGER;
		v_start_date      DATE;
		v_amt             NUMBER (10, 2);
		v_first           VARCHAR2 (01) := 'Y';
    --bilRootRec bil_root%ROWTYPE;
		emgfeemstrec      emg_bil_feemst%rowtype;
		vsnhirec          vsnhi%rowtype;
		v_dischg_date     DATE;
		v_qty_1           INTEGER;
		emgoccurrec       cpoe.emg_occur%rowtype;
		emgfeedtlrec      emg_bil_feedtl%rowtype;
		patemgcaserec     common.pat_emg_casen%rowtype;
		v_tb_days         INTEGER;
		v_days            INTEGER;

    --錯誤訊息用途
		v_program_name    VARCHAR2 (80);
		v_session_id      NUMBER (10);
		v_error_code      VARCHAR2 (20);
		v_error_msg       VARCHAR2 (400);
		v_error_info      VARCHAR2 (600);
		v_source_seq      VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'emg_calculate_PKG.p_TransNHRule';
		v_session_id     := userenv ('SESSIONID');
    --v_source_seq := pPfkey;
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;
    --6.過濾手術類別(07)同日之換藥48011C,48012C,48013C,CASEPAYMENT除外不過濾
    /*急診無drg
    */
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
					FETCH cur_7_1 INTO emgacntwkrec;
					EXIT WHEN cur_7_1%notfound;
					IF v_first = 'Y' THEN
						p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '33088B', pdeletereason => '每日33076B 二次轉成33088B'
						);
						v_first := 'N';
					END IF;
          --reset qty values ,就不會再insert 一次了...
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '每日33076B 二次轉成33088B');
				END LOOP;
				CLOSE cur_7_1;
        --33076B > 2 轉成33089B
			ELSE
        --reset qty values ,就不會再insert 一次了...
				v_first := 'Y';
				OPEN cur_7_1 (v_start_date);
				LOOP
					FETCH cur_7_1 INTO emgacntwkrec;
					EXIT WHEN cur_7_1%notfound;
					IF v_first = 'Y' THEN
						p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '33089B', pdeletereason => '每日33076B 超過二次轉成33089B'
						);
						v_first := 'N';
					END IF;
          --reset qty values ,就不會再insert 一次了...
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '每日33076B 超過二次轉成33089B');
				END LOOP;
				CLOSE cur_7_1;
			END IF; --IF v_cnt = 2
		END LOOP;
		CLOSE cur_7;

    --8.衛材金額大於三萬,管理費上限1500
		OPEN cur_8;
		LOOP
			FETCH cur_8 INTO emgacntwkrec;
			EXIT WHEN cur_8%notfound;
			p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => 'MA12345678NH', pdeletereason => '材料管理費上限1500'
			);
		END LOOP;
		CLOSE cur_8;

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
				emg_bil_acnt_wk
			WHERE
				emg_bil_acnt_wk.caseno = pcaseno
				AND
				emg_bil_acnt_wk.start_date = v_start_date
				AND
				emg_bil_acnt_wk.ins_fee_code = '06009C';
			IF v_cnt > 0 THEN
				v_ins_fee_code := '06012C';
			ELSE
				v_ins_fee_code := '06013C';
			END IF;
			v_first := 'Y';
			OPEN cur_9_1 (v_start_date);
			LOOP
				FETCH cur_9_1 INTO emgacntwkrec;
				EXIT WHEN cur_9_1%notfound;
				IF v_first = 'Y' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '06012C', pdeletereason => '尿液常規申報規則轉'
					|| v_ins_fee_code);
					v_first := 'N';
				END IF;
        --reset qty values ,就不會再insert 一次了...
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉' || v_ins_fee_code);
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
			FETCH cur_10_1 INTO emgacntwkrec;
      --找不到就跳出回圈
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;
      --check 是否有08003C
			OPEN cur_10_1 (v_start_date, '08003C');
			FETCH cur_10_1 INTO emgacntwkrec;
      --找不到就跳出回圈
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;
      --check 是否有08004C
			OPEN cur_10_1 (v_start_date, '08004C');
			FETCH cur_10_1 INTO emgacntwkrec;
      --找不到就是 08001C+08002C+08003C都有,轉成08014C
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
        --刪除08001C,08002C,08003C
				OPEN cur_10_1 (v_start_date, '08001C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08002C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08003C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
          --新增08014C
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '08014C', pdeletereason => '尿液常規申報規則轉08014C'
					);
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --check 是否有08127C
			OPEN cur_10_1 (v_start_date, '08127C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
        --刪除08001C,08002C,08003C
				OPEN cur_10_1 (v_start_date, '08001C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08002C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08003C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
          --新增08014C
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '08014C', pdeletereason => '尿液常規申報規則轉08014C'
					);
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08014C');
				END IF;
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --check 是否有08006C
			OPEN cur_10_1 (v_start_date, '08006C');
			FETCH cur_10_1 INTO emgacntwkrec;
      --找不到就是 08001C+08002C+08003C+08004C+08127C都有,轉成08012C
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
        --刪除08001C,08002C,08003C,08004C,08127C
				OPEN cur_10_1 (v_start_date, '08001C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08002C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08003C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08004C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08127C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
          --新增08012C
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '08012C', pdeletereason => '尿液常規申報規則轉08012C'
					);
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08012C');
				END IF;
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --通通都有
      --08001C+08002C+08003C+08004C+08127C+08006C都有,轉成08011C
      --刪除08001C,08002C,08003C,08004C,08127C,08006C
			OPEN cur_10_1 (v_start_date, '08001C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08002C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08003C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08004C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08127C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08006C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
        --新增08011C
				p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '08011C', pdeletereason => '尿液常規申報規則轉08011C'
				);
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '尿液常規申報規則轉08011C');
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
				IF bilnhrulesetrec.rule_kind = '1' THEN
					OPEN cur_3 (v_ins_fee_code);
					LOOP
						FETCH cur_3 INTO emgacntwkrec;
						EXIT WHEN cur_3%notfound;
						IF bilnhrulesetrec.range_type = '1' THEN
							SELECT
								COUNT (*)
							INTO v_cnt
							FROM
								emg_bil_acnt_wk
							WHERE
								emg_bil_acnt_wk.caseno = pcaseno
								AND
								emg_bil_acnt_wk.ins_fee_code LIKE bilnhrulesetrec.ins_fee_code2 || '%'
								AND
								emg_bil_acnt_wk.start_date = emgacntwkrec.start_date;
						ELSE
							SELECT
								COUNT (*)
							INTO v_cnt
							FROM
								emg_bil_acnt_wk
							WHERE
								emg_bil_acnt_wk.caseno = pcaseno
								AND
								emg_bil_acnt_wk.ins_fee_code LIKE bilnhrulesetrec.ins_fee_code2 || '%';
						END IF;
            --存在不得同時申報的B健保碼,故A不得申報
						IF v_cnt > 0 THEN
              --刪除A碼
              --移至轉換明細檔
              --調整金額回 bil_feemst/EMG_bil_feedtl
							p_deleteacntwk (pcaseno, emgacntwkrec.acnt_seq, '不得與' || bilnhrulesetrec.ins_fee_code2 || '不時申報');
						END IF;
					END LOOP;
					CLOSE cur_3;
				END IF; --IF bilnhruleSetREC.Rule_Kind = '1'

        --限次數
				IF bilnhrulesetrec.rule_kind = '2' THEN
					v_qty := 0;
          --限日
					IF bilnhrulesetrec.range_type = '1' THEN
            --
						OPEN cur_4 (v_ins_fee_code);
						LOOP
							FETCH cur_4 INTO v_start_date;
							EXIT WHEN cur_4%notfound;
							v_qty := 0;
              --取出所有符合的資料
							OPEN cur_5 (v_ins_fee_code, v_start_date);
							LOOP
								FETCH cur_5 INTO emgacntwkrec;
								EXIT WHEN cur_5%notfound;
								v_qty := v_qty + emgacntwkrec.qty;
								IF v_qty > bilnhrulesetrec.qty THEN
									p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '超過每日限制次數');
								END IF;
							END LOOP;
							CLOSE cur_5;
						END LOOP;
						CLOSE cur_4;
					ELSE
						v_qty := 0;
            --取出所有符合的資料
						OPEN cur_3 (v_ins_fee_code);
						LOOP
							FETCH cur_3 INTO emgacntwkrec;
							EXIT WHEN cur_3%notfound;
							v_qty := v_qty + emgacntwkrec.qty;
							IF v_qty > bilnhrulesetrec.qty THEN
								p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '超過每次限制次數');
							END IF;
						END LOOP;
						CLOSE cur_3;
					END IF; --IF bilnhruleSetREC.Range_Type = '1'
				END IF; --IF bilnhruleSetREC.Rule_Kind = '2'

        --A碼過後幾次轉成B碼
				IF bilnhrulesetrec.rule_kind = '3' THEN
					v_qty := 0;
          --限日
					IF bilnhrulesetrec.range_type = '1' THEN
            --
						OPEN cur_4 (v_ins_fee_code);
						LOOP
							FETCH cur_4 INTO v_start_date;
							EXIT WHEN cur_4%notfound;
              --算出該健保於某日期中的筆數,超過才要轉換,不然沒事
							SELECT
								SUM (emg_bil_acnt_wk.tqty)
							INTO v_qty1
							FROM
								emg_bil_acnt_wk
							WHERE
								emg_bil_acnt_wk.caseno = pcaseno
								AND
								emg_bil_acnt_wk.ins_fee_code = v_ins_fee_code
								AND
								emg_bil_acnt_wk.start_date = v_start_date
								AND
								emg_bil_acnt_wk.insu_amt > 0;
							SELECT
								SUM (emg_bil_acnt_wk.tqty)
							INTO v_qty2
							FROM
								emg_bil_acnt_wk
							WHERE
								emg_bil_acnt_wk.caseno = pcaseno
								AND
								emg_bil_acnt_wk.ins_fee_code = v_ins_fee_code
								AND
								emg_bil_acnt_wk.start_date = v_start_date
								AND
								emg_bil_acnt_wk.insu_amt < 0;
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
									FETCH cur_5 INTO emgacntwkrec;
									EXIT WHEN cur_5%notfound;
                  --只有第一筆要新增B項健保碼,其他全都要刪除含第一筆,只是第一筆要拿來copyB項健保碼用.
									IF v_qty >= bilnhrulesetrec.qty AND v_first = 'Y' THEN
										p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => bilnhrulesetrec.ins_fee_code2, pdeletereason
										=> '超過每日限制次數,轉換成' || bilnhrulesetrec.ins_fee_code2);
                    --reset qty values ,就不會再insert 一次了...
										v_first := 'N';
									END IF;
									IF v_qty >= bilnhrulesetrec.qty AND emgacntwkrec.tqty <= v_qty THEN
										p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '超過每日限制次數,轉換成' || bilnhrulesetrec
										.ins_fee_code2);
										v_qty := v_qty - emgacntwkrec.tqty;
									END IF;
								END LOOP;
								CLOSE cur_5;
							END IF; --IF v_qty >= bilnhruleSetREC.qty
						END LOOP;
						CLOSE cur_4;
					ELSE
            --IF bilnhruleSetREC.Range_Type = '1'
            --算出該健保於某日期中的筆數,超過才要轉換,不然沒事
						SELECT
							SUM (emg_bil_acnt_wk.tqty)
						INTO v_qty1
						FROM
							emg_bil_acnt_wk
						WHERE
							emg_bil_acnt_wk.caseno = pcaseno
							AND
							emg_bil_acnt_wk.insu_amt > 0
							AND
							emg_bil_acnt_wk.ins_fee_code = v_ins_fee_code;
						SELECT
							SUM (emg_bil_acnt_wk.tqty)
						INTO v_qty2
						FROM
							emg_bil_acnt_wk
						WHERE
							emg_bil_acnt_wk.caseno = pcaseno
							AND
							emg_bil_acnt_wk.insu_amt < 0
							AND
							emg_bil_acnt_wk.ins_fee_code = v_ins_fee_code;
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
								FETCH cur_3 INTO emgacntwkrec;
								EXIT WHEN cur_3%notfound;
                --只有第一筆要新增B項健保碼,其他全都要刪除含第一筆,只是第一筆要拿來copyB項健保碼用.
								IF v_qty > bilnhrulesetrec.qty THEN
									p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => bilnhrulesetrec.ins_fee_code2, pdeletereason
									=> '超過每次住院限制次數,轉換成' || bilnhrulesetrec.ins_fee_code2);
                  --reset qty values ,就不會再insert 一次了...
									v_qty := 0;
								END IF;
								p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '超過每次住院限制次數,轉換成' || bilnhrulesetrec
								.ins_fee_code2);
							END LOOP;
							CLOSE cur_3;
						END IF; --IF v_qty > bilnhruleSetREC.qty
					END IF; --IF bilnhruleSetREC.Range_Type = '1'
				END IF; --IF bilnhruleSetREC.Rule_Kind = '3'
			END LOOP;
			CLOSE cur_2;
		END LOOP;
		CLOSE cur_1;
    --12.新生兒內含項刪除
    /*急診無
    */
    --X光打折
		OPEN cur_14;
		LOOP
			FETCH cur_14 INTO emgacntwkrec;
			EXIT WHEN cur_14%notfound;
			SELECT
				COUNT (*)
			INTO v_qty
			FROM
				emg_bil_acnt_wk
			WHERE
				emg_bil_acnt_wk.caseno = pcaseno
				AND
				emg_bil_acnt_wk.ins_fee_code = emgacntwkrec.ins_fee_code
				AND
				emg_bil_acnt_wk.start_date = emgacntwkrec.start_date
				AND
				emg_bil_acnt_wk.insu_amt > 0;
			SELECT
				COUNT (*)
			INTO v_qty_1
			FROM
				emg_bil_acnt_wk,
				pflabi
			WHERE
				emg_bil_acnt_wk.caseno = pcaseno
				AND
				emg_bil_acnt_wk.ins_fee_code = emgacntwkrec.ins_fee_code
				AND
				emg_bil_acnt_wk.start_date = emgacntwkrec.start_date
				AND
				emg_bil_acnt_wk.insu_amt < 0;
			v_qty := nvl (v_qty, 0) - nvl (v_qty_1, 0);
			IF v_qty > 1 THEN
				IF emgacntwkrec.ins_fee_code = '32001C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32002C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					emgacntwkrec.ins_fee_code := '32002C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32007C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32008C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					emgacntwkrec.ins_fee_code := '32008C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32009C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32010C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					emgacntwkrec.ins_fee_code := '32010C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32011C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32012C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					emgacntwkrec.ins_fee_code := '32012C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32013C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32014C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					emgacntwkrec.ins_fee_code := '32014C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32015C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32016C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					emgacntwkrec.ins_fee_code := '32016C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32017C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32018C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					emgacntwkrec.ins_fee_code := '32018C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32022C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32023C', pdeletereason => 'X光第二張打八折')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X光第二張打八折');
					emgacntwkrec.ins_fee_code := '32023C';
				END IF;
			END IF; --IF v_qty > 1
		END LOOP;
		CLOSE cur_14;
	EXCEPTION
		WHEN OTHERS THEN
      --v_source_seq := pPfkey;
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
	END; --p_TransNHRule
	PROCEDURE p_deleteacntwk (
		pcaseno         VARCHAR2,
		pacntseq        NUMBER,
		pdeletereason   VARCHAR2
	) IS
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.acnt_seq = pacntseq;
		emgacntwkrec       emg_bil_acnt_wk%rowtype;
		emgoccurtransrec   emg_bil_occur_trans%rowtype;
		emgfeemstrec       emg_bil_feemst%rowtype;
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
		v_program_name                          := 'emg_calculate_PKG.p_deleteAcntWk';
		v_session_id                            := userenv ('SESSIONID');
    --v_source_seq := pPfkey;
		OPEN cur_1;
		FETCH cur_1 INTO emgacntwkrec;
		CLOSE cur_1;

    --複制一筆到記錄檔中
		emgoccurtransrec.caseno                 := emgacntwkrec.caseno;
    --emgOccurTransRec.Patient_Id  :=
		emgoccurtransrec.id                     := emgacntwkrec.emblpk;
		emgoccurtransrec.bil_date               := emgacntwkrec.start_date;
		emgoccurtransrec.order_seqno            := emgacntwkrec.seq_no;
    --emgOccurTransRec.Id          := emgAcntWkRec.Order_Seq;
		emgoccurtransrec.discharged             := emgacntwkrec.discharged;
		emgoccurtransrec.pf_key                 := emgacntwkrec.price_code;
		emgoccurtransrec.create_dt              := emgacntwkrec.keyin_date;
		emgoccurtransrec.fee_kind               := emgacntwkrec.fee_kind;
		emgoccurtransrec.qty                    := emgacntwkrec.qty * -1;
		IF emgacntwkrec.insu_amt <> 0 THEN
			v_amt := emgacntwkrec.insu_amt * emgacntwkrec.emg_per * emgacntwkrec.qty;
		END IF;
		IF emgacntwkrec.self_amt <> 0 THEN
			v_amt := emgacntwkrec.self_amt * emgacntwkrec.emg_per * emgacntwkrec.qty;
		END IF;
		IF emgacntwkrec.part_amt <> 0 THEN
			v_amt := emgacntwkrec.part_amt * emgacntwkrec.emg_per * emgacntwkrec.qty;
		END IF;
		emgoccurtransrec.charge_amount          := v_amt * -1;
		emgoccurtransrec.emergency              := emgacntwkrec.emg_flag;
		emgoccurtransrec.self_flag              := emgacntwkrec.self_flag;
		emgoccurtransrec.income_dept            := emgacntwkrec.cost_code;
		emgoccurtransrec.log_location           := emgacntwkrec.stock_code;
		emgoccurtransrec.discharge_bring_back   := emgacntwkrec.out_med_flag;
		emgoccurtransrec.ward                   := emgacntwkrec.ward;
		emgoccurtransrec.bed_no                 := emgacntwkrec.bed_no;
		emgoccurtransrec.created_by             := emgacntwkrec.clerk;
		emgoccurtransrec.created_date           := emgacntwkrec.keyin_date;
		emgoccurtransrec.last_updated_by        := emgacntwkrec.clerk;
		emgoccurtransrec.last_update_date       := SYSDATE;
		emgoccurtransrec.e_level                := emgacntwkrec.e_level;
		emgoccurtransrec.trans_reason           := pdeletereason;
		emgoccurtransrec.ins_fee_code           := emgacntwkrec.ins_fee_code;
		emgoccurtransrec.bildate                := emgacntwkrec.bildate;
		BEGIN
			SELECT
				MAX (emg_bil_occur_trans.acnt_seq)
			INTO v_seqno
			FROM
				emg_bil_occur_trans
			WHERE
				emg_bil_occur_trans.caseno = pcaseno;
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
		emgoccurtransrec.acnt_seq               := v_seqno;
		INSERT INTO emg_bil_occur_trans VALUES emgoccurtransrec;

    --v_amt := emgAcntWkRec.Insu_Amt * emgAcntWkRec.Emg_Per * emgAcntWkRec.qty;

    --修改 EMG_bil_feedtl 及bilfeemst的金額
		IF emgacntwkrec.insu_amt <> 0 THEN
			UPDATE emg_bil_feedtl
			SET
				emg_bil_feedtl.total_amt = emg_bil_feedtl.total_amt - v_amt
			WHERE
				emg_bil_feedtl.caseno = pcaseno
				AND
				emg_bil_feedtl.fee_type = emgacntwkrec.fee_kind
				AND
				emg_bil_feedtl.pfincode = 'LABI';
			v_amt1   := 0;
			v_amt2   := 0;
			v_amt3   := 0;
			IF emgoccurtransrec.e_level = '1' THEN
				v_amt1 := v_amt;
			ELSIF emgoccurtransrec.e_level = '2' THEN
				v_amt2 := v_amt;
			ELSE
				v_amt3 := v_amt;
			END IF;
			IF f_getnhrangeflag (pcaseno, emgacntwkrec.start_date, '2') = 'NHI0' THEN
				UPDATE emg_bil_feemst
				SET
					emg_bil_feemst.emg_exp_amt1 = emg_bil_feemst.emg_exp_amt1 - v_amt1,
					emg_bil_feemst.emg_exp_amt2 = emg_bil_feemst.emg_exp_amt2 - v_amt2,
					emg_bil_feemst.emg_exp_amt3 = emg_bil_feemst.emg_exp_amt3 - v_amt3,
					emg_bil_feemst.emg_pay_amt1 = emg_bil_feemst.emg_pay_amt1 - v_amt1,
					emg_bil_feemst.emg_pay_amt2 = emg_bil_feemst.emg_pay_amt2 - v_amt2,
					emg_bil_feemst.emg_pay_amt3 = emg_bil_feemst.emg_pay_amt3 - v_amt3
				WHERE
					emg_bil_feemst.caseno = pcaseno;
			ELSE
				UPDATE emg_bil_feemst
				SET
					emg_bil_feemst.emg_exp_amt1 = emg_bil_feemst.emg_exp_amt1 - v_amt1,
					emg_bil_feemst.emg_exp_amt2 = emg_bil_feemst.emg_exp_amt2 - v_amt2,
					emg_bil_feemst.emg_exp_amt3 = emg_bil_feemst.emg_exp_amt3 - v_amt3
				WHERE
					emg_bil_feemst.caseno = pcaseno;
			END IF;
		END IF;
		IF emgacntwkrec.self_amt <> 0 THEN
			UPDATE emg_bil_feedtl
			SET
				emg_bil_feedtl.total_amt = emg_bil_feedtl.total_amt - v_amt
			WHERE
				emg_bil_feedtl.caseno = pcaseno
				AND
				emg_bil_feedtl.fee_type = emgacntwkrec.fee_kind
				AND
				emg_bil_feedtl.pfincode = 'CIVC';
			UPDATE emg_bil_feemst
			SET
				emg_bil_feemst.tot_gl_amt = emg_bil_feemst.tot_gl_amt - v_amt
			WHERE
				emg_bil_feemst.caseno = pcaseno;
		END IF;
		IF emgacntwkrec.part_amt <> 0 THEN
			UPDATE emg_bil_feedtl
			SET
				emg_bil_feedtl.total_amt = emg_bil_feedtl.total_amt - v_amt
			WHERE
				emg_bil_feedtl.caseno = pcaseno
				AND
				emg_bil_feedtl.fee_type = emgacntwkrec.fee_kind
				AND
				emg_bil_feedtl.pfincode = emgacntwkrec.pfincode;
			UPDATE emg_bil_feemst
			SET
				emg_bil_feemst.credit_amt = emg_bil_feemst.credit_amt - v_amt
			WHERE
				emg_bil_feemst.caseno = pcaseno;
		END IF;
		DELETE FROM emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.acnt_seq = pacntseq;
	EXCEPTION
		WHEN OTHERS THEN
      -- v_source_seq := pPfkey;
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
	END; --p_deleteAcntWk
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
			emg_bil_acnt_wk
		WHERE
			emg_bil_acnt_wk.caseno = pcaseno
			AND
			emg_bil_acnt_wk.acnt_seq = pacntseq;
		emgacntwkrec       emg_bil_acnt_wk%rowtype;
		emgoccurtransrec   emg_bil_occur_trans%rowtype;
		emgfeemstrec       emg_bil_feemst%rowtype;
		emgfeedtlrec       emg_bil_feedtl%rowtype;
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
		v_program_name                          := 'emg_calculate_PKG.p_insertAcntWk';
		v_session_id                            := userenv ('SESSIONID');
    --v_source_seq := pPfkey;
		OPEN cur_1;
		FETCH cur_1 INTO emgacntwkrec;
		CLOSE cur_1;

    --複制一筆到記錄檔中
		emgoccurtransrec.caseno                 := emgacntwkrec.caseno;
    --emgOccurTransRec.Patient_Id  :=
		emgoccurtransrec.acnt_seq               := emgacntwkrec.acnt_seq;
		emgoccurtransrec.id                     := emgacntwkrec.emblpk;
		emgoccurtransrec.bil_date               := emgacntwkrec.start_date;
		emgoccurtransrec.order_seqno            := emgacntwkrec.seq_no;
    --emgOccurTransRec.Id          := emgAcntWkRec.Order_Seq;
		emgoccurtransrec.discharged             := emgacntwkrec.discharged;
		emgoccurtransrec.create_dt              := emgacntwkrec.keyin_date;
    --新生兒照顧費
		IF pinsfeecode IN (
			'57114C',
			'57115C'
		) THEN
			emgoccurtransrec.fee_kind   := '39';
			emgacntwkrec.fee_kind       := '39';
			IF pinsfeecode = '57114C' THEN
				emgacntwkrec.price_code := '60299998';
			ELSE
				emgacntwkrec.price_code := '60299999';
			END IF;
		ELSE
			emgoccurtransrec.fee_kind := emgacntwkrec.fee_kind;
		END IF;
		emgoccurtransrec.qty                    := 1;
		emgoccurtransrec.emergency              := emgacntwkrec.emg_flag;
		IF pinsfeecode IN (
			'E4001B',
			'E4002B'
		) THEN
			emgacntwkrec.self_flag   := 'N';
			emgacntwkrec.self_amt    := 0;
			emgacntwkrec.pfincode    := 'LABI';
		END IF;
		emgoccurtransrec.pf_key                 := emgacntwkrec.price_code;
		emgoccurtransrec.self_flag              := emgacntwkrec.self_flag;
		emgoccurtransrec.income_dept            := emgacntwkrec.cost_code;
		emgoccurtransrec.log_location           := emgacntwkrec.stock_code;
		emgoccurtransrec.discharge_bring_back   := emgacntwkrec.out_med_flag;
		emgoccurtransrec.ward                   := emgacntwkrec.ward;
		emgoccurtransrec.bed_no                 := emgacntwkrec.bed_no;
		emgoccurtransrec.created_by             := emgacntwkrec.clerk;
		emgoccurtransrec.created_date           := emgacntwkrec.keyin_date;
		emgoccurtransrec.last_updated_by        := emgacntwkrec.clerk;
		emgoccurtransrec.last_update_date       := SYSDATE;
		emgoccurtransrec.e_level                := emgacntwkrec.e_level;
		emgoccurtransrec.trans_reason           := pdeletereason;
		emgoccurtransrec.ins_fee_code           := pinsfeecode;
		emgoccurtransrec.bildate                := emgacntwkrec.bildate;

    --   INSERT INTO emg_bil_occur_trans VALUES emgOccurTransRec;
		BEGIN
			SELECT
				MAX (emg_bil_occur_trans.acnt_seq)
			INTO v_seqno
			FROM
				emg_bil_occur_trans
			WHERE
				emg_bil_occur_trans.caseno = pcaseno;
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
		emgoccurtransrec.acnt_seq               := v_seqno;
		SELECT
			vsnhi.labprice
		INTO v_labprice
		FROM
			vsnhi
    --FROM cpoe.vsnhi
		WHERE
			rtrim (vsnhi.labkey) = pinsfeecode
			AND
			(labbdate <= emgacntwkrec.start_date
			 OR
			 labbdate IS NULL)
			AND
			labedate >= emgacntwkrec.start_date;
		v_amt                                   := v_labprice * emgacntwkrec.emg_per * 1;
		emgoccurtransrec.charge_amount          := v_amt;
		IF pinsfeecode <> 'MA12345678NH' THEN
			INSERT INTO emg_bil_occur_trans VALUES emgoccurtransrec;
		END IF;
		BEGIN
			SELECT
				MAX (emg_bil_acnt_wk.acnt_seq)
			INTO v_seqno
			FROM
				emg_bil_acnt_wk
			WHERE
				emg_bil_acnt_wk.caseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				v_seqno := 0;
		END;
		IF v_seqno IS NULL THEN
			v_seqno := 0;
		END IF;
		emgacntwkrec.acnt_seq                   := v_seqno + 1;
		emgacntwkrec.insu_amt                   := v_labprice;
		IF pinsfeecode <> 'MA12345678NH' THEN
			emgacntwkrec.qty    := 1;
			emgacntwkrec.tqty   := 1;
		ELSE
			v_amt := v_amt * emgacntwkrec.qty;
		END IF;
		emgacntwkrec.ins_fee_code               := pinsfeecode;
		INSERT INTO emg_bil_acnt_wk VALUES emgacntwkrec;

    --修改 EMG_bil_feedtl 及bilfeemst的金額
		SELECT
			COUNT (*)
		INTO v_cnt
		FROM
			emg_bil_feedtl
		WHERE
			emg_bil_feedtl.caseno = pcaseno
			AND
			emg_bil_feedtl.fee_type = emgoccurtransrec.fee_kind
			AND
			emg_bil_feedtl.pfincode = 'LABI';
		IF v_cnt > 0 THEN
			UPDATE emg_bil_feedtl
			SET
				emg_bil_feedtl.total_amt = emg_bil_feedtl.total_amt + v_amt
			WHERE
				emg_bil_feedtl.caseno = pcaseno
				AND
				emg_bil_feedtl.fee_type = emgoccurtransrec.fee_kind
				AND
				emg_bil_feedtl.pfincode = 'LABI';
		ELSE
			emgfeedtlrec.caseno             := pcaseno;
			emgfeedtlrec.fee_type           := emgoccurtransrec.fee_kind;
			emgfeedtlrec.pfincode           := 'LABI';
			emgfeedtlrec.total_amt          := v_amt;
			emgfeedtlrec.created_by         := 'billing';
			emgfeedtlrec.created_date       := SYSDATE;
			emgfeedtlrec.last_updated_by    := 'billing';
			emgfeedtlrec.last_update_date   := SYSDATE;
			INSERT INTO emg_bil_feedtl VALUES emgfeedtlrec;
		END IF;
		v_amt1                                  := 0;
		v_amt2                                  := 0;
		v_amt3                                  := 0;
		IF emgoccurtransrec.e_level = '1' THEN
			v_amt1 := v_amt;
		ELSIF emgoccurtransrec.e_level = '2' THEN
			v_amt2 := v_amt;
		ELSE
			v_amt3 := v_amt;
		END IF;
		IF f_getnhrangeflag (pcaseno, emgacntwkrec.start_date, '2') = 'NHI0' THEN
			UPDATE emg_bil_feemst
			SET
				emg_bil_feemst.emg_exp_amt1 = emg_bil_feemst.emg_exp_amt1 + v_amt1,
				emg_bil_feemst.emg_exp_amt2 = emg_bil_feemst.emg_exp_amt2 + v_amt2,
				emg_bil_feemst.emg_exp_amt3 = emg_bil_feemst.emg_exp_amt3 + v_amt3,
				emg_bil_feemst.emg_pay_amt1 = emg_bil_feemst.emg_pay_amt1 + v_amt1,
				emg_bil_feemst.emg_pay_amt2 = emg_bil_feemst.emg_pay_amt2 + v_amt2,
				emg_bil_feemst.emg_pay_amt3 = emg_bil_feemst.emg_pay_amt3 + v_amt3
			WHERE
				emg_bil_feemst.caseno = pcaseno;
		ELSE
			UPDATE emg_bil_feemst
			SET
				emg_bil_feemst.emg_exp_amt1 = emg_bil_feemst.emg_exp_amt1 + v_amt1,
				emg_bil_feemst.emg_exp_amt2 = emg_bil_feemst.emg_exp_amt2 + v_amt2,
				emg_bil_feemst.emg_exp_amt3 = emg_bil_feemst.emg_exp_amt3 + v_amt3
			WHERE
				emg_bil_feemst.caseno = pcaseno;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
      -- v_source_seq := pPfkey;
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
	END; --p_insertAcntWk

  --判斷是否為就養榮民,使用bill的

  --自付因應身份(榮民),特約調整
	PROCEDURE p_modifityselfpay (
		pcaseno      VARCHAR2,
		pfinacl      VARCHAR2,
		v_acnt_seq   INT
	) IS
		emgfeemstrec     emg_bil_feemst%rowtype;
		emgfeedtlrec     emg_bil_feedtl%rowtype;
		emgacntwkrec     emg_bil_acnt_wk%rowtype;
		v_discount       NUMBER (5, 2);
		v_disfin         VARCHAR2 (10);
		v_discount_amt   NUMBER (10, 0);
		v_cnt            INTEGER;
		v_total_amt      INTEGER;

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
		v_program_name   := 'emg_calculate_PKG.p_modifitySelfPay';
		v_session_id     := userenv ('SESSIONID');
    --v_source_seq := pPfkey;
		IF pfinacl IN (
			'1',
			'E'
		) THEN
			p_disfin (pcaseno, 'VTAN', v_disfin);
		ELSE
			p_disfin (pcaseno, pfinacl, v_disfin);
		END IF;
		BEGIN
			SELECT
				*
			INTO emgfeemstrec
			FROM
				emg_bil_feemst
			WHERE
				emg_bil_feemst.caseno = pcaseno;
			v_discount                      := 1;
			IF v_disfin IN (
				'VT01',
				'VT02',
				'VT03'
			) THEN
				v_discount := 1;
			ELSIF v_disfin = 'VT04' THEN
				v_discount := 0.8;
			ELSIF v_disfin = 'VT05' THEN
				v_discount := 0.5;
			ELSIF v_disfin = 'VT06' THEN
				v_discount := 0.5;
			ELSIF v_disfin = 'VT07' THEN
				v_discount := 0.3;
			ELSIF v_disfin = 'VT11' THEN
				v_discount := 0;
			ELSIF v_disfin = 'EMPL' THEN
				v_discount := 0.5;
			END IF;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				tmp_fincal
			WHERE
				tmp_fincal.caseno = pcaseno
				AND
				tmp_fincal.fincalcode = '1058';
			IF v_cnt > 0 THEN
				v_discount   := 0;
				v_disfin     := '1058';
			END IF;
      /*
      SELECT COUNT(*)
        INTO v_cnt
        FROM tmp_fincal
       WHERE tmp_fincal.caseno = pCaseNo
         AND tmp_fincal.fincalcode = '1054';

      IF v_cnt > 0 then
         v_discount := 0;
         v_DisFin := '1054';
      END IF;

      --ADD BY KUO 970701 1083
      SELECT COUNT(*)
        INTO v_cnt
        FROM tmp_fincal
       WHERE tmp_fincal.caseno = pCaseNo
         AND tmp_fincal.fincalcode = '1083';

      IF v_cnt > 0 then
         v_discount := 0;
         v_DisFin := '1083';
      END IF;
      */

      --還要改按區間
      /*
      SELECT COUNT(*)
        INTO v_cnt
        FROM tmp_fincal
       WHERE tmp_fincal.caseno = pCaseNo
         AND tmp_fincal.fincalcode = '1060';

      IF v_cnt > 0 then
         v_discount := 0;
         v_DisFin := '1060';
      END IF;

      SELECT COUNT(*)
        INTO v_cnt
        FROM tmp_fincal
       WHERE tmp_fincal.caseno = pCaseNo
         AND tmp_fincal.fincalcode = '1039';

      IF v_cnt > 0 then
         v_discount := 0;
         v_DisFin := '1039';
      END IF;

      SELECT COUNT(*)
        INTO v_cnt
        FROM tmp_fincal
       WHERE tmp_fincal.caseno = pCaseNo
         AND tmp_fincal.fincalcode = '1057';

      IF v_cnt > 0 then
         v_discount := 0.9;
         v_DisFin := '1057';
      END IF;
      */
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				tmp_fincal
			WHERE
				tmp_fincal.caseno = pcaseno
				AND
				tmp_fincal.fincalcode = '1059';
			IF v_cnt > 0 THEN
				v_discount   := 0;
				v_disfin     := '1059';
			END IF;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				tmp_fincal
			WHERE
				tmp_fincal.caseno = pcaseno
				AND
				tmp_fincal.fincalcode = '1062';
			IF v_cnt > 0 THEN
				v_discount   := 0;
				v_disfin     := '1062';
			END IF;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				tmp_fincal
			WHERE
				tmp_fincal.caseno = pcaseno
				AND
				tmp_fincal.fincalcode = '1100';
			IF v_cnt > 0 THEN
				v_discount   := 0;
				v_disfin     := '1100';
			END IF;
			SELECT
				COUNT (*)
			INTO v_cnt
			FROM
				tmp_fincal
			WHERE
				tmp_fincal.caseno = pcaseno
				AND
				tmp_fincal.fincalcode = '9520';
			IF v_cnt > 0 THEN
				v_discount   := 0;
				v_disfin     := '9520';
			END IF;
			v_discount_amt                  := emgfeemstrec.tot_self_amt * (1 - v_discount);
			UPDATE emg_bil_feemst
			SET
				emg_bil_feemst.tot_self_amt = emgfeemstrec.tot_self_amt - v_discount_amt,
				emg_bil_feemst.credit_amt = emgfeemstrec.credit_amt + v_discount_amt
			WHERE
				emg_bil_feemst.caseno = pcaseno;
			emgfeedtlrec.caseno             := pcaseno;
			emgfeedtlrec.fee_type           := '41';
			emgfeedtlrec.pfincode           := v_disfin;
			emgfeedtlrec.total_amt          := v_discount_amt;
			emgfeedtlrec.created_by         := 'billing';
			emgfeedtlrec.created_date       := SYSDATE;
			emgfeedtlrec.last_updated_by    := 'billing';
			emgfeedtlrec.last_update_date   := SYSDATE;
			INSERT INTO emg_bil_feedtl VALUES emgfeedtlrec;

      /*          
      --insert acount work
      emgAcntWkRec.Caseno     := pCaseNo;
      emgAcntWkRec.Acnt_Seq   := v_acnt_seq + 1 ;

      emgAcntWkRec.Price_Code := 'COPAYEMG';
      emgAcntWkRec.Fee_Kind   := '41';
      emgAcntWkRec.Pfincode   := v_DisFin;
      emgAcntWkRec.Qty        := 1;
      emgAcntWkRec.Tqty       := 1;
      emgAcntWkRec.Emg_Flag   := 'R';
      emgAcntWkRec.Emg_Per    := 1.00;
      emgAcntWkRec.Insu_Amt   := 0;
      emgAcntWkRec.Self_Amt   := 0;
      emgAcntWkRec.Part_Amt   := v_discount_amt;

      emgAcntWkRec.Self_Flag  := 'Y';

      --emgAcntWkRec.Bed_No     := patemgcaseRec.EMGBEDNO ;
      emgAcntWkRec.Start_Date := sysdate;
      emgAcntWkRec.End_Date   := sysdate;

      emgAcntWkRec.Keyin_Date := sysdate;
      emgAcntWkRec.Bildate    := sysdate;

      insert into emg_bil_acnt_wk values emgAcntWkRec;
      */
			SELECT
				total_amt
			INTO v_total_amt
			FROM
				emg_bil_feedtl
			WHERE
				caseno = pcaseno
				AND
				pfincode = 'CIVC'
				AND
				fee_type = emgfeedtlrec.fee_type;
			IF v_total_amt - v_discount_amt > 0 THEN
				UPDATE emg_bil_feedtl
				SET
					emg_bil_feedtl.total_amt = emg_bil_feedtl.total_amt - v_discount_amt
				WHERE
					caseno = pcaseno
					AND
					pfincode = 'CIVC'
					AND
					fee_type = emgfeedtlrec.fee_type;
			ELSE
				DELETE FROM emg_bil_feedtl
				WHERE
					caseno = pcaseno
					AND
					pfincode = 'CIVC'
					AND
					fee_type = emgfeedtlrec.fee_type;
			END IF;
      /*
      IF v_total_amt - v_discount_amt > 0 THEN

        UPDATE EMG_BIL_ACNT_WK
            SET EMG_BIL_ACNT_WK.Self_Amt = EMG_BIL_ACNT_WK.Self_Amt - v_discount_amt
          WHERE caseno   = pCaseNo
            AND Pfincode = 'CIVC'
            AND Fee_Kind = EMGFeeDtlRec.Fee_Type;

       ELSE

         DELETE FROM EMG_bil_feedtl
            WHERE caseno   = pCaseNo
              AND Pfincode = 'CIVC'
              AND fee_type = EMGFeeDtlRec.Fee_Type;

       END IF;
      */
		EXCEPTION
			WHEN OTHERS THEN
				v_error_code   := sqlcode;
				v_error_info   := sqlerrm;
		END;
	EXCEPTION
		WHEN OTHERS THEN
      -- v_source_seq := pPfkey;
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
	END; --p_modifitySelfPay

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
			common.pat_emg_casen
		WHERE
			common.pat_emg_casen.ecaseno = pcaseno;
		tmpfincalrec     tmp_fincal%rowtype;
		emgcaserec       common.pat_emg_casen%rowtype;
		v_fin            VARCHAR2 (4);
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
		v_program_name   := 'emg_calculate_PKG.f_getNhRangeFlag';
		v_session_id     := userenv ('SESSIONID');
		OPEN cur_2;
		FETCH cur_2 INTO emgcaserec;
		CLOSE cur_2;

    --RETURN LABI/CIVC/特約 算價格用
		IF pfinflag = '1' THEN
      /*
      OPEN CUR_1;
      FETCH CUR_1 INTO tmpFincalRec;
      CLOSE CUR_1;
      RETURN tmpFincalRec.Fincalcode;
      */
      -- 改為一個身分到底
			IF emgcaserec.emg1fncl = '7' THEN
				RETURN 'LABI';
			ELSE
				RETURN 'CIVC';
			END IF;
		ELSIF pfinflag = '2' THEN
      --部份負擔代碼001-009, 902 免部份負擔
      --新增NHI7 (906) by kuo 20121212
			IF emgcaserec.emgcopay >= '001' AND emgcaserec.emgcopay <= '009' THEN
				v_fin := 'NHI' || substr (emgcaserec.emgcopay, 3, 1);
				RETURN v_fin;
			ELSIF emgcaserec.emgcopay IN (
				'901',
				'902'
			) THEN
				v_fin := 'NHI' || substr (emgcaserec.emgcopay, 1, 1);
				RETURN v_fin;
			ELSIF emgcaserec.emgcopay = '906' THEN
				v_fin := 'NHI7';
				RETURN v_fin;
			ELSIF emgcaserec.emg1fncl = '7' THEN
				IF emgcaserec.emg2fncl = 'G' THEN --新增警察消防海巡空勤人員醫療照護實施方案【G】不算部分負擔:NHIA by kuo 20190422
					v_fin := 'NHIA';
				ELSE
					v_fin := 'NHI0';
				END IF;
				RETURN v_fin;
			ELSE
				v_fin := 'CIVC';
				RETURN v_fin;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
      -- v_source_seq := pPfkey;
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
	END; --f_getNhRangeFlag
	PROCEDURE emgoccurfromimsdb (
		pcaseno VARCHAR2
	) IS
		emgoccurrec        cpoe.emg_occur%rowtype;
		patemgcasenrec     common.pat_emg_casen%rowtype;
		imsdbemgoccurrec   imsdb.dbemgemg_emgoccur%rowtype;
		CURSOR cur_imsdb_emgoccur (
			pcaseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			imsdb.dbemgemg_emgoccur
		WHERE
			kfa_emgroot LIKE pcaseno || '%'
			AND
			(emchtyp4 != '99'
			 OR
			 emchtyp4 IS NULL
			 OR
			 emchtyp2 != '99');
		v_seqno            INTEGER;
    --錯誤訊息用
		v_program_name     VARCHAR2 (80);
		v_session_id       NUMBER (10);
		v_error_code       VARCHAR2 (20);
		v_error_msg        VARCHAR2 (400);
		v_error_info       VARCHAR2 (600);
		v_source_seq       VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_dischage_flag    VARCHAR2 (01) := 'N';
		v_old_seqno        cpoe.emg_occur.emblpk%TYPE;
		v_count            INTEGER;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'emgOccurFromImsdb';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;

    --add if case not find, exit by kuo 20140915
		SELECT
			COUNT (*)
		INTO v_count
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;
		IF v_count = 0 THEN
			return;
		END IF;
		SELECT
			*
		INTO patemgcasenrec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno; 

    --IF SELECT * FROM IMSDB.DBEMGEMG_EMGOCCUR WHERE KFA_EMGROOT NOT EXIST RETURN;
		v_seqno          := 0;
		SELECT
			COUNT (*)
		INTO v_count
		FROM
			imsdb.dbemgemg_emgoccur
		WHERE
			kfa_emgroot LIKE pcaseno || '%';

    --刪除上一次轉入之occur資料 IF IMSDB HAS DATA
		IF v_count > 0 THEN
			DELETE FROM cpoe.emg_occur
			WHERE
				caseno = pcaseno
				AND
				hisst = 'R';
			COMMIT WORK;
		ELSE
			return;
		END IF;
		v_seqno          := 0;
		IF v_seqno IS NULL THEN
			v_seqno := 0;
		END IF;
    --將IMSDB EMGOCCUR 轉入
		OPEN cur_imsdb_emgoccur (pcaseno);
		LOOP
			FETCH cur_imsdb_emgoccur INTO imsdbemgoccurrec;
			EXIT WHEN cur_imsdb_emgoccur%notfound;
			emgoccurrec.emblpk     := 'H' || pcaseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 13) || v_seqno;
			emgoccurrec.caseno     := pcaseno;
			emgoccurrec.emocdate   := biling_common_pkg.f_get_chdate (trim (imsdbemgoccurrec.emchdate));
			IF trim (emgoccurrec.emchqty1) = '18' OR trim (emgoccurrec.emchqty1) = '06' THEN
				emgoccurrec.ordseq := 'E' || pcaseno || 'UD' || trim (imsdbemgoccurrec.emchrseq);
			ELSE
				emgoccurrec.ordseq := 'E' || pcaseno || 'OR' || trim (imsdbemgoccurrec.emchrseq);
			END IF;
			emgoccurrec.emchcode   := trim (imsdbemgoccurrec.emchcode);
			IF (imsdbemgoccurrec.emchrgcr IS NULL OR trim (imsdbemgoccurrec.emchrgcr) <> '-') THEN
				emgoccurrec.emchrgcr := '+';
			ELSE
				emgoccurrec.emchrgcr := '-';
			END IF;
			emgoccurrec.embldate   := biling_common_pkg.f_get_chdate (trim (imsdbemgoccurrec.embldate));
			emgoccurrec.emchtyp1   := trim (imsdbemgoccurrec.emchtpy1);
			emgoccurrec.emchqty1   := to_number (imsdbemgoccurrec.emquty1);
			emgoccurrec.emchamt1   := to_number (imsdbemgoccurrec.emcharg1) / 10.0;
			IF TRIM (imsdbemgoccurrec.emchtyp2) IS NOT NULL THEN
				emgoccurrec.emchtyp2 := trim (imsdbemgoccurrec.emchtyp2);
			ELSE
				emgoccurrec.emchtyp2 := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emquty2) IS NOT NULL THEN
				emgoccurrec.emchqty2 := to_number (imsdbemgoccurrec.emquty2);
			ELSE
				emgoccurrec.emchqty2 := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emcharg2) IS NOT NULL THEN
				emgoccurrec.emchamt2 := to_number (imsdbemgoccurrec.emcharg2) / 10.0;
			ELSE
				emgoccurrec.emchamt2 := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emchtyp3) IS NOT NULL THEN
				emgoccurrec.emchtyp3 := trim (imsdbemgoccurrec.emchtyp3);
			ELSE
				emgoccurrec.emchtyp3 := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emquty3) IS NOT NULL THEN
				emgoccurrec.emchqty3 := to_number (imsdbemgoccurrec.emquty3);
			ELSE
				emgoccurrec.emchqty3 := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emcharg3) IS NOT NULL THEN
				emgoccurrec.emchamt3 := to_number (imsdbemgoccurrec.emcharg3) / 10.0;
			ELSE
				emgoccurrec.emchamt3 := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emchtyp4) IS NOT NULL THEN
				emgoccurrec.emchtyp4 := trim (imsdbemgoccurrec.emchtyp4);
			ELSE
				emgoccurrec.emchtyp4 := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emquty4) IS NOT NULL THEN
				emgoccurrec.emchqty4 := to_number (imsdbemgoccurrec.emquty4);
			ELSE
				emgoccurrec.emchqty4 := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emcharg4) IS NOT NULL THEN
				emgoccurrec.emchamt4 := to_number (imsdbemgoccurrec.emcharg4) / 10.0;
			ELSE
				emgoccurrec.emchamt4 := NULL;
			END IF;
			emgoccurrec.emgcrat    := 0.0;
			emgoccurrec.emgerat    := 0.0;

      --IDEP 暫時先不入 BY KUO 990629
      --IF TRIM(imsdbEmgOccurRec.Emocsect) is not null THEN
      --  emgOccurRec.Emchidep := TRIM(imsdbEmgOccurRec.Emocsect);
      --ELSE
        --EMGOCCURREC.EMCHIDEP := NULL;
			emgoccurrec.emchidep   := trim (imsdbemgoccurrec.emgidept);
      --END IF;
			emgoccurrec.emocns     := trim (imsdbemgoccurrec.emgward);
			IF TRIM (imsdbemgoccurrec.emchemg) IS NOT NULL THEN
				emgoccurrec.emchemg := trim (imsdbemgoccurrec.emchemg);
			ELSE
				emgoccurrec.emchemg := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.empayfg) IS NOT NULL THEN
				emgoccurrec.empayfg := trim (imsdbemgoccurrec.empayfg);
			ELSE
				emgoccurrec.empayfg := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emchanes) IS NOT NULL THEN
				emgoccurrec.emchanes := trim (imsdbemgoccurrec.emchanes);
			ELSE
				emgoccurrec.emchanes := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emrescod) IS NOT NULL THEN
				emgoccurrec.emrescod := trim (imsdbemgoccurrec.emrescod);
			ELSE
				emgoccurrec.emrescod := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emchstat) IS NOT NULL THEN
				emgoccurrec.emchstat := trim (imsdbemgoccurrec.emchstat);
			ELSE
				emgoccurrec.emchstat := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emuserid) IS NOT NULL THEN
				emgoccurrec.emuserid := trim (imsdbemgoccurrec.emuserid);
			ELSE
				emgoccurrec.emuserid := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emorcat) IS NOT NULL THEN
				emgoccurrec.emorcat := trim (imsdbemgoccurrec.emorcat);
			ELSE
				emgoccurrec.emorcat := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emororno) IS NOT NULL THEN
				emgoccurrec.emororno := trim (imsdbemgoccurrec.emororno);
			ELSE
				emgoccurrec.emororno := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emorcomp) IS NOT NULL THEN
				emgoccurrec.emorcomp := trim (imsdbemgoccurrec.emorcomp);
			ELSE
				emgoccurrec.emorcomp := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emocdist) IS NOT NULL THEN
				emgoccurrec.emocdist := trim (imsdbemgoccurrec.emocdist);
			ELSE
				emgoccurrec.emocdist := NULL;
			END IF;
			IF TRIM (imsdbemgoccurrec.emocsect) IS NOT NULL THEN
				emgoccurrec.emocsect := trim (imsdbemgoccurrec.emocsect);
			ELSE
				emgoccurrec.emocsect := NULL;
			END IF;
			emgoccurrec.emdgstus   := NULL;

      -- NS
      --emgOccurRec.Emocsect := patEmgCasenRec.Emgns;
			IF TRIM (imsdbemgoccurrec.emoedept) IS NOT NULL THEN
				emgoccurrec.emoedept := trim (imsdbemgoccurrec.emoedept);
			ELSE
				emgoccurrec.emoedept := NULL;
			END IF;
			emgoccurrec.emochadp   := NULL;
			IF TRIM (imsdbemgoccurrec.emuserid) IS NOT NULL THEN
				emgoccurrec.card_no := trim (imsdbemgoccurrec.emuserid);
			ELSE
				emgoccurrec.emuserid := NULL;
			END IF;
			emgoccurrec.hisdttm    := SYSDATE;
			emgoccurrec.hisst      := 'R';
			emgoccurrec.hismsg     := 'Received from HIS';
			IF TRIM (imsdbemgoccurrec.emgpay) IS NOT NULL THEN
				emgoccurrec.emgpay := trim (imsdbemgoccurrec.emgpay);
			ELSE
				emgoccurrec.emgpay := NULL;
			END IF;
			emgoccurrec.emgorse1   := NULL;
			IF TRIM (imsdbemgoccurrec.emapply) IS NOT NULL THEN
				emgoccurrec.emapply := trim (imsdbemgoccurrec.emapply);
			ELSE
				emgoccurrec.emapply := NULL;
			END IF;
			INSERT INTO cpoe.emg_occur VALUES emgoccurrec;
			v_seqno                := v_seqno + 1;
		END LOOP;
		CLOSE cur_imsdb_emgoccur;
		COMMIT WORK;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line (v_program_name || ',' || v_source_seq || ',' || v_error_code || ',' || v_error_info);
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
	END; -- emgOccurFromImsdb end
	PROCEDURE p_emgoccurbycase (
		pcaseno VARCHAR2
	) IS
    --變數宣告區
		biloccurrec        cpoe.emg_occur%rowtype;
		bilrootrec         bil_root%rowtype;
		CURSOR cur_emgoccur (
			pcaseno VARCHAR2
		) IS
		SELECT
			emg_occur.*
		FROM
			cpoe.emg_occur,
			bil_spct_mst
		WHERE
			caseno = pcaseno
			AND
			emg_occur.emchcode = bil_spct_mst.pf_key;
    -- AND (emg_Occur.Emapply IS NULL OR trim(emg_Occur.Emapply) = '');
		CURSOR cur_spct_order (
			ppfkey VARCHAR2
		) IS
		SELECT
			*
		FROM
			cpoe.vsnhspct
		WHERE
			nhsppfcd = ppfkey; --主計價碼與子計價碼的對應檔，其中的母項碼
		CURSOR cur_spct (
			ppfkey VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_spct_dtl
		WHERE
			bil_spct_dtl.pf_key = ppfkey;
		v_patnum           VARCHAR2 (10);
		v_new_caseno       VARCHAR2 (10);
		v_seqno            INTEGER;
		v_cnt              INTEGER;
		v_skip             VARCHAR2 (01) := 'N';
		v_onedaydiettype   VARCHAR2 (01);
		v_additionalqty    INTEGER;
		v_segregateflag    VARCHAR2 (02);
		v_diet1            VARCHAR2 (02);
		v_diet2            VARCHAR2 (02);
		v_diet3            VARCHAR2 (02);
		v_price            NUMBER (10, 2);
		v_add_amt          NUMBER (10, 2);
		v_ordapno          CHAR (8);
		v_fee_type         VARCHAR2 (02);
		bilspctdtlrec      bil_spct_dtl%rowtype;
		vsnhspctrec        cpoe.vsnhspct%rowtype;
		t_spfg             VARCHAR2 (01);
		v_nhspdefg         VARCHAR2 (01);
		v_orflag           VARCHAR2 (30);
		v_comb_flag        VARCHAR2 (01);

    --錯誤訊息用
		v_program_name     VARCHAR2 (80);
		v_session_id       NUMBER (10);
		v_error_code       VARCHAR2 (20);
		v_error_msg        VARCHAR2 (400);
		v_error_info       VARCHAR2 (600);
		v_source_seq       VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_dischage_flag    VARCHAR2 (01) := 'N';
		v_old_seqno        cpoe.emg_occur.emblpk%TYPE;
		v_count            INTEGER;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'p_emgOccurByCase';
		v_session_id     := userenv ('SESSIONID');

    --刪除上一次轉入之occur資料
    --   delete from bil_occur
    --    where bil_occur.caseno = pCaseno
    --      and bil_occur.created_by = 'InformBatch';
		IF v_seqno IS NULL THEN
			v_seqno := 0;
		END IF;
		OPEN cur_emgoccur (pcaseno);
		LOOP
			FETCH cur_emgoccur INTO biloccurrec;
			EXIT WHEN cur_emgoccur%notfound;
			v_old_seqno   := biloccurrec.emblpk;
			v_count       := 0;
			IF biloccurrec.emchcode IN (
				'20002140',
				'20002190',
				'15001020',
				'15003230',
				'15004020',
				'15004030',
				'15004160',
				'15004180',
				'15004290',
				'15005150',
				'15005301',
				'15005460',
				'15005750',
				'15007080',
				'50008100'
			) THEN
				biloccurrec.emchcode := rtrim (biloccurrec.emchcode);
			END IF;
			IF biloccurrec.emocomb IS NULL OR rtrim (biloccurrec.emocomb) <> 'N' THEN
				BEGIN
					SELECT
						bil_spct_mst.spdefg
					INTO v_nhspdefg
					FROM
						bil_spct_mst
					WHERE
						bil_spct_mst.pf_key = biloccurrec.emchcode;
					IF v_nhspdefg = '2' THEN
						SELECT
							COUNT (*)
						INTO v_cnt
						FROM
							cpoe.vsnhspct
						WHERE
							nhsppfcd = biloccurrec.emchcode
							AND
							nhspit IS NOT NULL;
						IF v_cnt > 0 THEN
							v_comb_flag := 'Y';
						ELSE
							v_comb_flag := 'N';
						END IF;
					ELSE
						v_comb_flag := 'Y';
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						v_comb_flag := 'N';
				END;
			ELSE
				v_comb_flag := 'N';
			END IF;

      --以billtemp中的bltmcomb flag 來判斷是否為組合項
			IF v_comb_flag = 'Y' THEN

        --判斷spec 
				t_spfg := special_code_check (biloccurrec.emchcode);

        --NORMAL_ROUTINE   
				IF t_spfg = '0' THEN
					IF v_nhspdefg = '2' THEN

            --取得order_tmp
						BEGIN
							SELECT
								orflag
							INTO v_orflag
							FROM
								cpoe.ordlabexam
							WHERE
								ordseq = biloccurrec.ordseq;

              /*
              --取得申請序號
              select ordapno 
              into v_ordapno
              from cpoe.common_order 
              where ordseq = bilOccurRec.ORDSEQ;

              --儀器檢驗項目編碼 orflag
              BEGIN
                SELECT orflag     
                  INTO v_orflag
                  FROM lis_order_signin_history@hissp_lis
                 WHERE ocreqno = v_ordapno and ROWNUM = 1;
              EXCEPTION
                 WHEN OTHERS THEN
                      v_orflag := null;
              END;

              IF v_orflag is null THEN

               SELECT orflag     
                INTO v_orflag
                FROM lis_order_signin@hissp_lis
               WHERE ocreqno = v_ordapno and ROWNUM = 1;

              END IF;
              */
						EXCEPTION
							WHEN OTHERS THEN
								v_orflag := '000000000000';
						END;

            --CHECK ORFLAG
						OPEN cur_spct_order (biloccurrec.emchcode);
						LOOP
							FETCH cur_spct_order INTO vsnhspctrec;
							EXIT WHEN cur_spct_order%notfound;
              --醫囑原為100,改為1000 FOR COMBO MORE THAN 100
							biloccurrec.emblpk := 'C' || pcaseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 13) || MOD (v_seqno, 1000
							);
                                           --14) || mod(v_seqno, 100);
							IF substr (v_orflag, vsnhspctrec.nhsindex + 1, 1) = '1' AND vsnhspctrec.nhspit IS NOT NULL THEN
								biloccurrec.ordseq     := rtrim (biloccurrec.ordseq);
								biloccurrec.emchcode   := rtrim (vsnhspctrec.nhspit);

                --先抓出定價
								BEGIN
									SELECT
										dbpfile.pfprice1,
										dbpfile.pricety1
									INTO
										v_price,
										v_fee_type
									FROM
										cpoe.dbpfile
									WHERE
										dbpfile.pfkey = biloccurrec.emchcode;
								EXCEPTION
									WHEN OTHERS THEN
										v_error_code   := sqlcode;
										v_error_info   := sqlerrm;
								END;
								IF rtrim (v_fee_type) <> '' AND v_fee_type IS NOT NULL AND length (rtrim (v_fee_type)) = 2 THEN
									biloccurrec.emchtyp1 := v_fee_type;
								END IF;
								biloccurrec.emchamt1   := v_price;
								biloccurrec.hismsg     := 'combo exam';
								biloccurrec.emocomb    := 'N';
								biloccurrec.hisst      := 'S';
								biloccurrec.emapply    := 'C';
								v_count                := v_count + 1;
								INSERT INTO cpoe.emg_occur VALUES biloccurrec;
								v_seqno                := v_seqno + 1;
							END IF;
						END LOOP;
						CLOSE cur_spct_order;
					ELSE
						OPEN cur_spct (biloccurrec.emchcode);
						LOOP
							FETCH cur_spct INTO bilspctdtlrec;
							EXIT WHEN cur_spct%notfound;
              --醫囑原為100,改為1000 FOR COMBO MORE THAN 100
							biloccurrec.emblpk     := 'C' || pcaseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 13) || MOD (v_seqno, 1000)
							;
                                           --14) || mod(v_seqno, 100);
							biloccurrec.ordseq     := rtrim (biloccurrec.ordseq);
							biloccurrec.emchcode   := rtrim (bilspctdtlrec.child_code);

              --先抓出定價
							BEGIN
								SELECT
									dbpfile.pfprice1,
									dbpfile.pricety1
								INTO
									v_price,
									v_fee_type
								FROM
									cpoe.dbpfile
								WHERE
									dbpfile.pfkey = biloccurrec.emchcode;
							EXCEPTION
								WHEN OTHERS THEN
									v_error_code   := sqlcode;
									v_error_info   := sqlerrm;
							END;
							IF rtrim (v_fee_type) <> '' AND v_fee_type IS NOT NULL AND length (rtrim (v_fee_type)) = 2 THEN
								biloccurrec.emchtyp1 := v_fee_type;
							END IF;
							biloccurrec.emchamt1   := v_price;
							biloccurrec.hismsg     := 'combo exam';
							biloccurrec.emocomb    := 'N';
							biloccurrec.hisst      := 'S';
							biloccurrec.emapply    := 'C';
							v_count                := v_count + 1;
							INSERT INTO cpoe.emg_occur VALUES biloccurrec;
							v_seqno                := v_seqno + 1;
						END LOOP;
						CLOSE cur_spct;
					END IF;
					IF v_count > 0 THEN
						SELECT
							*
						INTO biloccurrec
						FROM
							cpoe.emg_occur
						WHERE
							emg_occur.caseno = pcaseno
							AND
							emg_occur.emblpk = v_old_seqno;
						DELETE cpoe.emg_occur
						WHERE
							emg_occur.caseno = pcaseno
							AND
							emg_occur.emblpk = v_old_seqno;
						biloccurrec.emapply := 'N';
						INSERT INTO cpoe.emg_occur VALUES biloccurrec;
					END IF;
				ELSE
          --醫囑原為100,改為1000 FOR COMBO MORE THAN 100
					biloccurrec.emblpk    := 'C' || pcaseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 13) || MOD (v_seqno, 1000);
                                        --14) || mod(v_seqno, 100);
					biloccurrec.ordseq    := rtrim (biloccurrec.ordseq);
					biloccurrec.hismsg    := 'combo exam';
					biloccurrec.emocomb   := 'N';
					biloccurrec.emapply   := 'C';
          --bilOccurRec.Id          := billTempRec.
          -- bilOccurRec.Discharged  := billTempRec.
          --    bilOccurRec.Pf_Key      := bilOccurRec.pf_key;
          --   bilOccurRec.Fee_Kind    := RTRIM(billTempRec.Bltmtp);
          --bilOccurRec.Charge_Amount := billTempRec.bltmamt;
					INSERT INTO cpoe.emg_occur VALUES biloccurrec;
					v_seqno               := v_seqno + 1;
				END IF;
			END IF;
		END LOOP;
		CLOSE cur_emgoccur;

    --END IF ;
		COMMIT WORK;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line (v_program_name || ',' || v_source_seq || ',' || v_error_code || ',' || v_error_info);
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
	END; --p_emgOccurByCase

  --組合項特殊規則cehck
	FUNCTION special_code_check (
		ppfkey VARCHAR2
	) RETURN VARCHAR2 IS
		t_fg              VARCHAR2 (01) := '0';
    --錯誤訊息用
		v_program_name    VARCHAR2 (80);
		v_session_id      NUMBER (10);
		v_error_code      VARCHAR2 (20);
		v_error_msg       VARCHAR2 (400);
		v_error_info      VARCHAR2 (600);
		v_source_seq      VARCHAR2 (20);
		e_user_exception EXCEPTION;
		v_dischage_flag   VARCHAR2 (01) := 'N';
		v_old_seqno       bil_occur.acnt_seq%TYPE;
		v_count           INTEGER;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'biling_daily_pkg.special_code_check';
		v_session_id     := userenv ('SESSIONID');
		IF ppfkey IN (
			'30010000',
			'30020000',
			'25001000',
			'25001001',
			'25001002',
			'25001003',
			'25001004',
			'25110000'
		) THEN
			t_fg := '1';
		ELSE
			t_fg := '0';
		END IF;
		RETURN t_fg;
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

  --掛號費入帳
	PROCEDURE emgregfee (
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
		patemgcaserec    common.pat_emg_casen%rowtype;
		emgfeedtlrec     emg_bil_feedtl%rowtype;
		emgfeemstrec     emg_bil_feemst%rowtype;
		emgacntwkrec     emg_bil_acnt_wk%rowtype;
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'emg_calculate_PKG.EMGREGFEE';
		v_session_id     := userenv ('SESSIONID');
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;

    --只收掛號費
		IF patemgcaserec.emgregfg = 'Y' THEN
			emgacntwkrec.caseno             := pcaseno;
			emgacntwkrec.acnt_seq           := 1;
      --emgAcntWkRec.Acnt_Seq   := emgOccurRec.Acnt_Seq; ???
      --emgAcntWkRec.Seq_No     := emgOccurRec.Acnt_Seq; ???
			emgacntwkrec.seq_no             := f_get_seq_no (pcaseno);
			emgacntwkrec.price_code         := 'REGISTER';
			emgacntwkrec.fee_kind           := '37';
			emgacntwkrec.qty                := 1;
			emgacntwkrec.tqty               := 1;
			emgacntwkrec.emg_flag           := 'R';
			emgacntwkrec.emg_per            := 1;
			emgacntwkrec.insu_amt           := 0;
			emgacntwkrec.self_amt           := 170;
			emgacntwkrec.part_amt           := 0;
			emgacntwkrec.self_flag          := 'Y';
      -- emgAcntWkRec.Order_Doc  :=
			emgacntwkrec.bed_no             := patemgcaserec.emgbedno;
			emgacntwkrec.start_date         := patemgcaserec.emgdt;
			emgacntwkrec.end_date           := patemgcaserec.emgdt;
      --emgAcntWkRec.Nh_Type    := v_fee_type;
			emgacntwkrec.cost_code          := patemgcaserec.emgns;
			emgacntwkrec.keyin_date         := patemgcaserec.emgdt;
			emgacntwkrec.ward               := patemgcaserec.emgns;
			emgacntwkrec.clerk              := 'BILLING';
      --emgAcntWkRec.Old_Acnt_Seq := emgOccurRec.Acnt_Seq; ???
      --emgAcntWkRec.EMBLPK     := emgOccurRec.EMBLPK;
			emgacntwkrec.bildate            := patemgcaserec.emgdt;
			emgacntwkrec.stock_code         := patemgcaserec.emgns;
			emgacntwkrec.dept_code          := patemgcaserec.emgns;
			INSERT INTO emg_bil_acnt_wk VALUES emgacntwkrec;
			emgfeedtlrec.caseno             := pcaseno;
			emgfeedtlrec.fee_type           := '37';
			emgfeedtlrec.pfincode           := 'CIVC';
			emgfeedtlrec.total_amt          := emgfeemstrec.emg_pay_amt1;
			emgfeedtlrec.created_by         := 'biling';
			emgfeedtlrec.created_date       := SYSDATE;
			emgfeedtlrec.last_updated_by    := 'biling';
			emgfeedtlrec.last_update_date   := SYSDATE;
			INSERT INTO emg_bil_feedtl VALUES emgfeedtlrec;
			emgfeemstrec.emg_exp_amt1       := 170;
			emgfeemstrec.tot_self_amt       := 170;
			emgfeemstrec.tot_gl_amt         := 170;
			UPDATE emg_bil_feemst
			SET
				emg_exp_amt1 = 170,
				tot_self_amt = 170,
				tot_gl_amt = 170
			WHERE
				caseno = pcaseno;
			COMMIT WORK;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
      -- v_source_seq := pPfkey;
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
	END; --EMGREGFEE

  --預估帳
  /*PROCEDURE pOverDueOrder(pCaseNo varchar2) IS
    --找出醫囑不是藥，且未簽收(<38)         
    CURSOR CUR_1 IS
      SELECT t.*
        FROM cpoe.common_order T
       WHERE t.encntno = pCaseNo
         AND t.ordstatus < '38'
         AND t.ordtype <> 'UD';

    CURSOR CUR_2 IS
      SELECT *
        FROM common.pat_emg_casen
       WHERE common.pat_emg_casen.ecaseno = pCaseNo;

    --錯誤訊息用
    v_program_name varchar2(80);
    v_session_id   number(10);
    v_source_seq   varchar2(20);
    v_error_code   varchar2(20);
    v_error_msg    varchar2(400);
    v_error_info   varchar2(600);
    e_user_exception exception;
    commonOrderRec  cpoe.common_order%ROWTYPE;
    bilFeeDtlRec    emg_bil_feedtl%ROWTYPE;
    emgcaseRec      common.pat_emg_casen%ROWTYPE;
    v_fee_type      varchar2(02);
    v_amt           number(10, 2);
    v_amt1          number(10, 1);
    v_amt2          number(10, 1);
    v_amt3          number(10, 1);
    v_day           integer;
    v_Emg_Per       number(8, 2);
    v_pf_self_pay   number(10, 2);
    v_pf_nh_pay     number(10, 2);
    v_price         number(10, 2);
    v_pfincode      varchar2(10);
    v_emg           varchar2(01);
    vHoliday_Per    NUMBER(10, 3);
    vNight_Per      NUMBER(10, 3);
    vChild_Per      NUMBER(10, 3);
    vUrgent_Per     NUMBER(10, 3);
    vOperation_Per  NUMBER(10, 3);
    vAnesthesia_Per NUMBER(10, 3);
    vMaterials_Per  NUMBER(10, 3);

  BEGIN

    OPEN CUR_2;
    FETCH CUR_2
      INTO emgcaseRec;
    CLOSE CUR_2;

    IF emgcaseRec.emgpstat = 'I' THEN

      OPEN CUR_1;
      LOOP
        FETCH CUR_1
          INTO commonOrderRec;
        EXIT WHEN CUR_1%NOTFOUND;
        BEGIN
          SELECT cpoe.cpoe_ordertmp.pfkey_1
            INTO commonOrderRec.Pfcode
            FROM cpoe.cpoe_ordertmp
           WHERE cpoe.cpoe_ordertmp.udocasorseq = commonOrderRec.Ordseq;
          BEGIN
            SELECT PRICETY1, cpoe.dbpfile.pfprice1
              INTO v_fee_type, v_price
              FROM cpoe.dbpfile
             WHERE dbpfile.PFKEY = commonOrderRec.Pfcode;
          EXCEPTION
            WHEN OTHERS THEN
              v_error_code := SQLCODE;
              v_error_info := SQLERRM;
          END;

          --判斷是否為強迫自費項目 或病患為自費身份
          IF commonOrderRec.Ordpayfg = 'S' OR emgcaseRec.Emg1fncl = '9' THEN
            v_amt := v_price * 1;
            BEGIN
              SELECT *
                INTO bilfeedtlREC
                FROM emg_bil_feedtl
               WHERE emg_bil_feedtl.caseno = pCaseNo
                 AND emg_bil_feedtl.fee_type = v_fee_type
                 AND emg_bil_feedtl.pfincode = 'CIVC';

              UPDATE emg_bil_feedtl
                 SET emg_bil_feedtl.total_amt = emg_bil_feedtl.total_amt +
                                                v_amt
               WHERE emg_bil_feedtl.caseno = pCaseNo
                 AND emg_bil_feedtl.fee_type = v_fee_type
                 AND emg_bil_feedtl.pfincode = 'CIVC';

            EXCEPTION
              WHEN OTHERS THEN
                bilFeeDtlRec.Caseno           := pCaseNo;
                bilFeeDtlRec.Fee_Type         := v_fee_type;
                bilFeeDtlRec.Pfincode         := 'CIVC';
                bilFeeDtlRec.Total_Amt        := v_amt;
                bilFeeDtlRec.Created_By       := 'biling';
                bilFeeDtlRec.Created_Date     := SYSDATE;
                bilFeeDtlRec.Last_Updated_By  := 'biling';
                bilFeeDtlRec.Last_Update_Date := SYSDATE;
            END;
          END IF;

          --病患為健保身份                   
          IF emgcaseRec.Emg1fncl = '7' THEN
            IF commonOrderRec.Ordfreqn IN ('1', 'E', 'URGENT', 'STAT') THEN
              v_emg := 'E';
            ELSE
              v_emg := 'R';
            END IF;

            --v_Emg_Per := 
            Getemgper(pCaseNo        => pCaseNo,
                      pPFkey         => commonOrderRec.Pfcode,
                      pFeeKind       => v_fee_type,
                      pEmgFlag       => v_emg,
                      pFncl          => emgcaseRec.Emg1fncl,
                      pType          => '1',
                      pDate          => sysdate,
                      Emg_Per        => v_Emg_Per,
                      Holiday_Per    => vHoliday_Per,
                      Night_Per      => vNight_Per,
                      Child_Per      => vChild_Per,
                      Urgent_Per     => vUrgent_Per,
                      Operation_Per  => vOperation_Per,
                      Anesthesia_Per => vAnesthesia_Per,
                      Materials_Per  => vMaterials_Per);

            BEGIN
              SELECT to_number(pfselpay) / 100, to_number(pfreqpay) / 100
                INTO v_pf_self_pay, v_pf_nh_pay
                FROM pfclass
               WHERE pfclass.pfkey = commonOrderRec.Pfcode
                 AND pfclass.pfincode = 'LABI';

              --抓不到資料,有可能是自費身份或純自費項      
            EXCEPTION

              WHEN NO_DATA_FOUND THEN
                v_pf_self_pay := v_price;
                v_pf_nh_pay   := 0;

            END;

            IF v_pf_self_pay > 0 THEN
              v_pfincode := 'CIVC';
              v_amt      := v_pf_self_pay * 1 * v_Emg_Per;

              BEGIN
                SELECT *
                  INTO bilfeedtlREC
                  FROM emg_bil_feedtl
                 WHERE emg_bil_feedtl.caseno = pCaseNo
                   AND emg_bil_feedtl.fee_type = v_fee_type
                   AND emg_bil_feedtl.pfincode = v_pfincode;

                UPDATE emg_bil_feedtl
                   SET emg_bil_feedtl.total_amt = emg_bil_feedtl.total_amt +
                                                  v_amt
                 WHERE emg_bil_feedtl.caseno = pCaseNo
                   AND emg_bil_feedtl.fee_type = v_fee_type
                   AND emg_bil_feedtl.pfincode = v_pfincode;

                UPDATE emg_bil_feemst
                   SET emg_bil_feemst.tot_gl_amt = emg_bil_feemst.tot_gl_amt +
                                                   v_amt
                 WHERE emg_bil_feemst.caseno = pCaseNo;

              EXCEPTION
                WHEN OTHERS THEN
                  bilFeeDtlRec.Caseno           := pCaseNo;
                  bilFeeDtlRec.Fee_Type         := v_fee_type;
                  bilFeeDtlRec.Pfincode         := v_pfincode;
                  bilFeeDtlRec.Total_Amt        := v_amt;
                  bilFeeDtlRec.Created_By       := 'biling';
                  bilFeeDtlRec.Created_Date     := SYSDATE;
                  bilFeeDtlRec.Last_Updated_By  := 'biling';
                  bilFeeDtlRec.Last_Update_Date := SYSDATE;
                  INSERT INTO emg_bil_feedtl VALUES bilFeeDtlRec;
              END;
            END IF;

            IF v_pf_nh_pay > 0 THEN
              v_pfincode := 'LABI';
              v_amt      := v_pf_nh_pay * 1 * v_Emg_Per;

              BEGIN
                SELECT *
                  INTO bilfeedtlREc
                  FROM emg_bil_feedtl
                 WHERE emg_bil_feedtl.caseno = pCaseNo
                   AND emg_bil_feedtl.fee_type = v_fee_type
                   AND emg_bil_feedtl.pfincode = v_pfincode;

                UPDATE emg_bil_feedtl
                   SET emg_bil_feedtl.total_amt = emg_bil_feedtl.total_amt +
                                                  v_amt
                 WHERE emg_bil_feedtl.caseno = pCaseNo
                   AND emg_bil_feedtl.fee_type = v_fee_type
                   AND emg_bil_feedtl.pfincode = v_pfincode;

              EXCEPTION

                WHEN NO_DATA_FOUND THEN
                  bilFeeDtlRec.Caseno           := pCaseNo;
                  bilFeeDtlRec.Fee_Type         := v_fee_type;
                  bilFeeDtlRec.Pfincode         := v_pfincode;
                  bilFeeDtlRec.Total_Amt        := v_amt;
                  bilFeeDtlRec.Created_By       := 'biling';
                  bilFeeDtlRec.Created_Date     := SYSDATE;
                  bilFeeDtlRec.Last_Updated_By  := 'biling';
                  bilFeeDtlRec.Last_Update_Date := SYSDATE;
                  INSERT INTO emg_bil_feedtl VALUES bilFeeDtlRec;

              END;

            END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            v_error_code := SQLCODE;
            v_error_info := SQLERRM;
        END;
      END LOOP;
      CLOSE CUR_1;

    END IF;

    --設定程式名稱及session_id
    v_program_name := 'emg_calculdate_pkg.pOverDueOrder';
    v_session_id   := USERENV('SESSIONID');
  EXCEPTION
    WHEN OTHERS THEN
      v_error_code := SQLCODE;
      v_error_info := SQLERRM;
      ROLLBACK WORK;

      DELETE FROM biling_spl_errlog
       WHERE session_id = v_session_id
         AND prog_name = v_program_name;

      INSERT INTO biling_spl_errlog
        (session_id,
         sys_date,
         prog_name,
         err_code,
         err_msg,
         err_info,
         source_seq)
      VALUES
        (v_session_id,
         sysdate,
         v_program_name,
         v_error_code,
         v_error_msg,
         v_error_info,
         v_source_seq);
      commit work;
  END;*/
    --預估帳
  --原邏輯是將金額反應在feedtl中,修改為直接將帳款加入emg_occur中(update by amber 20110426)
	PROCEDURE poverdueorder (
		pcaseno VARCHAR2
	) IS
    --找出醫囑不是藥，且未簽收(<38),ADD OR 不預估 BY KUO 1000509
		CURSOR cur_1 IS
		SELECT
			t.*
		FROM
			cpoe.common_order t
		WHERE
			t.encntno = pcaseno
			AND
			t.ordstatus < '38'
			AND
			t.ordtype NOT IN (
				'UD',
				'OR'
			);
         --AND t.ordtype <> 'UD';
		CURSOR cur_2 IS
		SELECT
			*
		FROM
			common.pat_emg_casen
		WHERE
			common.pat_emg_casen.ecaseno = pcaseno;

    --錯誤訊息用
		v_program_name    VARCHAR2 (80);
		v_session_id      NUMBER (10);
		v_source_seq      VARCHAR2 (20);
		v_error_code      VARCHAR2 (20);
		v_error_msg       VARCHAR2 (400);
		v_error_info      VARCHAR2 (600);
		e_user_exception EXCEPTION;
		commonorderrec    cpoe.common_order%rowtype;
		emgcaserec        common.pat_emg_casen%rowtype;
		emgoccrec         cpoe.emg_occur%rowtype;
		v_cnt             INTEGER;
		v_seq             INTEGER;
		v_date            DATE;
		v_fee_type        VARCHAR2 (02);
		v_amt             NUMBER (10, 2);
		v_emg_per         NUMBER (8, 2);
		v_pf_self_pay     NUMBER (10, 2);
		v_pf_nh_pay       NUMBER (10, 2);
		v_price           NUMBER (10, 2);
		v_pfincode        VARCHAR2 (10);
		v_emg             VARCHAR2 (01);
		v_nhspdefg        VARCHAR2 (01);
		v_comb_flag       VARCHAR2 (01);
		vholiday_per      NUMBER (10, 3);
		vnight_per        NUMBER (10, 3);
		vchild_per        NUMBER (10, 3);
		vurgent_per       NUMBER (10, 3);
		voperation_per    NUMBER (10, 3);
		vanesthesia_per   NUMBER (10, 3);
		vmaterials_per    NUMBER (10, 3);
	BEGIN
    --設定程式名稱及session_id
		v_program_name   := 'pOverDueOrder';
		v_session_id     := userenv ('SESSIONID');
		OPEN cur_2;
		FETCH cur_2 INTO emgcaserec;
		CLOSE cur_2;

    --IF emgcaseRec.emgpstat = 'I' THEN
		v_seq            := 0;
		OPEN cur_1;
		LOOP
			FETCH cur_1 INTO commonorderrec;
			EXIT WHEN cur_1%notfound;
      --dbms_output.put_line(commonorderrec.ordseq);
			BEGIN
				SELECT
					cpoe.cpoe_ordertmp.pfkey_1
				INTO
					commonorderrec
				.pfcode
				FROM
					cpoe.cpoe_ordertmp
				WHERE
					cpoe.cpoe_ordertmp.udocasorseq = commonorderrec.ordseq;
				BEGIN
					SELECT
						pricety1,
						cpoe.dbpfile.pfprice1
					INTO
						v_fee_type,
						v_price
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = commonorderrec.pfcode;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
				IF commonorderrec.ordfreqn IN (
					'1',
					'E',
					'URGENT',
					'STAT'
				) THEN
					v_emg := 'E';
				ELSE
					v_emg := 'R';
				END IF;

        --v_Emg_Per急作乘數
				getemgper (pcaseno, ppfkey => commonorderrec.pfcode, pfeekind => v_fee_type, pemgflag => v_emg, pfncl => emgcaserec.emg1fncl,
				ptype => '1', pdate => SYSDATE, emg_per => v_emg_per, holiday_per => vholiday_per, night_per => vnight_per, child_per => vchild_per
				, urgent_per => vurgent_per, operation_per => voperation_per, anesthesia_per => vanesthesia_per, materials_per => vmaterials_per
				);

        --判斷是否為強迫自費項目 或病患為自費身份,自費價格
				IF commonorderrec.ordpayfg = 'S' OR emgcaserec.emg1fncl = '9' THEN
					v_amt                := v_price * 1;
					v_pfincode           := 'CIVC';
					v_emg                := 'R';
					emgoccrec.emchanes   := 'PR'; --20160815 加入by kuo 
				ELSE
					emgoccrec.emchanes := '';
				END IF;

        --病患為健保身份
				IF emgcaserec.emg1fncl = '7' THEN
					BEGIN
						SELECT
							to_number (pfselpay) / 100,
							to_number (pfreqpay) / 100
						INTO
							v_pf_self_pay,
							v_pf_nh_pay
						FROM
							pfclass
						WHERE
							pfclass.pfkey = commonorderrec.pfcode
							AND
							pfclass.pfincode = 'LABI';
            --抓不到資料,有可能是自費身份或純自費項
					EXCEPTION
						WHEN no_data_found THEN
							v_pf_self_pay   := v_price;
							v_pf_nh_pay     := 0;
					END;
					IF v_pf_self_pay > 0 THEN
						v_pfincode   := 'CIVC';
						v_amt        := v_pf_self_pay * 1 * v_emg_per;
					END IF;
					IF v_pf_nh_pay > 0 THEN
						v_pfincode   := 'LABI';
						v_amt        := v_pf_nh_pay * 1 * v_emg_per;
					END IF;
				END IF;

        --判斷是否為組合項
				BEGIN
					SELECT
						bil_spct_mst.spdefg
					INTO v_nhspdefg
					FROM
						bil_spct_mst
					WHERE
						bil_spct_mst.pf_key = commonorderrec.pfcode;
					v_comb_flag := 'N';
					IF v_nhspdefg = '2' THEN
						SELECT
							COUNT (*)
						INTO v_cnt
						FROM
							cpoe.vsnhspct
						WHERE
							nhsppfcd = commonorderrec.pfcode
							AND
							nhspit IS NOT NULL;
						IF v_cnt > 0 THEN
							v_comb_flag := 'Y';
						ELSE
							v_comb_flag := 'N';
						END IF;
					ELSE
						v_comb_flag := 'Y';
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						v_comb_flag := 'N';
				END;
				v_seq                := v_seq + 1;
				v_date               := trunc (emgcaserec.emgdt);
				emgoccrec.caseno     := pcaseno;
				emgoccrec.emblpk     := pcaseno || 'O' || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 13) || MOD (v_seq, 1000);
                                              --15) || MOD(v_seq, 100);
				emgoccrec.emocdate   := commonorderrec.orddttm; --v_date; --改成COMMON_ORDER 的 ORDDTTM        
				emgoccrec.embldate   := SYSDATE; --v_date; --改為SYSDATE
				emgoccrec.ordseq     := commonorderrec.ordseq;
				emgoccrec.emchrgcr   := '+';
				emgoccrec.emchcode   := commonorderrec.pfcode;
				emgoccrec.emchtyp1   := v_fee_type;
				emgoccrec.emchqty1   := 1;
				emgoccrec.emchamt1   := v_amt;
				emgoccrec.emchtyp2   := '99';
				emgoccrec.emchtyp4   := '99';
				emgoccrec.emchemg    := v_emg;
				emgoccrec.emchidep   := '';--emgcaserec.emgns; --強制收入歸屬科(4 BYTES)
				emgoccrec.emchstat   := emgcaserec.emgns; --消耗地點(4 BYTES)
				emgoccrec.emocomb    := v_comb_flag;
				emgoccrec.emocsect   := emgcaserec.emgns; --計價科別(4 BYTES)
				emgoccrec.emocns     := emgcaserec.emgns; --病房(4 BYTES)
				emgoccrec.emoedept   := emgcaserec.emgns; --開立科別(4 BYTES, EMG ONLY)
				emgoccrec.hisst      := 'S';
				emgoccrec.emuserid   := 'OVRORDER';
				emgoccrec.card_no    := 'OVRORDER';
				INSERT INTO cpoe.emg_occur VALUES emgoccrec;
        --INSERT INTO BIL_CALLREPORT_LOG(CASENO,DATE_CALLED,REPORT,MSG,HTTP_STRING)
        --VALUES(PCASENO,SYSDATE,'OVERORDER',emgoccrec.emchcode,emgoccrec.ordseq);
        --病理虛擬碼 by kuo 20161021
				IF emgoccrec.emocdate >= TO_DATE ('20161101', 'YYYYMMDD') AND emgoccrec.emchcode IN (
					'94002030',
					'94002031'
				) THEN
					emgoccrec.emblpk     := f_getemg_occrpk (emgoccrec.emblpk);
					emgoccrec.emchcode   := 'PATH0000';--虛擬碼
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				END IF;
				COMMIT WORK;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
			END;
		END LOOP;
		CLOSE cur_1;
    --COMMIT WORK;
    --END IF;
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

  --急診每日帳款重算(因應醫收需每日結轉,需每日將有發生帳款的CASENO重算)(add by amber 20110413)  
	PROCEDURE daily_process IS
    /* MARK BY KUO 1000523
    cursor CUR_C1(vDate varchar2) is
      SELECT DISTINCT trim(kfa_emgroot) caseno
        FROM imsdb.dbemgemg_emgoccur a
       WHERE 1 = 1
         AND trim(EMBLDATE) = vDate
         AND EXISTS (SELECT 'X'
                FROM common.pat_emg_casen
               WHERE ecaseno = TRIM(A.kfa_emgroot)
                 AND EMGLVDT IS NULL);
    */
    --imsdb.dbemgemg_emgoccur and cpoe.emg_occur also needed by kuo 1000523
		CURSOR cur_c1 (
			pdate DATE
		) IS
		SELECT DISTINCT
			TRIM (kfa_emgroot) AS xcaseno
		FROM
			imsdb.dbemgemg_emgoccur
		WHERE
			TRIM (embldate) = biling_common_pkg.f_return_date (pdate)
		UNION
		SELECT DISTINCT
			caseno AS xcaseno
		FROM
			cpoe.emg_occur
		WHERE
			embldate >= trunc (pdate)
			AND
			embldate < trunc (pdate + 1)
			AND
			emchtyp1 NOT IN (
				'01',
				'03',
				'05'
			);
		v_error_code    VARCHAR2 (20);
		v_error_info    VARCHAR2 (600);
		pdate           VARCHAR2 (6);
		v_messageout    VARCHAR2 (400);
		av_messageout   VARCHAR2 (400);
		cnt             NUMBER;
		errcnt          NUMBER;
		emgdailyprocess_error EXCEPTION;
		vcaseno         common.pat_emg_casen.ecaseno%TYPE;
	BEGIN
    --pDate := biling_common_pkg.f_return_date(sysdate - 1);
    --OPEN CUR_C1(PDATE);
    --增加LOG by Kuo 20130416
		INSERT INTO bil_daliyjoblog (
			job_date,
			job_kind,
			job_code,
			created_by
		) VALUES (
			trunc (SYSDATE),
			'X',
			'EMGDAILY',
			'BILLING'
		);
		COMMIT WORK;
		av_messageout   := '';
		cnt             := 0;
		errcnt          := 0;
		OPEN cur_c1 (trunc (SYSDATE - 1));
		LOOP
			FETCH cur_c1 INTO vcaseno;
			IF cur_c1%found THEN
				emg_calculate_pkg.main_process (pcaseno => TRIM (vcaseno), poper => 'billing', pmessageout => v_messageout);
				cnt := cnt + 1;
				IF v_messageout != 'OK' THEN
          --RAISE emgDailyProcess_error;
					av_messageout   := av_messageout || vcaseno || ':' || v_messageout || '.';
					errcnt          := errcnt + 1;
				END IF;
			END IF;
			EXIT WHEN cur_c1%notfound;
		END LOOP;
    --刪除掉已取消掛號但是仍有帳款的caseno
		DELETE emg_bil_acnt_wk a
		WHERE
			NOT EXISTS (
				SELECT
					'x'
				FROM
					common.pat_emg_casen
				WHERE
					ecaseno = a.caseno
			)
			    AND
			    trunc (keyin_date) = trunc (SYSDATE) - 1;
		DELETE emg_bil_feemst a
		WHERE
			NOT EXISTS (
				SELECT
					'x'
				FROM
					common.pat_emg_casen
				WHERE
					ecaseno = a.caseno
			)
			    AND
			    trunc (created_date) = trunc (SYSDATE) - 1;
		DELETE emg_bil_feedtl a
		WHERE
			NOT EXISTS (
				SELECT
					'x'
				FROM
					common.pat_emg_casen
				WHERE
					ecaseno = a.caseno
			)
			    AND
			    trunc (created_date) = trunc (SYSDATE) - 1;
    --
		IF av_messageout = '' OR av_messageout IS NULL THEN
			bil_sendmail ('', '', 'EMG_CALCULATE.DAILY_PROCESS', 'PROCESS END WITH OK COUNT:' || TO_CHAR (cnt));
			bil_sendmail ('', 'cc3f@vghtc.gov.tw', 'EMG_CALCULATE.DAILY_PROCESS', 'PROCESS END WITH OK COUNT:' || TO_CHAR (cnt));
			bil_sendmail ('', 'khcheng@vghtc.gov.tw', 'EMG_CALCULATE.AILY_PROCESS', 'PROCESS END WITH OK COUNT:' || TO_CHAR (cnt));
		ELSE
			bil_sendmail ('', '', 'EMG_CALCULATE.DAILY_PROCESS', av_messageout);
			bil_sendmail ('', 'cc3f@vghtc.gov.tw', 'EMG_CALCULATE.DAILY_PROCESS', av_messageout);
			bil_sendmail ('', 'khcheng@vghtc.gov.tw', 'EMG_CALCULATE.DAILY_PROCESS', av_messageout);
		END IF;
    --增加LOG by Kuo 20130416
		UPDATE bil_daliyjoblog
		SET
			finished_flag = 'Y',
			last_update_date = SYSDATE,
			last_updated_by = 'BILLING',
			log_msg = TO_CHAR (SYSDATE - 1, 'YYYYMMDD') || ' 急診過帳成功!'
		WHERE
			job_code = 'EMGDAILY'
			AND
			job_date = trunc (SYSDATE)
			AND
			job_kind = 'X';
		COMMIT WORK;
	EXCEPTION
    --when emgDailyProcess_error then
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			bil_sendmail ('', '', 'EMG_CALCULATE.DAILY_PROCESS', v_error_code || ',' || v_error_info);
			bil_sendmail ('', 'cc3f@vghtc.gov.tw', 'EMG_CALCULATE.DAILY_PROCESS', v_error_code || ',' || v_error_info);
			bil_sendmail ('', 'khcheng@vghtc.gov.tw', 'EMG_CALCULATE.DAILY_PROCESS', v_error_code || ',' || v_error_info);
      --dbms_output.put_line(vCaseno || ',emgDailyProcess_error');
			NULL;
	END;

  --emg_occur備份(add by amber 20110412) 
	PROCEDURE bkoccur (
		pcaseno VARCHAR2
	) IS
		CURSOR c1 IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			caseno = pcaseno;
		emgacntrec     emg_bil_acnt_wk%rowtype;
		v_hist_id      NUMBER;
		v_error_code   VARCHAR2 (30);
		v_error_info   VARCHAR2 (300);
	BEGIN
  --2012.03.20 ，將原本的max寫法改成rownum寫法
		SELECT
			nvl (MAX (hist_id), 0)
		INTO v_hist_id
		FROM
			(
				SELECT
					hist_id
				FROM
					emg_bil_acnt_wk_hist
				WHERE
					caseno = pcaseno
				ORDER BY
					hist_id DESC
			)
		WHERE
			ROWNUM < 2;
		v_hist_id := v_hist_id + 1;
		OPEN c1;
		LOOP
			FETCH c1 INTO emgacntrec;
			EXIT WHEN c1%notfound;
			INSERT INTO emg_bil_acnt_wk_hist VALUES (
				v_hist_id,
				emgacntrec.caseno,
				emgacntrec.acnt_seq,
				emgacntrec.seq_no,
				emgacntrec.price_code,
				emgacntrec.fee_kind,
				emgacntrec.cost_code,
				emgacntrec.keyin_date,
				emgacntrec.unit_desc,
				emgacntrec.qty,
				emgacntrec.cir_code,
				emgacntrec.path_code,
				emgacntrec.days,
				emgacntrec.tqty,
				emgacntrec.insu_tqty,
				emgacntrec.stock_code,
				emgacntrec.emg_flag,
				emgacntrec.emg_per,
				emgacntrec.insu_amt,
				emgacntrec.self_amt,
				emgacntrec.part_amt,
				emgacntrec.self_flag,
				emgacntrec.order_doc,
				emgacntrec.execute_doc,
				emgacntrec.order_seq,
				emgacntrec.clerk,
				emgacntrec.bed_no,
				emgacntrec.dept_code,
				emgacntrec.start_date,
				emgacntrec.end_date,
				emgacntrec.start_time,
				emgacntrec.end_time,
				emgacntrec.out_med_flag,
				emgacntrec.diff_flag,
				emgacntrec.remark,
				emgacntrec.del_flag,
				emgacntrec.upd_oper,
				TRIM (biling_common_pkg.f_return_date7 (SYSDATE)), --此筆歷史帳建立日期(民國年YYYMMDD)
				TO_CHAR (SYSDATE, 'hh24MI'),   --此筆歷史帳建立時間(時分)
				emgacntrec.med_consume,
				emgacntrec.ins_fee_code,
				emgacntrec.nh_type,
				emgacntrec.e_level,
				emgacntrec.discharged,
				emgacntrec.ward,
				emgacntrec.pfincode,
				emgacntrec.emblpk,
				emgacntrec.bildate,
				emgacntrec.holiday_per,
				emgacntrec.night_per,
				emgacntrec.child_per,
				emgacntrec.urgent_per,
				emgacntrec.operation_per,
				emgacntrec.anesthesia_per,
				emgacntrec.materials_per
			);
		END LOOP;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line (v_error_code || ',' || v_error_info);
	END;

  --更新欠款檔 - 重算帳款後是否已無欠款或是欠款金額有異動(add by amber 20110420) 
	PROCEDURE p_debt_check (
		pcaseno VARCHAR2
	) IS

    /*CURSOR c1 IS
    SELECT ecaseno
      FROM common.pat_emg_casen
     WHERE TRUNC(emglvdt) BETWEEN TO_DATE('20110215', 'yyyymmdd') AND
           TO_DATE('20110419', 'yyyymmdd');*/
		emgdebtrec   emg_bil_debt_rec%rowtype;
		v_tot_amt    NUMBER;
		v_debt_amt   NUMBER;
    --pcaseno    common.pat_emg_casen.ecaseno%TYPE;
	BEGIN
    /*OPEN c1;

    LOOP
      FETCH c1
        INTO pcaseno;

      EXIT WHEN c1%NOTFOUND;*/
		BEGIN
			SELECT
				*
			INTO emgdebtrec
			FROM
				emg_bil_debt_rec
			WHERE
				caseno = pcaseno
				AND
				change_flag = 'N';
			IF SQL%found THEN
        --抓取目前最新的帳款應繳金額
				SELECT
					SUM (round (nvl (tot_self_amt, 0) + nvl (tot_gl_amt, 0)))
				INTO v_tot_amt
				FROM
					emg_bil_feemst
				WHERE
					caseno = pcaseno;

        --檢查欠款檔中金額是否相同,若不相同,則要更新欠款檔資料
				IF abs (emgdebtrec.total_self_amt - v_tot_amt) > 1 THEN
					v_debt_amt := v_tot_amt - emgdebtrec.total_paid_amt;
					UPDATE emg_bil_debt_rec
					SET
						total_self_amt = v_tot_amt,
						debt_amt = v_debt_amt
					WHERE
						caseno = pcaseno;
          --DBMS_OUTPUT.put_line(pcaseno || ':' || v_tot_amt || ',' ||v_debt_amt);

          --若欠款金額為0,表示原本欠款但更改身份後已不需繳費,將欠款狀態改為'C'-取消
					IF v_debt_amt = 0 THEN
						UPDATE emg_bil_debt_rec
						SET
							change_flag = 'C'
						WHERE
							caseno = pcaseno;
					END IF;
				END IF;
			END IF;
		EXCEPTION
			WHEN no_data_found THEN
				NULL;
		END;
    --END LOOP;
	END;
	FUNCTION f_get_seq_no (
		pcaseno VARCHAR2
	) RETURN VARCHAR2 IS
		v_max_seq_no NUMBER;
	BEGIN
		SELECT
			nvl (MAX (to_number (seq_no)), 0)
		INTO v_max_seq_no
		FROM
			emg_bil_acnt_wk
		WHERE
			caseno = pcaseno;
		v_max_seq_no := v_max_seq_no + 1;
    --DBMS_OUTPUT.PUT_LINE(v_max_seq_no);
		return (TO_CHAR (v_max_seq_no));
	END;

  --追蹤預估醫囑
	PROCEDURE t_ovrordlog (
		pcaseno VARCHAR2
	) IS
		v_error_code   VARCHAR2 (20);
		v_error_info   VARCHAR2 (600);
    --離院還在開立狀態的醫囑
		CURSOR get_ord IS
		SELECT
			*
		FROM
			cpoe.common_order
		WHERE
			encntno = pcaseno
			AND
			ordstatus < '38'
			AND
			pfcode IS NOT NULL;
    --組合碼拆解
		CURSOR get_combopf (
			pfcode VARCHAR2
		) IS
		SELECT
			nhspit
		FROM
			cpoe.vsnhspct
		WHERE
			nhsppfcd = pfcode
			AND
			nhspit IS NOT NULL;
		cntovr         NUMBER;
		awkcnt         NUMBER;
		combo          NUMBER;
		ovrordstr      VARCHAR2 (400);
		novrordstr     VARCHAR2 (400);
		pf_key         VARCHAR2 (12);
		ordrec         cpoe.common_order%rowtype;
	BEGIN
		cntovr       := 0;
		novrordstr   := '';
		ovrordstr    := '';
		OPEN get_ord;
		LOOP
			FETCH get_ord INTO ordrec;
			EXIT WHEN get_ord%notfound;
      --DBMS_OUTPUT.PUT_LINE('A');
			cntovr   := cntovr + 1;
			awkcnt   := 0;
			SELECT
				COUNT (*)
			INTO awkcnt
			FROM
				emg_bil_acnt_wk
			WHERE
				caseno = pcaseno
				AND
				clerk = 'OVRORDER'
				AND
				price_code = ordrec.pfcode
				AND
				bildate = ordrec.orddttm;
      --DBMS_OUTPUT.PUT_LINE('B');
			IF awkcnt > 0 THEN
				ovrordstr := ovrordstr || ordrec.pfcode || ',';
			ELSE
         --找不到主項，找組合項
         --DBMS_OUTPUT.PUT_LINE('C');
				combo := 0;
				OPEN get_combopf (ordrec.pfcode);
				LOOP
					FETCH get_combopf INTO pf_key;
					EXIT WHEN get_combopf%notfound;
					awkcnt := 0;
					SELECT
						COUNT (*)
					INTO awkcnt
					FROM
						emg_bil_acnt_wk
					WHERE
						caseno = pcaseno
						AND
						clerk = 'OVRORDER'
						AND
						price_code = pf_key
						AND
						bildate = ordrec.orddttm;
           --DBMS_OUTPUT.PUT_LINE('D');
					IF awkcnt > 0 THEN
						ovrordstr   := ovrordstr || ordrec.pfcode || ' C:' || pf_key || ',';
						combo       := combo + 1;
					END IF;
				END LOOP;
				CLOSE get_combopf;
			END IF;
      --DBMS_OUTPUT.PUT_LINE('W');
			IF combo = 0 THEN
				novrordstr := novrordstr || ordrec.pfcode || ' NO OVRORDER,';
			END IF;
		END LOOP;
		CLOSE get_ord;
    --DBMS_OUTPUT.PUT_LINE(PCASENO||':'||OVRORDSTR||';'||NOVRORDSTR||'.');
		INSERT INTO bil_callreport_log (
			caseno,
			date_called,
			report,
			msg,
			http_string
		) VALUES (
			pcaseno,
			SYSDATE,
			'OVERORDER',
			ovrordstr,
			novrordstr
		);
		COMMIT WORK;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line ('T_OVRORDLOG ERROR:' || v_error_code || ',' || v_error_info || ',' || pcaseno);
	END t_ovrordlog;
  --帳務未拆(自付為0)部份加入 EMG_BIL_ACNT_WK BY KUO 1000601
	PROCEDURE zero_emg_acnkwk (
		pcaseno VARCHAR2
	) IS
		CURSOR get_zero_occ (
			vcaseno VARCHAR
		) IS
		SELECT
			*
		FROM
			cpoe.emg_occur
		WHERE
			caseno = vcaseno
			AND
			emblpk NOT IN (
				SELECT
					emblpk
				FROM
					emg_bil_acnt_wk
				WHERE
					caseno = vcaseno
			)
			AND
			emapply IS NULL
			AND
			emchtyp1 NOT IN (
				'11',
				'12'
			);
		v_error_code    VARCHAR2 (20);
		v_error_msg     VARCHAR2 (400);
		v_error_info    VARCHAR2 (600);
		anct_seq        NUMBER;
		pftype          VARCHAR2 (02);
		emgoccurrec     cpoe.emg_occur%rowtype;
		emgacntwkrec    emg_bil_acnt_wk%rowtype;
		patemgcaserec   common.pat_emg_casen%rowtype;
	BEGIN
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;
		BEGIN
			SELECT
				MAX (acnt_seq)
			INTO anct_seq
			FROM
				emg_bil_acnt_wk
			WHERE
				caseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				anct_seq := 0;
		END;
		OPEN get_zero_occ (pcaseno);
		LOOP
			FETCH get_zero_occ INTO emgoccurrec;
			EXIT WHEN get_zero_occ%notfound;
			anct_seq                  := anct_seq + 1;
      --dbms_output.put_line('ANCT_SEQ:'||ANCT_SEQ);
			emgacntwkrec.acnt_seq     := anct_seq;
			emgacntwkrec.emg_per      := 1;
			emgacntwkrec.emg_flag     := emgoccurrec.emchemg;
			BEGIN
				SELECT
					pricety1
				INTO pftype
				FROM
					cpoe.dbpfile
				WHERE
					pfkey = emgoccurrec.emchcode;
			EXCEPTION
				WHEN OTHERS THEN
					pftype := emgoccurrec.emchtyp1;
			END;
			emgacntwkrec.fee_kind     := pftype;
			IF emgoccurrec.emchrgcr = '-' THEN
				emgoccurrec.emchqty1 := -1 * emgoccurrec.emchqty1;
			END IF;
			emgacntwkrec.caseno       := pcaseno;
			emgacntwkrec.seq_no       := f_get_seq_no (pcaseno);
			emgacntwkrec.price_code   := emgoccurrec.emchcode;
			emgacntwkrec.qty          := emgoccurrec.emchqty1;
			emgacntwkrec.tqty         := emgoccurrec.emchqty1;
			emgacntwkrec.emg_flag     := emgoccurrec.emchemg;
			emgacntwkrec.emg_per      := emgacntwkrec.emg_per;
			emgacntwkrec.insu_amt     := 0;
			emgacntwkrec.self_amt     := 0;
			emgacntwkrec.part_amt     := 0;
			IF emgoccurrec.emchanes <> 'PR' OR emgoccurrec.emchanes IS NULL THEN
				emgacntwkrec.self_flag := 'N';
			ELSE
				emgacntwkrec.self_flag := 'Y';
			END IF;
			emgacntwkrec.bed_no       := patemgcaserec.emgbedno;
			emgacntwkrec.start_date   := emgoccurrec.emocdate;
			emgacntwkrec.end_date     := emgoccurrec.emocdate;
			emgacntwkrec.nh_type      := emgoccurrec.emchtyp1;
			emgacntwkrec.cost_code    := emgoccurrec.emchidep;
			emgacntwkrec.keyin_date   := emgoccurrec.embldate;
			emgacntwkrec.ward         := emgoccurrec.emocns;
			emgacntwkrec.clerk        := emgoccurrec.emuserid;
      --emgAcntWkRec.Old_Acnt_Seq := emgOccurRec.Acnt_Seq; ???
			emgacntwkrec.emblpk       := emgoccurrec.emblpk;
			emgacntwkrec.bildate      := emgoccurrec.emocdate;
			emgacntwkrec.stock_code   := emgoccurrec.emocdist;
			emgacntwkrec.dept_code    := emgoccurrec.emocsect;
			emgacntwkrec.order_seq    := emgoccurrec.ordseq;
			emgacntwkrec.insu_amt     := 0;
			emgacntwkrec.self_amt     := 0;
			emgacntwkrec.part_amt     := 0;
			emgacntwkrec.pfincode     := 'CIVC';
			emgacntwkrec.bildate      := emgoccurrec.emocdate;
			INSERT INTO emg_bil_acnt_wk VALUES emgacntwkrec;
		END LOOP;
		CLOSE get_zero_occ;
		COMMIT WORK;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line ('ZERO_EMG_ACNKWK ERROR:' || v_error_code || ',' || v_error_info || ',' || pcaseno);
	END zero_emg_acnkwk;

  --急診申報前重算 BY KUO 1000628
	PROCEDURE emg_recalmon (
		pmonth VARCHAR2
	) IS
    --PMONTH離院的CASE
		CURSOR nhi_emgcase IS
		SELECT
			*
		FROM
			common.pat_emg_casen
		WHERE
			TO_CHAR (emglvdt, 'YYYYMM') = pmonth
			AND
			emg1fncl = '7';
		v_error_code   VARCHAR2 (20);
		v_error_msg    VARCHAR2 (400);
		v_error_info   VARCHAR2 (600);
		patemgcase     common.pat_emg_casen%rowtype;
		pmessage       VARCHAR2 (100);
	BEGIN
		dbms_output.put_line ('START AT:' || SYSDATE);
		OPEN nhi_emgcase;
		LOOP
			FETCH nhi_emgcase INTO patemgcase;
			EXIT WHEN nhi_emgcase%notfound;
			main_process (patemgcase.ecaseno, '', pmessage);
		END LOOP;
		CLOSE nhi_emgcase;
		dbms_output.put_line ('END AT:' || SYSDATE);
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line ('EMG_RECALMON ERROR:' || v_error_code || ',' || v_error_info || ',' || pmonth);
	END emg_recalmon;

  --急診分攤主要程式--強制以健保計算 BY KUO 1000808
	PROCEDURE main_process_labi (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2
	) IS
    --變數宣告區

    --錯誤訊息用途
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		emgbildebtrec    emg_bil_debt_rec%rowtype;
		recalculate      VARCHAR2 (1) := 'Y';
		patemgcaserec    common.pat_emg_casen%rowtype;
	BEGIN
    --增加HIS欠款不重算的判斷(add by amber 20110401)
		BEGIN
			SELECT
				*
			INTO emgbildebtrec
			FROM
				emg_bil_debt_rec
			WHERE
				caseno = pcaseno;
			IF emgbildebtrec.created_by = 'HIS' THEN
				recalculate := 'N';
			END IF;
		EXCEPTION
			WHEN no_data_found THEN
				NULL;
			WHEN OTHERS THEN
				NULL;
		END;
		IF recalculate = 'Y' THEN

      --設定程式名稱及session_id
			v_program_name   := 'emg_calculate_PKG_A.Main_Process_LABI';
			v_session_id     := userenv ('SESSIONID');
			v_source_seq     := trim (pcaseno);

      --在重算前先將該caseno的emg_occur備份
      --dbms_output.put_line('bkOccur');
			bkoccur (trim (pcaseno));

      --刪除原有計算資料
      --dbms_output.put_line('initdata');
			initdata (trim (pcaseno));

      --展開身份別
      --dbms_output.put_line('extanfin');
      --extandfin(trim(pCaseNo));
      --只考慮為健保(EMG1FNCL=7)的算法,已經離院才適用
      --增加一筆PAT_EMG_FINANCL DATA, 算完後刪除
      --PAT_EMG_CASEN.EMG1FNCL改為 7,算完後改回
			SELECT
				*
			INTO patemgcaserec
			FROM
				common.pat_emg_casen
			WHERE
				ecaseno = pcaseno;
			UPDATE common.pat_emg_casen
			SET
				emg1fncl = '7'
			WHERE
				ecaseno = pcaseno;
			COMMIT WORK;
			INSERT INTO tmp_fincal (
				caseno,
				fincalcode,
				st_date,
				end_date
			) VALUES (
				pcaseno,
				'LABI',
				trunc (patemgcaserec.emgdt),
				trunc (patemgcaserec.emglvdt)
			);

      --入固定費用到emg_occur
      --dbms_output.put_line('EMGFixFees');
			emgfixfees (trim (pcaseno));

      --預估入賬
      --dbms_output.put_line('pOverDueOrder');
      --POVERDUEORDER(TRIM(PCASENO));
      --從IMSDB 轉入HIS上帳款
      --dbms_output.put_line('emgOccurFromImsdb');
			emgoccurfromimsdb (trim (pcaseno));

      --need add考量合併項主項，把合併項的細項取定價及費用類別逐一新增入emg_occur，再將合併項主項刪除
      --dbms_output.put_line('p_emgOccurByCase');
			p_emgoccurbycase (pcaseno => TRIM (pcaseno));

      --trace log to billtemp_leave
      --SAVEOVR2BLTMP(PCASENO);
      --計算分攤
      --dbms_output.put_line('CompAcntWk');
			compacntwk (trim (pcaseno), poper);

      --特約，身份等調整
      --dbms_output.put_line('p_receivableComp');
			p_receivablecomp (pcaseno => TRIM (pcaseno));

      --更新欠款檔 - 重算帳款後是否已無欠款或是欠款金額有異動(add by amber 20110420)   
      --p_debt_check(pCaseNo => trim(pCaseNo));

      --將emg_occur預估資料刪除
			DELETE cpoe.emg_occur
			WHERE
				caseno = TRIM (pcaseno)
				AND
				emuserid = 'OVRORDER';
			COMMIT WORK;
      --加入自付為0的記錄FOR 醫收
			zero_emg_acnkwk (pcaseno);
			UPDATE common.pat_emg_casen
			SET
				emg1fncl = '9'
			WHERE
				ecaseno = pcaseno;
			COMMIT WORK;
			pmessageout      := 'OK';
      --dbms_output.put_line(pmessageout);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_source_seq   := trim (pcaseno);
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			pmessageout    := sqlcode || ',' || sqlerrm;
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
	END main_process_labi; --Main_Process_LABI

--國際醫療計算用，整個翻新 BY KUO 20121108
  --健保給付價=健保價*1.63 20151102 以後為 2.21 request by 國際醫療小組 add by kuo
  --自費=自費*1.3 20151015 以後為 1.7 request by 國際醫療小組 add by kuo
  --有部份給付算在自費(含病房費，護理費)
  --無藥事服務費
	PROCEDURE contract_es999 (
		pcaseno VARCHAR2
	) IS
		CURSOR upd_acnt_wk IS
		SELECT
			*
		FROM
			emg_bil_acnt_wk
		WHERE
			caseno = pcaseno
			AND
			fee_kind <> '03'
			AND
			price_code <> '91711115'
		ORDER BY
			fee_kind;
         --FOR UPDATE;
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
			emg_bil_feedtl
		WHERE
			caseno = pcaseno
		ORDER BY
			fee_type
		FOR UPDATE;
		sprice           cpoe.dbpfile.pfprice1%TYPE;
		pfcnhiprice      NUMBER;
		pfcselprice      NUMBER;
		pfmlogrec        pfmlog%rowtype;
		bilfeedtlrec     emg_bil_feedtl%rowtype;
		totalglamt       NUMBER;
		emper            NUMBER;
		cuflag           VARCHAR2 (1);
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
		acntwk_rec       emg_bil_acnt_wk%rowtype;
		patemgcaserec    common.pat_emg_casen%rowtype;
	BEGIN
		v_program_name   := 'EMG_calculate_PKG.CONTRACT_ES999';
		v_session_id     := userenv ('SESSIONID');
		v_source_seq     := pcaseno;
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;
    --國際醫療S999 BY KUO 20121128
    --若加入S998,相同規則，只要將CIVC改成S998即可
    --加入S995,相同規則，只要將CIVC改成S995即可 by kuo 20150721
		IF patemgcaserec.emgspeu1 NOT IN (
			'S999',
			'S995'
		) OR patemgcaserec.emgspeu1 IS NULL THEN
			return;
		END IF;    
    --dbms_output.put_line('into S999...');
		OPEN upd_acnt_wk;
		LOOP
			<< xxx >>
      --EMPER:=1.3;
			 FETCH upd_acnt_wk INTO acntwk_rec;
			EXIT WHEN upd_acnt_wk%notfound;
      --dbms_output.put_line(ACNTWK_REC.PRICE_CODE||' 0.EMPER='||ACNTWK_REC.EMG_PER);
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
			IF acntwk_rec.fee_kind = '06' THEN
				sprice := acntwk_rec.self_amt;
			END IF;
      --非CU病房診察費一律1500,急診無
      --藥事服務費取消
			IF acntwk_rec.fee_kind = '04' THEN
				UPDATE emg_bil_acnt_wk
				SET
					qty = 0,
					tqty = 0
				WHERE
					caseno = acntwk_rec.caseno
					AND
					price_code = acntwk_rec.price_code
					AND
					seq_no = acntwk_rec.seq_no;
				COMMIT WORK;
				GOTO xxx;
			END IF;
      --一般項目
      --DBMS_OUTPUT.PUT_LINE(ACNTWK_REC.PRICE_CODE||' EMPER='||EMPER*ACNTWK_REC.EMG_PER||','||ACNTWK_REC.BILDATE||','||ACNTWK_REC.SEQ_NO);
      --Add by kuo 20150721 for S995
			IF patemgcaserec.emgspeu1 = 'S995' THEN
				UPDATE emg_bil_acnt_wk
				SET
					emg_per = emper * acntwk_rec.emg_per,
					self_amt = sprice,
					pfincode = patemgcaserec.emgspeu1
				WHERE
					caseno = acntwk_rec.caseno
					AND
					price_code = acntwk_rec.price_code
					AND
					seq_no = acntwk_rec.seq_no;
				COMMIT WORK;
			ELSE
				UPDATE emg_bil_acnt_wk
				SET
					emg_per = emper * acntwk_rec.emg_per,
					self_amt = sprice
				WHERE
					caseno = acntwk_rec.caseno
					AND
					price_code = acntwk_rec.price_code
					AND
					seq_no = acntwk_rec.seq_no;
				COMMIT WORK;
			END IF;
		END LOOP;
		CLOSE upd_acnt_wk;
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
				emg_bil_acnt_wk
			WHERE
				caseno = pcaseno
				AND
				fee_kind = bilfeedtlrec.fee_type;
      --Add by kuo 20150721 for S995
			IF patemgcaserec.emgspeu1 = 'S995' THEN
				UPDATE emg_bil_feedtl
				SET
					total_amt = bilfeedtlrec.total_amt,
					pfincode = patemgcaserec.emgspeu1
				WHERE
					CURRENT OF upd_bil_feedtl;
			ELSE
				UPDATE emg_bil_feedtl
				SET
					total_amt = bilfeedtlrec.total_amt
				WHERE
					CURRENT OF upd_bil_feedtl;
			END IF;
		END LOOP;
		CLOSE upd_bil_feedtl;
		COMMIT WORK;
		SELECT
			SUM (total_amt)
		INTO totalglamt
		FROM
			emg_bil_feedtl
		WHERE
			caseno = pcaseno;
    --Add by kuo 20150721 for S995
		IF patemgcaserec.emgspeu1 = 'S995' THEN
			UPDATE emg_bil_feemst
			SET
				credit_amt = totalglamt,
				tot_gl_amt = 0
			WHERE
				caseno = pcaseno;
		ELSE
			UPDATE emg_bil_feemst
			SET
				tot_gl_amt = totalglamt
			WHERE
				caseno = pcaseno;
		END IF;
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
	END contract_es999;

  --急診獎勵用 by kuo 20160405
	PROCEDURE hospinout (
		pcaseno VARCHAR2
	) IS
		cnt             NUMBER;
		cntnhiss        NUMBER;
		outhospno       VARCHAR2 (10);
		hosplevel       VARCHAR2 (1);
		udtrn           VARCHAR2 (4);
		ppfkey          VARCHAR2 (12);
		v_error_code    VARCHAR2 (20);
		v_error_info    VARCHAR2 (600);
		patemgcase      common.pat_emg_casen%rowtype;
		patemgdiagrec   common.pat_emg_diagnosis%rowtype;
		emgoccrec       cpoe.emg_occur%rowtype;
		dbpfilerec      cpoe.dbpfile%rowtype;
		diagcode1       VARCHAR2 (10);
		diagcode2       VARCHAR2 (10);
		v_date          DATE;
		vuddcnt01       VARCHAR2 (01);
		CURSOR get_diag IS
		SELECT
			*
		FROM
			common.pat_emg_diagnosis
		WHERE
			ecaseno = pcaseno
		ORDER BY
			ediagmain DESC,
			ediagstat;
		CURSOR cur_dbpfile (
			ppfkey VARCHAR2
		) IS
		SELECT
			*
		FROM
			cpoe.dbpfile
		WHERE
			pfkey = ppfkey;
	BEGIN
		SELECT
			*
		INTO patemgcase
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;

	--由20160601 開始 by kuo 20160405 
		IF patemgcase.emgdt < TO_DATE ('20160601', 'YYYYMMDD') THEN
			return;
		END IF;

  --非健保身份不做 by kuo 20160518
		IF patemgcase.emg1fncl <> '7' THEN
			return;
		END IF;
		outhospno   := get_outhospno (patemgcase.ecaseno);
		IF patemgcase.emglvdt IS NULL THEN
			v_date := SYSDATE;
		ELSE
			v_date := patemgcase.emglvdt;
		END IF;
		OPEN get_diag;
		cnt         := 1;
		LOOP
			FETCH get_diag INTO patemgdiagrec;
			EXIT WHEN cnt > 2 OR get_diag%notfound;
			IF cnt = 1 THEN
				diagcode1 := patemgdiagrec.icd10;
			END IF;
			IF cnt = 2 THEN
				diagcode2 := patemgdiagrec.icd10;
			END IF;
			cnt := cnt + 1;
		END LOOP;
		CLOSE get_diag;
  --DBMS_OUTPUT.PUT_LINE('DIAGCODE1:'||DIAGCODE1);
  --DBMS_OUTPUT.PUT_LINE('DIAGCODE2:'||DIAGCODE2);

    --轉出轉入
    --醫院level 使用 OPDUSR.BASHOSP
    --NHIROOT_REC.INHOSPNO  := PATEMGCASE.EMGINHOSPNO;                -- 轉入院所or單位
    --INHOSPNO,OUTHOSPNO
    --轉入
    --只有平上
		IF patemgcase.emginhospno IS NOT NULL THEN
       --dbms_output.put_line('IN');
			BEGIN
				SELECT
					hospitallevel
				INTO hosplevel
				FROM
					opdusr.bashosp
				WHERE
					hospitalno = patemgcase.emginhospno;
			EXCEPTION
				WHEN OTHERS THEN
					hosplevel := '2';
			END;
       --dbms_output.put_line('HOSPLEVEL:'||HOSPLEVEL);
			IF hosplevel = '1' THEN
				udtrn    := 'PAR';
				ppfkey   := '66030052';--'P4608B'
			ELSE
				udtrn    := 'UP';
				ppfkey   := '66030050';--'P4604B'
			END IF;
			OPEN cur_dbpfile (ppfkey);
			FETCH cur_dbpfile INTO dbpfilerec;
			IF cur_dbpfile%notfound THEN
				dbpfilerec.pfprice1   := 0;
				dbpfilerec.pricety1   := '03';
			END IF;
			CLOSE cur_dbpfile;
       --DBMS_OUTPUT.PUT_LINE('DIAGT:'||DIAGCODE1||','||DIAGCODE2||',TRN:'||UDTRN||','||EMG_PRIZE_TRN_DIAGT(DIAGCODE1,DIAGCODE2,UDTRN));
			IF emg_prize_trn_diagt (diagcode1, diagcode2, udtrn) = 'Y' THEN
          --ADD THEN PRIZE CODE;
				emgoccrec.caseno     := pcaseno;
				emgoccrec.emblpk     := pcaseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15);
				emgoccrec.emocdate   := v_date;
				emgoccrec.embldate   := v_date;
				emgoccrec.ordseq     := 'E' || pcaseno || 'EMPRIZ';
				emgoccrec.emchrgcr   := '+';
				emgoccrec.emchcode   := ppfkey;
				emgoccrec.emchtyp1   := dbpfilerec.pricety1;
				emgoccrec.emchqty1   := 1;
				emgoccrec.emchamt1   := dbpfilerec.pfprice1;
				emgoccrec.emchtyp2   := '99';
				emgoccrec.emchtyp4   := '99';
				emgoccrec.emchemg    := 'R';
				emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --強制收入歸屬科(4 BYTES)
				emgoccrec.emchstat   := patemgcase.emgns; --消耗地點(4 BYTES)
				emgoccrec.card_no    := 'EMPRIZE'; --急診獎勵，不列入帳款計算 by kuo 20160517
				emgoccrec.emocomb    := 'N';
				emgoccrec.emapply    := 'N';        --急診獎勵，不列入帳款計算 by kuo 20160517
				emgoccrec.emocsect   := patemgcase.emgsect; --計價科別(4 BYTES)
				emgoccrec.emocns     := patemgcase.emgns; --病房(4 BYTES)
				emgoccrec.emoedept   := patemgcase.emgsect; --開立科別(4 BYTES, EMG ONLY)
				emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert '||PPFKEY||' to date:'||v_date);
          --dbms_output.put_line('轉入 insert');
				INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				COMMIT WORK;
			END IF;
		END IF;
    --轉出
    --只有平下
		IF outhospno IS NOT NULL THEN
			BEGIN
				SELECT
					hospitallevel
				INTO hosplevel
				FROM
					opdusr.bashosp
				WHERE
					hospitalno = outhospno;
			EXCEPTION
				WHEN OTHERS THEN
					hosplevel := '2';
			END;
       --dbms_output.put_line('HOSPLEVEL:'||HOSPLEVEL);
			IF hosplevel = '1' THEN
				udtrn    := 'PAR';
				ppfkey   := '66030053';--'P4607B'
			ELSE
         --P4605B 為 UP by kuo 20150811
         --UDTRN:='DOWN';
				udtrn    := 'DOWN';
				ppfkey   := '66030051';--'P4605B'
			END IF;
			OPEN cur_dbpfile (ppfkey);
			FETCH cur_dbpfile INTO dbpfilerec;
			IF cur_dbpfile%notfound THEN
				dbpfilerec.pfprice1   := 0;
				dbpfilerec.pricety1   := '03';
			END IF;
			CLOSE cur_dbpfile;
       --DBMS_OUTPUT.PUT_LINE('DIAGT:'||NHIROOTREC.NHIDIAGTCODE1||','||NHIROOTREC.NHIDIAGTCODE2||',TRN:'||UDTRN||','||LABITEM||','||EMG_PRIZE_TRN_DIAGT(NHIROOTREC.NHIDIAGTCODE1,NHIROOTREC.NHIDIAGTCODE2,UDTRN));
			IF emg_prize_trn_diagt (diagcode1, diagcode2, udtrn) = 'Y' THEN
          --ADD THEN PRIZE CODE;
          --ADD THEN PRIZE CODE;
				emgoccrec.caseno     := pcaseno;
				emgoccrec.emblpk     := pcaseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15);
				emgoccrec.emocdate   := v_date;
				emgoccrec.embldate   := v_date;
				emgoccrec.ordseq     := 'E' || pcaseno || 'EMPRIZ';
				emgoccrec.emchrgcr   := '+';
				emgoccrec.emchcode   := ppfkey;
				emgoccrec.emchtyp1   := dbpfilerec.pricety1;
				emgoccrec.emchqty1   := 1;
				emgoccrec.emchamt1   := dbpfilerec.pfprice1;
				emgoccrec.emchtyp2   := '99';
				emgoccrec.emchtyp4   := '99';
				emgoccrec.emchemg    := 'R';
				emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --強制收入歸屬科(4 BYTES)
				emgoccrec.emchstat   := patemgcase.emgns; --消耗地點(4 BYTES)
				emgoccrec.card_no    := 'EMPRIZE'; --急診獎勵，不列入帳款計算 by kuo 20160517
				emgoccrec.emocomb    := 'N';
				emgoccrec.emapply    := 'N';        --急診獎勵，不列入帳款計算 by kuo 20160517
				emgoccrec.emocsect   := patemgcase.emgsect; --計價科別(4 BYTES)
				emgoccrec.emocns     := patemgcase.emgns; --病房(4 BYTES)
				emgoccrec.emoedept   := patemgcase.emgsect; --開立科別(4 BYTES, EMG ONLY)
				emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert '||PPFKEY||' to date:'||v_date);
          --dbms_output.put_line('轉出 insert');
				INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				COMMIT WORK;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line ('HOSPINOUT' || v_error_code || ',' || v_error_info || ':' || pcaseno);
	END hospinout;
	FUNCTION get_outhospno (
		pcaseno VARCHAR2
	) RETURN VARCHAR2 AS
		v_error_code   VARCHAR2 (20);
		v_error_info   VARCHAR2 (600);
		outhospno      VARCHAR2 (10);
		hospname       VARCHAR2 (100);
		provalue       vghtc.encounter_props.prop_value%TYPE;
	BEGIN
		SELECT
			prop_value
		INTO provalue
		FROM
			vghtc.encounter_props
		WHERE
			prop_key = 'emg.encounter.prop.tranOutHospAndReason'
			AND
			encounter_type = 'E'
			AND
			encounter_id = pcaseno;
		hospname := substr (provalue, 1, instr (provalue, ' ') - 1);
		SELECT
			hosp_id
		INTO outhospno
		FROM
			common.nhihospital
		WHERE
			hosp_name = hospname;
		RETURN outhospno;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
    --DBMS_OUTPUT.PUT_LINE('GET_OUTHOSPNO '||V_ERROR_CODE||','||V_ERROR_INFO||':'||PCASENO);
			RETURN NULL;
	END get_outhospno;
	FUNCTION emg_prize_trn_diagt (
		diagcode1   VARCHAR2,
		diagcode2   VARCHAR2,
		ud          VARCHAR2
	) RETURN VARCHAR2 IS
		v_error_code   VARCHAR2 (20);
		v_error_info   VARCHAR2 (600);
	BEGIN
		IF ud IN (
			'UP',
			'PAR'
		) THEN
			IF diagcode1 >= 'I21.0' AND diagcode1 <= 'I21.3' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'I63' AND diagcode1 <= 'I66' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'I71.00' AND diagcode1 <= 'I71.02' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 IN (
				'K70.0',
				'K70.10',
				'K70.11',
				'K70.2',
				'K70.30',
				'K70.31',
				'K70.40',
				'K70.41',
				'K70.9',
				'K73.0',
				'K73.1',
				'K73.2',
				'K73.8',
				'K73.9',
				'K74.0',
				'K74.1',
				'K74.2',
				'K74.3',
				'K74.4',
				'K74.5',
				'K74.60',
				'K74.69',
				'K75.4',
				'K75.81',
				'K76.0',
				'K76.89',
				'K76.9'
			) THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 = 'K76.6' AND diagcode2 = 'I85.11' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 IN (
				'A41.9',
				'R57.1',
				'R57.8',
				'R65.21'
			) THEN
				RETURN 'Y';
			END IF;
			IF length (diagcode1) >= 7 THEN
				IF substr (diagcode1, 7, 1) = 'A' THEN
					IF substr (diagcode1, 1, 3) >= 'S00' AND substr (diagcode1, 1, 3) <= 'S17' THEN
						RETURN 'Y';
					END IF;
					IF substr (diagcode1, 1, 3) >= 'S19' AND substr (diagcode1, 1, 3) <= 'S99' THEN
						RETURN 'Y';
					END IF;
					IF substr (diagcode1, 1, 3) IN (
						'T07',
						'T79'
					) THEN
						RETURN 'Y';
					END IF;
				END IF;
				IF substr (diagcode1, 7, 1) = 'B' THEN
					IF substr (diagcode1, 1, 3) IN (
						'S12',
						'S22',
						'S32',
						'S42',
						'S52',
						'S62',
						'S72',
						'S82',
						'S92'
					) THEN
						RETURN 'Y';
					END IF;
				END IF;
				IF substr (diagcode1, 7, 1) = 'C' THEN
					IF substr (diagcode1, 1, 3) IN (
						'S52',
						'S72',
						'S82'
					) THEN
						RETURN 'Y';
					END IF;
				END IF;
			END IF;
		END IF;
		IF ud IN (
			'DOWN',
			'PAR'
		) THEN
			IF diagcode1 IN (
				'K92.2',
				'K31.82',
				'K56.60',
				'K56.60',
				'K56.60',
				'K56.69',
				'K56.7',
				'K80.00',
				'K80.01',
				'K80.50',
				'K80.51',
				'K80.70',
				'K80.71',
				'K80.80',
				'K80.81',
				'K81.9',
				'K82.8',
				'K82.9',
				'K74.3',
				'K80.3',
				'K83.0',
				'K85',
				'J18.9',
				'J44',
				'K12.2',
				'L98.3',
				'R50.9',
				'N36',
				'N39',
				'N139',
				'R31',
				'N12',
				'N18.4',
				'N18.5',
				'K746.0',
				'K746.9',
				'K72.91'
			) THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K25.0' AND diagcode1 <= 'K25.2' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K26.0' AND diagcode1 <= 'K26.2' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K27.0' AND diagcode1 <= 'K27.2' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K80.11' AND diagcode1 <= 'K80.13' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K80.18' AND diagcode1 <= 'K80.21' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K80.30' AND diagcode1 <= 'K80.37' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K80.40' AND diagcode1 <= 'K80.47' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K80.60' AND diagcode1 <= 'K80.67' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K81.0' AND diagcode1 <= 'K81.2' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'K82.0' AND diagcode1 <= 'K82.4' THEN
				RETURN 'Y';
			END IF;
			IF substr (diagcode1, 1, 3) >= 'L02' AND substr (diagcode1, 1, 3) <= 'L03' THEN
				RETURN 'Y';
			END IF;
			IF diagcode1 >= 'I50.2' AND diagcode1 <= 'I50.9' THEN
				RETURN 'Y';
			END IF;
		END IF;
		RETURN 'N';
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line ('EMG_PRIZE_TRN_DIAGT ' || v_error_code || ',' || v_error_info || ':' || diagcode1);
			RETURN 'N';
	END emg_prize_trn_diagt;

    -- 設定 1060 算帳身分
	PROCEDURE set_1060_financial (
		i_ecaseno VARCHAR2
	) IS
		TYPE t_emgspeu_date_pair IS RECORD (
			sta_date   common.pat_emg_casen.emgspeu1_sta_date%TYPE,
			end_date   common.pat_emg_casen.emgspeu1_end_date%TYPE
		);
		emgspeu_date_pair    t_emgspeu_date_pair;
		TYPE t_emgspeu_date_pairs IS
			VARRAY (2) OF t_emgspeu_date_pair;
		emgspeu_date_pairs   t_emgspeu_date_pairs := t_emgspeu_date_pairs ();
	BEGIN
		FOR r_pat_emg_casen IN (
			SELECT
				*
			FROM
				common.pat_emg_casen
			WHERE
				ecaseno = i_ecaseno
				AND
				(emgspeu1 = '1060'
				 OR
				 emgspeu2 = '1060')
		) LOOP
			IF r_pat_emg_casen.emgspeu1 = '1060' THEN
				emgspeu_date_pair.sta_date   := r_pat_emg_casen.emgspeu1_sta_date;
				emgspeu_date_pair.end_date   := r_pat_emg_casen.emgspeu1_end_date;
				emgspeu_date_pairs.extend;
				emgspeu_date_pairs (1)       := emgspeu_date_pair;
			END IF;
			IF r_pat_emg_casen.emgspeu2 = '1060' THEN
				emgspeu_date_pair.sta_date   := r_pat_emg_casen.emgspeu2_sta_date;
				emgspeu_date_pair.end_date   := r_pat_emg_casen.emgspeu2_end_date;
				emgspeu_date_pairs.extend;
				emgspeu_date_pairs (2)       := emgspeu_date_pair;
			END IF;
			FOR idx IN 1..emgspeu_date_pairs.count LOOP INSERT INTO tmp_fincal VALUES (
				r_pat_emg_casen.ecaseno,
				'LABI',
				emgspeu_date_pairs (idx).sta_date,
				emgspeu_date_pairs (idx).end_date
			);
			END LOOP;
		END LOOP;
	END;

	-- 調整 1060 帳款分攤
	PROCEDURE adjust_1060_acnt_wk (
		i_ecaseno VARCHAR2
	) IS
	BEGIN
		-- 1060 特約生效期間須涵蓋整段急診期間
		FOR r_pat_emg_casen IN (
			SELECT
				*
			FROM
				common.pat_emg_casen
			WHERE
				ecaseno = i_ecaseno
				AND
				(emgspeu1 = '1060'
				 AND
				 trunc (emgdt) >= emgspeu1_sta_date
				 AND
				 trunc (emglvdt) <= emgspeu1_end_date
				 OR
				 emgspeu2 = '1060'
				 AND
				 trunc (emgdt) >= emgspeu2_sta_date
				 AND
				 trunc (emglvdt) <= emgspeu2_end_date)
		) LOOP 
			-- 掛號費調至 1060 分攤單位
			UPDATE emg_bil_acnt_wk
			SET
				pfincode = '1060',
				part_amt = self_amt,
				self_amt = 0
			WHERE
				caseno = r_pat_emg_casen.ecaseno
				AND
				fee_kind = '37'
				AND
				pfincode = 'CIVC';
		END LOOP;
	END;

    -- 重整費用明細檔
	PROCEDURE recalculate_feedtl (
		i_caseno VARCHAR2
	) IS
	BEGIN
		DELETE FROM emg_bil_feedtl
		WHERE
			caseno = i_caseno;
		FOR r IN (
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
				emg_bil_acnt_wk
			WHERE
				caseno = i_caseno
				AND
				(clerk <> 'NHIMOVE'
				 OR
				 clerk IS NULL)
			GROUP BY
				caseno,
				fee_kind,
				pfincode
		) LOOP INSERT INTO emg_bil_feedtl (
			caseno,
			fee_type,
			pfincode,
			total_amt,
			created_by,
			created_date,
			last_updated_by,
			last_update_date
		) VALUES (
			r.caseno,
			r.fee_kind,
			r.pfincode,
			r.total_amt,
			'biling',
			SYSDATE,
			'biling',
			SYSDATE
		);
		END LOOP;

		-- 重整部分負擔
		recalculate_copay (i_caseno);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
	END;

    -- 重整部分負擔
	PROCEDURE recalculate_copay (
		i_ecaseno VARCHAR2
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
		r_pat_emg_casen    common.pat_emg_casen%rowtype;
		r_pf_baserule      pf_baserule%rowtype;
		r_emg_bil_feedtl   emg_bil_feedtl%rowtype;
		l_copay_lmt        pf_baserule.emg_pay_lmt1%TYPE;
		l_triage_degree    common.pat_emg_triage.degree%TYPE;
		l_labi_amt         emg_bil_feedtl.total_amt%TYPE;
		l_copay_amt        emg_bil_feedtl.total_amt%TYPE;
		l_copay_fee_type   emg_bil_feedtl.fee_type%TYPE := '41';
		l_copay_disc_per   bil_discdtl.insu_per%TYPE;
		l_copay_disc_amt   bil_feedtl.total_amt%TYPE;
	BEGIN
		-- 取得急診主檔
		SELECT
			*
		INTO r_pat_emg_casen
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = i_ecaseno;

		-- 取得部分負擔規則
		OPEN c_pf_baserule ('E', r_pat_emg_casen.emgdt);
		FETCH c_pf_baserule INTO r_pf_baserule;
		CLOSE c_pf_baserule;

		-- 計算健保金額
		SELECT
			SUM (insu_amt * emg_per * qty)
		INTO l_labi_amt
		FROM
			emg_bil_acnt_wk
		WHERE
			pfincode = 'LABI'
			AND
			emg_calculate_pkg.f_getnhrangeflag (caseno, bildate, '2') = 'NHI0'
			AND
			caseno = r_pat_emg_casen.ecaseno
			AND
			(clerk <> 'NHIMOVE'
			 OR
			 clerk IS NULL);

        -- 計算部分負擔金額
		l_copay_amt   := l_labi_amt;

        -- 取得檢傷等級
		FOR r_pat_emg_triage IN (
			SELECT
				*
			FROM
				common.pat_emg_triage
			WHERE
				hcaseno = r_pat_emg_casen.ecaseno
			ORDER BY
				op_dtm DESC
		) LOOP
			l_triage_degree := r_pat_emg_triage.degree;

            -- 取最後異動一筆
			EXIT;
		END LOOP;

        -- 部分負擔上限
		l_copay_lmt   :=
			CASE
				WHEN l_triage_degree IN (
					'1',
					'2'
				) THEN
					r_pf_baserule.emg_pay_lmt3
				ELSE r_pf_baserule.emg_pay_lmt1
			END;
        -- 牙科部分負擔上限
		IF r_pat_emg_casen.emgcopay = 'E00' THEN
			l_copay_lmt := r_pf_baserule.emg_pay_lmt2;
		END IF;

        -- 超過上限以上限計
		IF l_copay_amt > l_copay_lmt THEN
			l_copay_amt := l_copay_lmt;
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
						caseno = r_pat_emg_casen.ecaseno
				)
			ORDER BY
				insu_per DESC
		) LOOP
			l_copay_disc_per   := r_bil_discdtl.insu_per;
			l_copay_disc_amt   := l_copay_amt * l_copay_disc_per;
			IF l_copay_disc_amt != 0 THEN
				r_emg_bil_feedtl                    := NULL;
				r_emg_bil_feedtl.caseno             := r_pat_emg_casen.ecaseno;
				r_emg_bil_feedtl.fee_type           := l_copay_fee_type;
				r_emg_bil_feedtl.pfincode           := r_bil_discdtl.bilkey;
				r_emg_bil_feedtl.total_amt          := round (l_copay_disc_amt);
				r_emg_bil_feedtl.created_by         := 'biling';
				r_emg_bil_feedtl.created_date       := SYSDATE;
				r_emg_bil_feedtl.last_updated_by    := 'biling';
				r_emg_bil_feedtl.last_update_date   := SYSDATE;
				INSERT INTO emg_bil_feedtl VALUES r_emg_bil_feedtl;
				l_copay_amt                         := l_copay_amt - l_copay_disc_amt;
			END IF;

            -- 只取最高折扣比例
			EXIT;
		END LOOP;

        -- 寫入部分負擔金額
		IF l_copay_amt != 0 THEN
			r_emg_bil_feedtl                    := NULL;
			r_emg_bil_feedtl.caseno             := r_pat_emg_casen.ecaseno;
			r_emg_bil_feedtl.fee_type           := l_copay_fee_type;
			r_emg_bil_feedtl.pfincode           := 'CIVC';
			r_emg_bil_feedtl.total_amt          := round (l_copay_amt);
			r_emg_bil_feedtl.created_by         := 'biling';
			r_emg_bil_feedtl.created_date       := SYSDATE;
			r_emg_bil_feedtl.last_updated_by    := 'biling';
			r_emg_bil_feedtl.last_update_date   := SYSDATE;
			INSERT INTO emg_bil_feedtl VALUES r_emg_bil_feedtl;
		END IF;

		-- 調整 1060 部分負擔
		adjust_1060_copay (r_pat_emg_casen.ecaseno);
	END;

	-- 調整 1060 部分負擔
	PROCEDURE adjust_1060_copay (
		i_ecaseno VARCHAR2
	) IS
	BEGIN
		-- 1060 特約生效期間須涵蓋整段急診期間
		FOR r_pat_emg_casen IN (
			SELECT
				*
			FROM
				common.pat_emg_casen
			WHERE
				ecaseno = i_ecaseno
				AND
				(emgspeu1 = '1060'
				 AND
				 trunc (emgdt) >= emgspeu1_sta_date
				 AND
				 trunc (emglvdt) <= emgspeu1_end_date
				 OR
				 emgspeu2 = '1060'
				 AND
				 trunc (emgdt) >= emgspeu2_sta_date
				 AND
				 trunc (emglvdt) <= emgspeu2_end_date)
		) LOOP 
			-- 部分負擔調至 1060 分攤單位
			UPDATE emg_bil_feedtl
			SET
				pfincode = '1060'
			WHERE
				caseno = r_pat_emg_casen.ecaseno
				AND
				fee_type = '41'
				AND
				pfincode = 'CIVC';
		END LOOP;
	END;

    -- 重整費用主檔
	PROCEDURE recalculate_feemst (
		i_ecaseno    VARCHAR2,
		i_end_date   DATE
	) IS
		r_pat_emg_casen       common.pat_emg_casen%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
		r_emg_bil_feemst      emg_bil_feemst%rowtype;
	BEGIN
        -- 取得急診主檔
		SELECT
			*
		INTO r_pat_emg_casen
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = i_ecaseno;

        -- 刪除費用主檔
		DELETE FROM emg_bil_feemst
		WHERE
			caseno = r_pat_emg_casen.ecaseno;

        -- 初始化費用主檔
		r_emg_bil_feemst.caseno             := r_pat_emg_casen.ecaseno;
		r_emg_bil_feemst.st_date            := trunc (r_pat_emg_casen.emgdt);
		r_emg_bil_feemst.end_date           :=
			CASE
				WHEN i_end_date > trunc (r_pat_emg_casen.emglvdt) THEN
					trunc (r_pat_emg_casen.emglvdt)
				ELSE trunc (i_end_date)
			END;
		r_emg_bil_feemst.emg_exp_amt1       := 0;
		r_emg_bil_feemst.emg_pay_amt1       := 0;
		r_emg_bil_feemst.emg_exp_amt2       := 0;
		r_emg_bil_feemst.emg_pay_amt2       := 0;
		r_emg_bil_feemst.emg_exp_amt3       := 0;
		r_emg_bil_feemst.emg_pay_amt3       := 0;
		r_emg_bil_feemst.created_by         := 'biling';
		r_emg_bil_feemst.created_date       := SYSDATE;
		r_emg_bil_feemst.last_updated_by    := r_emg_bil_feemst.created_by;
		r_emg_bil_feemst.last_update_date   := r_emg_bil_feemst.created_date;
        -- 急性床天數
		r_emg_bil_feemst.emg_bed_days       := trunc (r_emg_bil_feemst.end_date) - trunc (r_emg_bil_feemst.st_date);
		IF r_emg_bil_feemst.emg_bed_days = 0 THEN
			r_emg_bil_feemst.emg_bed_days := 1;
		END IF;
        -- 計算第一階段健保金額
		SELECT
			nvl (SUM (total_amt), 0)
		INTO
			r_emg_bil_feemst
		.emg_exp_amt1
		FROM
			emg_bil_feedtl
		WHERE
			caseno = r_emg_bil_feemst.caseno
			AND
			pfincode = 'LABI';

        -- 計算第一階段部分負擔
		SELECT
			nvl (SUM (total_amt), 0)
		INTO
			r_emg_bil_feemst
		.emg_pay_amt1
		FROM
			emg_bil_feedtl
		WHERE
			caseno = r_emg_bil_feemst.caseno
			AND
			fee_type = '41';

        -- 計算自付部分負擔
		SELECT
			nvl (SUM (total_amt), 0)
		INTO
			r_emg_bil_feemst
		.tot_self_amt
		FROM
			emg_bil_feedtl
		WHERE
			caseno = r_emg_bil_feemst.caseno
			AND
			fee_type = '41'
			AND
			pfincode = 'CIVC';

        -- 計算自付自費項目
		SELECT
			nvl (SUM (total_amt), 0)
		INTO
			r_emg_bil_feemst
		.tot_gl_amt
		FROM
			emg_bil_feedtl
		WHERE
			caseno = r_emg_bil_feemst.caseno
			AND
			fee_type != '41'
			AND
			pfincode = 'CIVC';

        -- 計算特約總額
		SELECT
			nvl (SUM (total_amt), 0)
		INTO
			r_emg_bil_feemst
		.credit_amt
		FROM
			emg_bil_feedtl
		WHERE
			caseno = r_emg_bil_feemst.caseno
			AND
			pfincode NOT IN (
				'LABI',
				'CIVC'
			);

        -- 寫入費用主檔
		INSERT INTO emg_bil_feemst VALUES r_emg_bil_feemst;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'recalculate_feemst';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_ecaseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
	END;

	-- 搬急診帳至住院帳（依計價日期）
	PROCEDURE mer_fee_fro_emg_to_adm (
		i_ecaseno          VARCHAR2,
		i_hcaseno          VARCHAR2,
		i_sta_emocdate     DATE,
		i_end_emocdate     DATE,
		i_is_charge_flag   VARCHAR2 DEFAULT 'N',
		o_msg              OUT VARCHAR2
	) IS
		CURSOR c_emg_occur (
			p_caseno              VARCHAR2,
			p_emocdate_sta_date   DATE,
			p_emocdate_end_date   DATE
		) IS
		SELECT
			*
		FROM
			cpoe.emg_occur
		WHERE
			caseno = p_caseno
			AND
			trunc (emocdate) BETWEEN p_emocdate_sta_date AND p_emocdate_end_date;
		r_pat_adm_case        common.pat_adm_case%rowtype;
		r_bil_root            bil_root%rowtype;
		r_pat_emg_casen       common.pat_emg_casen%rowtype;
		r_emg_occur           cpoe.emg_occur%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
		l_cnt                 INTEGER := 0;
	BEGIN
		-- 取出住院主檔
		SELECT
			*
		INTO r_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = i_hcaseno;

		-- 取出住院帳務主檔
		SELECT
			*
		INTO r_bil_root
		FROM
			bil_root
		WHERE
			caseno = r_pat_adm_case.hcaseno;

		-- 取得急診主檔
		SELECT
			*
		INTO r_pat_emg_casen
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = i_ecaseno;

		-- 檢查是否已搬帳
		OPEN c_emg_occur (r_pat_emg_casen.ecaseno, i_sta_emocdate, i_end_emocdate);
		LOOP
			FETCH c_emg_occur INTO r_emg_occur;
			EXIT WHEN c_emg_occur%notfound;
			IF r_emg_occur.emuserid = 'NHIMOVE' THEN
				o_msg := '急診序號：' || r_emg_occur.caseno || '，計價日期：' || r_emg_occur.emocdate || '，已執行過搬帳';
				return;
			END IF;
		END LOOP;
		CLOSE c_emg_occur;

		-- 搬帳
		OPEN c_emg_occur (r_pat_emg_casen.ecaseno, i_sta_emocdate, i_end_emocdate);
		LOOP
			FETCH c_emg_occur INTO r_emg_occur;
			EXIT WHEN c_emg_occur%notfound;
			IF 
			-- emapply != 'N'
			 (r_emg_occur.emapply != 'N' OR r_emg_occur.emapply IS NULL) 
			-- 非 PR
			 AND (r_emg_occur.emchanes != 'PR' OR r_emg_occur.emchanes IS NULL 
				-- 特材費無論是否 PR 全搬
			 OR r_emg_occur.emchtyp1 = '14') 
			-- 非病房費、醫師費、藥師費、護理費
			 AND trim (r_emg_occur.ordseq) != '0000' THEN
				l_cnt                  := l_cnt + 1;

				-- 入住院帳
				order_bill ('A', -- 就診別 (A/E)
				 r_pat_adm_case.hcaseno, -- 就診序號
				 r_emg_occur.emocdate, -- 計價日
				 r_emg_occur.ordseq, -- 醫囑序號
					CASE
						WHEN trunc (SYSDATE, 'MI') > r_bil_root.dischg_date THEN
							'Y'
						ELSE 'N'
					END, -- 離院補帳註記 (Y/N)
					 r_emg_occur.emchcode, -- 計價碼
					 r_emg_occur.emchrgcr, -- 正負號 (+/-)
					 r_emg_occur.emchtyp1, -- 費用類別
					 TO_CHAR (r_emg_occur.emchqty1), -- 數量
					 TO_CHAR (r_emg_occur.emchamt1), -- 總金額
					 r_emg_occur.emchemg, -- 急作加成 (E/R)
					CASE i_is_charge_flag
						WHEN 'N' THEN
							'DR'
						ELSE r_emg_occur.emchanes
					END, -- 強制自費或只申報不計價註記 (PR/DR)
					 NULL, -- IV PUMP(Y/N)
					 r_emg_occur.emchidep, -- 強制收入歸屬科
					 r_emg_occur.emrescod, -- 退帳理由
					 r_emg_occur.emchstat, -- 消耗地點
					 r_emg_occur.caseno, -- 入帳者卡號 (搬帳用急診序號作入帳者卡號)
					 r_emg_occur.emorcat, -- OR catalog
					 r_emg_occur.emorcomp, -- 因併發症產生的帳 (Y/N)
					 r_emg_occur.emororno, -- 手術第幾刀
					 NULL, -- discharge bring back (Y/N)
					 r_emg_occur.emocomb, -- 組合項 (Y/N)
					 r_emg_occur.emocdist, -- 拆帳比例
					 r_emg_occur.emocsect, -- 計價科別
					 r_emg_occur.emocns, -- 護理站
					 r_emg_occur.emoedept, -- 開立科別 
					 o_msg, -- 輸出訊息
					 'N' -- 自動 commit (Y/N)
					);

				-- 沖急診帳
				r_emg_occur.emblpk     := r_emg_occur.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (l_cnt, 100);
				r_emg_occur.embldate   := SYSDATE;
				r_emg_occur.emchrgcr   :=
					CASE r_emg_occur.emchrgcr
						WHEN '+' THEN
							'-'
						WHEN '-' THEN
							'+'
					END;
				r_emg_occur.emuserid   :=
					CASE i_is_charge_flag
						WHEN 'N' THEN
							'NHIMOVE'
						ELSE r_emg_occur.emuserid
					END;
				INSERT INTO cpoe.emg_occur VALUES r_emg_occur;
			END IF;
		END LOOP;
		CLOSE c_emg_occur;
		COMMIT;
		o_msg := '0';
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'mer_fee_fro_emg_to_adm';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_ecaseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
			o_msg                            := r_biling_spl_errlog.err_info;
	END;

	-- 搬急診帳至住院帳（依醫囑序號）
	PROCEDURE mer_fee_fro_emg_to_adm (
		i_aordseq   IN    VARCHAR2,
		i_eordseq   IN    VARCHAR2,
		o_msg       OUT   VARCHAR2
	) IS
		CURSOR c_emg_occur (
			p_caseno   VARCHAR2,
			p_ordseq   VARCHAR2
		) IS
		SELECT
			*
		FROM
			cpoe.emg_occur
		WHERE
			caseno = p_caseno
			AND
			ordseq = p_ordseq;
		r_pat_adm_case        common.pat_adm_case%rowtype;
		r_bil_root            bil_root%rowtype;
		r_pat_emg_casen       common.pat_emg_casen%rowtype;
		r_emg_occur           cpoe.emg_occur%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
		l_cnt                 INTEGER := 0;
	BEGIN
		-- 取出住院主檔
		SELECT
			*
		INTO r_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = substr (i_aordseq, 2, 8);

		-- 取出住院帳務主檔
		SELECT
			*
		INTO r_bil_root
		FROM
			bil_root
		WHERE
			caseno = r_pat_adm_case.hcaseno;

		-- 取得急診主檔
		SELECT
			*
		INTO r_pat_emg_casen
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = substr (i_eordseq, 2, 8);
		OPEN c_emg_occur (r_pat_emg_casen.ecaseno, i_eordseq);
		LOOP
			FETCH c_emg_occur INTO r_emg_occur;
			EXIT WHEN c_emg_occur%notfound;
			l_cnt                  := l_cnt + 1;

			-- 入住院帳
			order_bill ('A', -- 就診別 (A/E)
			 r_pat_adm_case.hcaseno, -- 就診序號
			 r_emg_occur.emocdate, -- 計價日
			 i_aordseq, -- 醫囑序號
				CASE
					WHEN trunc (SYSDATE, 'MI') > r_bil_root.dischg_date THEN
						'Y'
					ELSE 'N'
				END, -- 離院補帳註記 (Y/N)
				 r_emg_occur.emchcode, -- 計價碼
				 r_emg_occur.emchrgcr, -- 正負號 (+/-)
				 r_emg_occur.emchtyp1, -- 費用類別
				 TO_CHAR (r_emg_occur.emchqty1), -- 數量
				 TO_CHAR (r_emg_occur.emchamt1), -- 總金額
				 r_emg_occur.emchemg, -- 急作加成 (E/R)
				 r_emg_occur.emchanes, -- 強制自費或只申報不計價註記 (PR/DR)
				 NULL, -- IV PUMP(Y/N)
				 r_emg_occur.emchidep, -- 強制收入歸屬科
				 r_emg_occur.emrescod, -- 退帳理由
				 r_emg_occur.emchstat, -- 消耗地點
				 r_emg_occur.emuserid, -- 入帳者卡號
				 r_emg_occur.emorcat, -- OR catalog
				 r_emg_occur.emorcomp, -- 因併發症產生的帳 (Y/N)
				 r_emg_occur.emororno, -- 手術第幾刀
				 NULL, -- discharge bring back (Y/N)
				 r_emg_occur.emocomb, -- 組合項 (Y/N)
				 r_emg_occur.emocdist, -- 拆帳比例
				 r_emg_occur.emocsect, -- 計價科別
				 r_pat_adm_case.hnursta, -- 護理站
				 NULL, -- 開立科別 
				 o_msg, -- 輸出訊息
				 'N' -- 自動 commit (Y/N)
				);

			-- 沖急診帳
			-- r_emg_occur.emblpk     := r_emg_occur.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (l_cnt, 100);
			r_emg_occur.emblpk     := 'M' || substr (r_emg_occur.emblpk, 2);
			r_emg_occur.embldate   := SYSDATE;
			r_emg_occur.emchrgcr   :=
				CASE r_emg_occur.emchrgcr
					WHEN '+' THEN
						'-'
					WHEN '-' THEN
						'+'
				END;
			INSERT INTO cpoe.emg_occur VALUES r_emg_occur;
		END LOOP;
		CLOSE c_emg_occur;
		COMMIT;
		o_msg := '0';
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'mer_fee_fro_emg_to_adm';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := substr (i_eordseq, 2, 8);
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
			o_msg                            := r_biling_spl_errlog.err_info;
	END;

	-- （待刪除）搬急診帳至住院帳（依醫囑序號）
	PROCEDURE emg_ord2adm_ord_bil (
		aordseq   VARCHAR2,
		eordseq   VARCHAR2
	) IS
		CURSOR get_emg_occur (
			vcaseno   VARCHAR2,
			vordseq   VARCHAR2
		) IS
		SELECT
			*
		FROM
			cpoe.emg_occur
		WHERE
			caseno = vcaseno
			AND
			ordseq = vordseq;
		v_error_code   VARCHAR2 (20);
		v_error_info   VARCHAR2 (600);
		v_seq          NUMBER;
		phcaseno       VARCHAR2 (08);
		pecaseno       VARCHAR2 (08);
		pmessage       VARCHAR2 (200);
		emgoccrec      cpoe.emg_occur%rowtype;
		patadmcase     common.pat_adm_case%rowtype;
	BEGIN
		phcaseno   := substr (aordseq, 2, 8);
		pecaseno   := substr (eordseq, 2, 8);
		SELECT
			*
		INTO patadmcase
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = phcaseno;
    --入住院帳
		OPEN get_emg_occur (pecaseno, eordseq);
		LOOP
			FETCH get_emg_occur INTO emgoccrec;
			EXIT WHEN get_emg_occur%notfound;
      --入住院帳務
      --非PR才入帳(FOR NHI)
			order_bill ('A',                    --住院(A)急診(E)
			 phcaseno,                --住院號或是急診號
			 emgoccrec.emocdate,     --計價日,DATE TIME
			 aordseq,       --醫囑序號(FULL COMON_ORDER KEY 15 BYTES)
			 'N',                    --離院後入帳(Y/N)
			 emgoccrec.emchcode,     --計價碼
			 emgoccrec.emchrgcr,     --加退帳(+/-)
			 emgoccrec.emchtyp1,     --計價類別(01-40)
			 lpad (TO_CHAR (emgoccrec.emchqty1), 4, '0'), --數量(4BYTES)
			 TO_CHAR (emgoccrec.emchamt1),             --總金額(7.1)
			 emgoccrec.emchemg,                       --是否急作(E急作/R非急作)
			 emgoccrec.emchanes,--'DR',         --麻醉方式(如LA)/自購註記(PR)(2 BYTES) DR IS NHI ONLY
			 '',           --IV PUMP(Y/N)
			 emgoccrec.emchidep, --強制收入歸屬科(4 BYTES)
			 emgoccrec.emrescod, --退帳理由LCOMMENT KEY(6 BYTES)
			 emgoccrec.emchstat, --消耗地點(4 BYTES)
			 emgoccrec.emuserid, --入帳者(需轉換成ID卡號)(8 BYTES)
			 emgoccrec.emorcat,  --OR. ORDER CATALOG(1/2/3/4/5)(1 BYTE)
			 emgoccrec.emorcomp, --是否因併發症所產生的帳(Y/N)(1 BYTE)
			 emgoccrec.emororno, --手術第幾刀(1 BYTE)
			 '',           --DISCHARGE BRING BACK(Y/NULL)(1 BYTE)
			 emgoccrec.emocomb,  --是組合項(Y/N)(1 BYTE)
			 emgoccrec.emocdist, --拆帳比率(4 BYTES)
			 emgoccrec.emocsect, --計價科別(4 BYTES)
			 patadmcase.hnursta, --EMGOCCREC.EMOCNS,   --病房(4 BYTES)
			 '',           --開立科別(4 BYTES, EMG ONLY)
			 pmessage      --RETURN MESSAGE,(0 IS OK ELSE ERROR)
			);
		END LOOP;
		CLOSE get_emg_occur;
		COMMIT WORK;
    --入負帳
		emg_minus_occ (pecaseno, eordseq);
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line ('EMG_ORD2ADM_ORD_BIL:' || v_error_code || ',' || v_error_info || ',A:' || aordseq || ',E:' || eordseq);
			ROLLBACK WORK;
	END;

	-- （待刪除）emg_ord2adm_ord_bil 沖帳用
	PROCEDURE emg_minus_occ (
		ecaseno   VARCHAR2,
		pordseq   VARCHAR2
	) IS
		CURSOR get_emgocc (
			vordseq VARCHAR2
		) IS
		SELECT
			*
		FROM
			cpoe.emg_occur
		WHERE
			caseno = ecaseno
			AND
			ordseq = vordseq;
		v_error_code   VARCHAR2 (20);
		v_error_info   VARCHAR2 (600);
		v_seq          NUMBER;
		emgoccrec      cpoe.emg_occur%rowtype;
		bilsplrec      bil_spl_errlog%rowtype;
	BEGIN
		v_seq := 0;
		OPEN get_emgocc (pordseq);
		LOOP
			FETCH get_emgocc INTO emgoccrec;
			EXIT WHEN get_emgocc%notfound;
			IF emgoccrec.emchrgcr = '-' THEN
				emgoccrec.emchrgcr := '+';
			ELSE
				emgoccrec.emchrgcr := '-';
			END IF;
      --EMBLPK修改
			v_seq                := v_seq + 1;
      --EMGOCCREC.EMBLPK:='D' || ECASENO || SUBSTR(TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISSFF'),1,13) || MOD(V_SEQ, 1000);
			emgoccrec.emblpk     := 'M' || substr (emgoccrec.emblpk, 2, length (emgoccrec.emblpk) - 1);
			emgoccrec.embldate   := SYSDATE;
      --USER 改為申報NHIMOVE
      --EMGOCCREC.EMUSERID:='NHIMOVE';
      --DBMS_OUTPUT.PUT_LINE(EMGOCCREC.EMBLPK||':'||EMGOCCREC.EMCHCODE||','||V_SEQ);
			INSERT INTO cpoe.emg_occur VALUES emgoccrec;
		END LOOP;
		CLOSE get_emgocc;
		COMMIT WORK;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code           := sqlcode;
			v_error_info           := sqlerrm;
      --ERROR LOG TO BIL_SPL_ERRLOG
			dbms_output.put_line ('EMG_MINUS_OCC:' || v_error_code || ',' || v_error_info || ':' || ecaseno);
			ROLLBACK WORK;
			bilsplrec.session_id   := userenv ('SESSIONID');
			bilsplrec.prog_name    := 'EMG_MINUS_OCC';
			bilsplrec.sys_date     := SYSDATE;
			bilsplrec.err_code     := v_error_code;
			bilsplrec.err_msg      := v_error_info;
			bilsplrec.source_seq   := pordseq;
			INSERT INTO bil_spl_errlog VALUES bilsplrec;
			COMMIT WORK;
	END;
END;
/
