CREATE OR REPLACE PACKAGE "EMG_CALCULATE_PKG" IS
  --created by Kuo 981029 for EMG Billing
  --main billing caculate package
  --�˶ˤ����ܼ� for �s�����t�� by kuo 20170216
	triage VARCHAR2 (1);
  --��E���u�D�n�{��
	PROCEDURE main_process (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2
	);

  --��E�p��T�w�O��
	PROCEDURE emgfixfees (
		pcaseno VARCHAR2
	);

  --��E�M���p��{��
	PROCEDURE initdata (
		pcaseno VARCHAR2
	);

  --��E�i�}�����O�ܨ����Ȧs��
	PROCEDURE extandfin (
		pcaseno VARCHAR2
	);

  --��E�p����O����
	PROCEDURE acntwkcalculate (
		pcaseno VARCHAR2
	);

  --��E��z�b��
	PROCEDURE compacntwk (
		pcaseno   VARCHAR2,
		poper     VARCHAR2
	);

  --��E�p�⭼��
	PROCEDURE getemgper (
		pcaseno          VARCHAR2, --��|��
		ppfkey           VARCHAR2, --�p���X
		pfeekind         VARCHAR2, --�b�ɭp�����O
		pemgflag         VARCHAR2, --��@�_
		pfncl            VARCHAR2, --�����O
		ptype            VARCHAR2, --�^�Ǧ���
		pdate            DATE, --�p����
		emg_per          OUT   NUMBER, --�[����
		holiday_per      OUT   NUMBER, --����[������
		night_per        OUT   NUMBER, --�]���[������
		child_per        OUT   NUMBER, --�ൣ�[������
		urgent_per       OUT   NUMBER, --��@�[������
		operation_per    OUT   NUMBER, --��N�[������
		anesthesia_per   OUT   NUMBER, --�¾K�[������
		materials_per    OUT   NUMBER --���ƥ[������
	);
  --RETURN NUMBER;

  --��E�վ������b��
	PROCEDURE p_receivablecomp (
		pcaseno VARCHAR2
	);

  --��E�u�ݨ����O�B�z
	PROCEDURE p_disfin (
		pcaseno    VARCHAR2,
		pfinacl    VARCHAR2,
		pdiscfin   OUT VARCHAR2
	);

  --��E���O�W�h�վ�
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

  --�ۥI�]������(�a��),�S���վ�
	PROCEDURE p_modifityselfpay (
		pcaseno      VARCHAR2,
		pfinacl      VARCHAR2,
		v_acnt_seq   INT
	);

  --���o��騭���O
	FUNCTION f_getnhrangeflag (
		pcaseno    VARCHAR2,
		pdate      DATE,
		pfinflag   VARCHAR2
	) RETURN VARCHAR2;

  -- �NHIS�W�b�ڥ�IMSDB ��J
	PROCEDURE emgoccurfromimsdb (
		pcaseno VARCHAR2
	);

  --need add�Ҷq�X�ֶ��D���A��X�ֶ����Ӷ����w���ζO�����O�v�@�s�W�Jemg_occur�A�A�N�X�ֶ��D���R��
	PROCEDURE p_emgoccurbycase (
		pcaseno VARCHAR2
	);

  --�զX���S��W�hcehck
	FUNCTION special_code_check (
		ppfkey VARCHAR2
	) RETURN VARCHAR2;

  --�����O�J�b
	PROCEDURE emgregfee (
		pcaseno VARCHAR2
	);

  --�w���b       
	PROCEDURE poverdueorder (
		pcaseno VARCHAR2
	);

  --��E�C��b�ڭ���(�]���妬�ݨC�鵲��,�ݨC��N���o�ͱb�ڪ�CASENO����)      
	PROCEDURE daily_process;

  --emg_occur�ƥ�
	PROCEDURE bkoccur (
		pcaseno VARCHAR2
	);

  --��s����� - ����b�ګ�O�_�w�L��کάO��ڪ��B������ 
	PROCEDURE p_debt_check (
		pcaseno VARCHAR2
	);

  --���o����E����seq_no
	FUNCTION f_get_seq_no (
		pcaseno VARCHAR2
	) RETURN VARCHAR2;

  --�l�ܹw������
	PROCEDURE t_ovrordlog (
		pcaseno VARCHAR2
	);
  --�b�ȥ���(�ۥI��0)�����[�J EMG_BIL_ACNT_WK BY KUO 1000601
	PROCEDURE zero_emg_acnkwk (
		pcaseno VARCHAR2
	);

  --��E�ӳ��e���� BY KUO 1000628
	PROCEDURE emg_recalmon (
		pmonth VARCHAR2
	);

  --��E���u�D�n�{��--�j��H���O�p�� BY KUO 1000808
	PROCEDURE main_process_labi (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2
	);

  --��������p��ΡA���½�s BY KUO 20121108
	PROCEDURE contract_es999 (
		pcaseno VARCHAR2
	);

  --��E���y�� by kuo 20160405
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

    -- �]�w 1060 ��b����
	PROCEDURE set_1060_financial (
		i_ecaseno VARCHAR2
	);

	-- �վ� 1060 �b�ڤ��u
	PROCEDURE adjust_1060_acnt_wk (
		i_ecaseno VARCHAR2
	);

    -- ����O�Ω�����
	PROCEDURE recalculate_feedtl (
		i_caseno VARCHAR2
	);

    -- ���㳡���t��
	PROCEDURE recalculate_copay (
		i_ecaseno VARCHAR2
	);

	-- �վ� 1060 �����t��
	PROCEDURE adjust_1060_copay (
		i_ecaseno VARCHAR2
	);

	-- ����O�ΥD��
	PROCEDURE recalculate_feemst (
		i_ecaseno    VARCHAR2,
		i_end_date   DATE
	);

	-- �h��E�b�ܦ�|�b�]�̭p������^
	PROCEDURE mer_fee_fro_emg_to_adm (
		i_ecaseno          VARCHAR2,
		i_hcaseno          VARCHAR2,
		i_sta_emocdate     DATE,
		i_end_emocdate     DATE,
		i_is_charge_flag   VARCHAR2 DEFAULT 'N',
		o_msg              OUT VARCHAR2
	);

	-- �h��E�b�ܦ�|�b�]������Ǹ��^
	PROCEDURE mer_fee_fro_emg_to_adm (
		i_aordseq   IN    VARCHAR2,
		i_eordseq   IN    VARCHAR2,
		o_msg       OUT   VARCHAR2
	);

	-- �]�ݧR���^�h��E�b�ܦ�|�b�]������Ǹ��^
	PROCEDURE emg_ord2adm_ord_bil (
		aordseq   VARCHAR2,
		eordseq   VARCHAR2
	);

	-- �]�ݧR���^emg_ord2adm_ord_bil �R�b��
	PROCEDURE emg_minus_occ (
		ecaseno   VARCHAR2,
		pordseq   VARCHAR2
	);
END;

/


CREATE OR REPLACE PACKAGE BODY "EMG_CALCULATE_PKG" IS

  --��E�b�ڭp��D�{���q
  --by Kuo 981014 Started
  --SOURCE: EMGOCCUR, PAT_EMG_CASEN(FOR CONTRACT), EMGADJST_MST, EMGADJST_DTL
  --TEMP  : TMP_FINCAL  �����Ȧs��
  --OUTPUT: EMG_BIL_ACNT_WK ���u�Ӷ�
  --        EMG_BIL_FEE_MST ���u�`�M
  --        EMG_BIL_FEE_DTL ���u�����P��������
  --        EMG_BIL_BILLMST �b��/���O�D��
  --        EMG_BIL_BILLDTL �b��/���O����
  --        BIL_DEBITREC��ڨϦ�|�ۦP
  --7(���O),9(����),E(��¾�a),1(�L¾�a)
  --��E�����@�Ө����쩳�A�L���q���D
  --�a���O�_�ݭn�P�_:common.vtandept
	PROCEDURE main_process (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2
	) IS
    --�ܼƫŧi��

    --���~�T���γ~
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
    --�W�[HIS��ڤ����⪺�P�_(add by amber 20110401)
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
				pmessageout   := '�eHIS���b ����';
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
    --�eHIS���b����<20110215
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
			pmessageout   := '�eHIS���b<20110215 ����';
		END IF;
    --000000000A ����
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
			pmessageout   := '000000000A ����';
		END IF;*/
    --�䤣�줣�� by kuo 20140915
		SELECT
			COUNT (*)
		INTO v_count
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;
		IF v_count = 0 THEN
			recalculate := 'N';
       --PMESSAGEOUT := '�L��CASE:'||PCASENO;
		END IF;
		IF recalculate = 'Y' THEN

      --�]�w�{���W�٤�session_id
			v_program_name   := 'emg_calculate_PKG.main_process';
			v_session_id     := userenv ('SESSIONID');
			v_source_seq     := trim (pcaseno);

      --�b����e���N��caseno��emg_occur�ƥ�
      --dbms_output.put_line('bkOccur');
			bkoccur (trim (pcaseno));

      --check if case not exist, return

      --�R���즳�p����
      --dbms_output.put_line('initdata');
			initdata (trim (pcaseno));

      --�i�}�����O
      --dbms_output.put_line('extanfin');
			extandfin (trim (pcaseno));

      --�J�T�w�O�Ψ�emg_occur
      --dbms_output.put_line('EMGFixFees');
			emgfixfees (trim (pcaseno));

      --�w���J��
      --dbms_output.put_line('pOverDueOrder');
			poverdueorder (trim (pcaseno));

      --�qIMSDB ��JHIS�W�b��
      --dbms_output.put_line('emgOccurFromImsdb');
			emgoccurfromimsdb (trim (pcaseno));

      --need add�Ҷq�X�ֶ��D���A��X�ֶ����Ӷ����w���ζO�����O�v�@�s�W�Jemg_occur�A�A�N�X�ֶ��D���R��
      --dbms_output.put_line('p_emgOccurByCase');
			p_emgoccurbycase (pcaseno => TRIM (pcaseno));

      		-- �p��p�����ة�����
			compacntwk (trim (pcaseno), poper);
			contract_es999 (pcaseno);

			-- ����O�Ω����� 
			recalculate_feedtl (pcaseno);

			-- �����b�ڽվ�
			p_receivablecomp (pcaseno => TRIM (pcaseno));

			-- ����O�ΥD��
			recalculate_feemst (pcaseno, SYSDATE);

      --�R�� EMG_OCCUR�O�w���J�b
      --�Nemg_occur�w����ƧR��
			DELETE cpoe.emg_occur
			WHERE
				caseno = TRIM (pcaseno)
				AND
				emuserid = 'OVRORDER';

      --��s����� - ����b�ګ�O�_�w�L��کάO��ڪ��B������(add by amber 20110420)   
			p_debt_check (pcaseno => TRIM (pcaseno));
			COMMIT WORK;
      --�w������l��
      --T_OVRORDLOG(pCaseNo);
      --�[�J�ۥI��0���O��FOR �妬
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

  --�i�}�T�w�O�Ϊ��p��
  --1151 -- �x����ĵ��s�� �����u��� 400�A�Ҧ��T�w�O�Ψ��� by kuo 20160201�A�ثe������������ ...
  --1151 -- 20160101 �}�l�אּ�N 90578604 �L�׭��ت��p����� 1151 by kuo 20161227
  --1152 -- ���ƿ��F��ĵ��s�� �̹�ڪ��p�p��A�ݺⱾ���O by kuo 20160201
  --1152 ��� 1151 by kuo 20161227
  --1193 ��� 1151 by kuo 20170517
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
    --��pfmlog
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
		v_degree          VARCHAR2 (01); --�˶˵���
		v_pfkey           VARCHAR2 (12);
		v_udcount         INTEGER; -- ���� count
		v_ct_udcount      INTEGER; -- CT ���� count
		v_tpn_udcount     INTEGER; -- TPN ���� count
		ffix              VARCHAR2 (01);
		l_fward_pfkey     cpoe.dbpfile.pfkey%TYPE; --�Ĥ@�ѯf�жO�p���X�n�J WARDER1�A�䥦�ѤJ WARDER
		l_fnurs_pfkey     cpoe.dbpfile.pfkey%TYPE; --�Ĥ@���@�z�O�p���X�n�J NURSER1�A�䥦�ѤJ NURSER

    --���~�T���γ~
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
    --�]�w�{���W�٤�session_id
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

    --�R�������T�w�O�ΡA�t�����O�B�Įv�O
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

    --Add ��������A�ȶO by kuo 20150721 for S995   
		IF patemgcaserec.emgspeu1 IN (
			'S999',
			'S995'
		) THEN
			DELETE FROM cpoe.emg_occur
			WHERE
				caseno = pcaseno
				AND
				emchcode = '91711115'; --91711115, ���O18
		END IF;
		COMMIT WORK;

    --1151 -- �x����ĵ��s�� �����u��� 400�A�Ҧ��T�w�O�Ψ��� by kuo 20160128�A�ثe������������ ...
    --1151,1152 -- �J��ɭY�O�����u��J�S��E��O(DIAGALOC),���E�����O 00000002,90578604,�������1151
    --1193 ��� 1151 by kuo 20170517
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
       --EmgOccRec.EMCHIDEP := patemgcaseRec.EMGNS; --�j��J�k�ݬ�(4 BYTES)
			emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --�j��J�k�ݬ�(4 BYTES)
			emgoccrec.emchstat   := patemgcaserec.emgns; --���Ӧa�I(4 BYTES)
			emgoccrec.card_no    := 'BILLING';
			emgoccrec.emocomb    := 'N';
       --EmgOccRec.EMOCSECT := patemgcaseRec.EMGNS; --�p����O(4 BYTES)
			emgoccrec.emocsect   := patemgcaserec.emgsect; --�p����O(4 BYTES)
			emgoccrec.emocns     := patemgcaserec.emgns; --�f��(4 BYTES)
			emgoccrec.emoedept   := patemgcaserec.emgns; --�}�߬�O(4 BYTES, EMG ONLY)
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
      --�J�T�w�O��
			EXIT WHEN v_date > v_enddate;
			BEGIN
        --����[��
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
      --�J�f�жO�P�@�z�O,��X����i
      --�J�|�W�L8�p�ɤ~��f�жO���@�z�O
      --�X�|��j��J�|��
			IF v_date <> trunc (patemgcaserec.emglvdt) AND (patemgcaserec.emglvdt - patemgcaserec.emgdt) * 24 >= 6 AND trunc (patemgcaserec
			.emglvdt) > trunc (patemgcaserec.emgdt) THEN
				ffix := 'Y';
				IF patemgcaserec.emgdt > TO_DATE ('20171001', 'YYYYMMDD') THEN --�f�лP�@�z�O�Ĥ@�ѥ� by kuo 20171002
					v_day := v_day + 1;
				END IF;
			END IF;
      --�B�X�|�鵥��J�|��B�W�L8�p��-->���ӬO6�p��
			IF v_date = trunc (patemgcaserec.emgdt) AND (patemgcaserec.emglvdt - patemgcaserec.emgdt) * 24 >= 6 AND trunc (patemgcaserec.emglvdt
			) = trunc (patemgcaserec.emgdt) THEN
				ffix := 'Y';
				IF patemgcaserec.emgdt > TO_DATE ('20171001', 'YYYYMMDD') THEN --�f�лP�@�z�O�Ĥ@�ѥ� by kuo 20171002
					v_day := v_day + 1;
				END IF;
			END IF;
			IF ffix = 'Y' THEN   
				--20200423 �Y��n�J WARDER1 �P NURSER1
				l_fward_pfkey   := 'WARDER';
				l_fnurs_pfkey   := 'NURSER';
				IF patemgcaserec.emgdt >= TO_DATE ('20171001', 'YYYYMMDD') AND v_day = 1 THEN --�Ĥ@�Ѩϥγo���
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
					emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --�j��J�k�ݬ�(4 BYTES)
					emgoccrec.emchstat   := patemgcaserec.emgns; --���Ӧa�I(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emocsect   := patemgcaserec.emgsect; --�p����O(4 BYTES)
					emgoccrec.emocns     := patemgcaserec.emgns; --�f��(4 BYTES)
					emgoccrec.emoedept   := patemgcaserec.emgsect; --�}�߬�O(4 BYTES, EMG ONLY)
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
					emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --�j��J�k�ݬ�(4 BYTES)
					emgoccrec.emchstat   := patemgcaserec.emgns; --���Ӧa�I(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emocsect   := patemgcaserec.emgsect; --�p����O(4 BYTES)
					emgoccrec.emocns     := patemgcaserec.emgns; --�f��(4 BYTES)
					emgoccrec.emoedept   := patemgcaserec.emgsect; --�}�߬�O(4 BYTES, EMG ONLY)
					emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert NURSER to date:'||v_date);
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				END IF;
			END IF; --END v_date <> trunc(patemgcaseRec.EMGDT)

      --�J�E��O��i�S��X
      --EMGOPDPT='Y'--���E����,EMGREGFG='Y' --�Ȧ������O
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
        --�������S999 BY KUO 20121128
        --�������S995 BY KUO 20150721
				IF patemgcaserec.emgspeu1 IN (
					'S999',
					'S995'
				) THEN
					v_pfkey := 'DIAGINT0';
				END IF;
        --¾�˥���˶ˤ������Ŧ��O
        --¾�˩�20140101�^�k���`�E��O�P�[�� by kuo 20140220,���ӽг�A�Ӳ���, update by kuo 20140225
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

        --��E�]���ΨҰ���,��w����[������COMPUWAT GETEMGPER���갵,�o�̥u��¶i�p��
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
          --¾�˥���˶ˤ�����X
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

        --�E��O�ĤG�ѥH�� $200�p��A�J�|�W�L 20�p�ɤ~��
				IF v_date <> trunc (patemgcaserec.emgdt) THEN
					IF (patemgcaserec.emglvdt - patemgcaserec.emgdt) * 24 >= 24 THEN
						v_pfkey := 'DIAGER@@';
            --�������S999 BY KUO 20121128
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
					emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --�j��J�k�ݬ�(4 BYTES)
					emgoccrec.emchstat   := patemgcaserec.emgns; --���Ӧa�I(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emocsect   := patemgcaserec.emgsect; --�p����O(4 BYTES)
					emgoccrec.emocns     := patemgcaserec.emgns; --�f��(4 BYTES)
					emgoccrec.emoedept   := patemgcaserec.emgsect; --�}�߬�O(4 BYTES, EMG ONLY)
					emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert '||v_pfkey||' to date:'||v_date);
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				END IF; --IF v_pfkey IS NOT NULL
			END IF; --IF patemgcaseRec.EMGOPDPT <> 'Y' AND...�E��O

      --�J�Įv�O
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
					emgoccrec.emchidep   := '';--'PHAR'; --�j��J�k�ݬ�(4 BYTES)
					emgoccrec.emchstat   := 'PHAR'; --���Ӧa�I(4 BYTES)
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
					emgoccrec.emchidep   := '';--'PHAR'; --�j��J�k�ݬ�(4 BYTES)
					emgoccrec.emchstat   := 'PHAR'; --���Ӧa�I(4 BYTES)
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
					emgoccrec.emchidep   := '';--'PHAR'; --�j��J�k�ݬ�(4 BYTES)
					emgoccrec.emchstat   := 'PHAR'; --���Ӧa�I(4 BYTES)
					emgoccrec.card_no    := 'BILLING';
					emgoccrec.emocomb    := 'N';
					emgoccrec.emchemg    := 'R';
					emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert REGISTER to date:'||trunc(patemgcaseRec.EMGDT));
					INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				END IF; -- v_ct_udcount end
			END IF; --�Įv�O end
			v_date   := v_date + 1;
		END LOOP;
    --�����O
    --EMGREGFEE(pCaseNo);
		IF patemgcaserec.emgregfg <> '1' OR patemgcaserec.emgregfg IS NULL THEN
			IF patemgcaserec.emgregfg <> '2' OR patemgcaserec.emgregfg IS NULL THEN
        --���E���E���f�w���Ȿ���O,�����~�����Ȿ���O
        --EMGOPDPT ,VEMG_PAT_SOURCE='C'--�������K�����O
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
      --EmgOccRec.EMCHIDEP := patemgcaseRec.EMGNS; --�j��J�k�ݬ�(4 BYTES)
			emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --�j��J�k�ݬ�(4 BYTES)
			emgoccrec.emchstat   := patemgcaserec.emgns; --���Ӧa�I(4 BYTES)
			emgoccrec.card_no    := 'BILLING';
			emgoccrec.emocomb    := 'N';
      --EmgOccRec.EMOCSECT := patemgcaseRec.EMGNS; --�p����O(4 BYTES)
			emgoccrec.emocsect   := patemgcaserec.emgsect; --�p����O(4 BYTES)
			emgoccrec.emocns     := patemgcaserec.emgns; --�f��(4 BYTES)
			emgoccrec.emoedept   := patemgcaserec.emgns; --�}�߬�O(4 BYTES, EMG ONLY)
			emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
      --dbms_output.put_line('insert REGISTER to date:'||trunc(patemgcaseRec.EMGDT));
			INSERT INTO cpoe.emg_occur VALUES emgoccrec;

      --�������S999 BY KUO 20121128,�[���A�ȶO
      --Add ��������A�ȶO by kuo 20150721 for S995
			IF patemgcaserec.emgspeu1 IN (
				'S999',
				'S995'
			) THEN
				emgoccrec.emblpk     := emgoccrec.caseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 15) || MOD (v_cnt, 100);
				v_cnt                := v_cnt + 1;
				emgoccrec.emchcode   := '91711115'; --91711115, ���O18
				emgoccrec.emchtyp1   := '18';
				emgoccrec.emchamt1   := 480;
				INSERT INTO cpoe.emg_occur VALUES emgoccrec;
			END IF;
		END IF; --IF patemgcaseRec.EMGREGFG <> '1'
		COMMIT WORK;
    --�۰ʤJ��E���y by kuo 20160511
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

  --�M���p��{��
	PROCEDURE initdata (
		pcaseno VARCHAR2
	) IS
    --���~�T���γ~
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
    --�]�w�{���W�٤�session_id
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

    --�b�R���e,�Y�����᪺�b�ڸ��,�x�s�ܾ��v��
		emg_calculate_pkg.bkoccur (pcaseno);
		DELETE FROM emg_bil_acnt_wk
		WHERE
			caseno = pcaseno;
		DELETE FROM emg_bil_occur_trans
		WHERE
			caseno = pcaseno;

    --�R�� ����զX����X����
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

  --�i�}�����O�ܨ����Ȧs��
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
    --���~�T���γ~
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --�]�w�{���W�٤�session_id
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

    --�ק�tmp_fincal.end_date,�|�o�ͥX�|�ɻ�ú�O,���j���b��S�ܦ�����ú�O
    --�]����E�O�@�Ө����쩳,�Nend_date�אּ2999/12/31(update by amber 20110421)
    --patemgdisgeRec.EDISDT := SYSDATE;
		patemgdisgerec.edisdt   := TO_DATE ('2999/12/31', 'YYYY/MM/DD');
    /*
    OPEN CUR_DISGE;
    LOOP
      FETCH CUR_DISGE into patemgdisgeRec;
      EXIT WHEN CUR_DISGE%NOTFOUND;
    END LOOP;
    */
    --�����@
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
    --�����G
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
    --�S��
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

  --���u�b��
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
            -- ���զX���s�W
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

    --�����T���Ѱ��O�X��g by Kuo 980428
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

    --�M��i�H�ൣ�M��[��60%����ͦW�� by kuo, SQL Provided by �H�@ 20140306
    --20171006�ھڨ|�۱N����զ��N�X���
    --20171011 copy from adm by kuo
    --20171108 ���`������:���M��p��~��P�ൣ�C�֦~�믫�줣�ݩ�p��M����v,�G���Ťp���M����v�E��O�[ by �ūT��,�u�d�M�����O IN ('MAIN0004')
		CURSOR ped_cardno (
			pdocno VARCHAR2
		) IS
		SELECT
			cardno
		FROM
			common.psbasic_vghtc
       --WHERE ((�M�����O='��M' AND �M��Ĵ���>='1030201' AND TITLE IN ('2014','7074')) OR
		WHERE
			((�M�����O = 'MAIN0004'
			  AND
			  �M��Ĵ��� >= '1030201'
			  AND
			  title IN (
				  '2014',
				  '7074'
			  )) --OR
              --(���M�����O IN('����M','��C��M','�p��~��','��C','�ൣ�C�֦~�믫��') AND TITLE NOT  IN  ('2004') ) OR
              --(���M�����O IN ('SUB0005','SUB0047','SUB0048') AND TITLE NOT  IN  ('2004') ) OR
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
			��v���� = pdocno;   

    --���~�T���γ~
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
		v_self_price          NUMBER (10, 2); --�۶O����(���)
		v_nh_price            NUMBER (10, 2); --���O����(���)
		v_other_price         NUMBER (10, 2); --�S���άO�S�������(���)
		v_other_fincal        VARCHAR2 (10); --�S���άO�S����(��@�p���X)
		v_price               NUMBER (10, 2); --�p���X�w��
		v_salf_per            NUMBER (5, 2); --��@���Obil_discdtl�۶O�馩����
		v_fincal              VARCHAR2 (10); --�馩����
		v_ud_qty              NUMBER (10, 2); --�ī~�p�]�˼ƶq
		v_ud_mstdcl           VARCHAR2 (20); --�ī~�ϥ�
		v_udd_payself         VARCHAR2 (01); --�ī~�O�_���O(y/n)�άO�a���ɧU(v)
		v_other_amt           NUMBER (10, 1); --�S���άO�S�����`���B(��@�p���X)
		v_nh_amt              NUMBER (10, 1); --���O�`���B(��@�p���X)
		v_self_amt            NUMBER (10, 1); --�ۥI�`���B(��@�p���X)
		v_emg_per             NUMBER (5, 2); --�[������
    --v_qty_1       integer;
		v_fee_type            VARCHAR2 (10); --���O���O

    --v_day         INTEGER;

    --v_amt_1       number(10,2);
    --v_amt_2       number(10,2);
    --v_amt_3       number(10,2);
    --v_self_pay    number(10,1);
		v_labprice            NUMBER (10, 1); --���O���
		v_nh_amt1             NUMBER (10, 1); --���O���B�Ȧs
		v_cnt                 INTEGER;
		v_pf_self_pay         NUMBER (10, 1); --�p���X�ۥI����
		v_pf_nh_pay           NUMBER (10, 1); --�p���X���O����
		v_pf_child_pay        NUMBER (10, 1); --�p���X�ൣ�[������
		v_labchild            VARCHAR2 (01); --VSNHI �O�_�ൣ�[��
		v_ins_fee_code        VARCHAR2 (20); --�p���X���������O�X
		v_pfemep              NUMBER (5, 2); --dbpfile�̭��������[����v
    --�|���p�����O
		v_fee_kind            VARCHAR2 (10); --�|���p�����O
		v_nhipric             NUMBER (10, 2); --VSNHI���O��
    --v_limit_amt number(10,0);
		v_feemep_flag         VARCHAR2 (01) := 'N'; --pfclass��E�O�_�i�p��@flag
		v_pfopfg_flag         VARCHAR2 (01) := 'N'; --pfclass��N�_
		v_pfspexam            VARCHAR2 (01) := 'N'; --pfclass�S���ˬd�_
		v_acnt_seq            NUMBER (5, 0); --�p�ƥ�
		v_e_level             VARCHAR2 (01) := '1'; --��E�L��
    --v_qty          INTEGER;
		v_in_type             VARCHAR2 (02); --emg_occur�� fee_type emgOccurRec.EMCHTYP1;
		v_out_type            VARCHAR2 (02); --�ഫ�O�����O��
		v_pricety1            VARCHAR2 (02); --dbpfile�������O

    --v_lab_disc_pert number(5,2);
    --v_lab_qty       integer;
		v_labi_qty            INTEGER; --VSNHI�ƶq
    --v_dietselfprice number(8,2);
    --v_dietnhprice   number(8,2);
    --v_dietunit      varchar2(10);
    --v_nh_diet_flag  varchar2(01) := 'N';
    --v_finCode       varchar2(10);

    --�O���O�_�O��billtemp�������椧���O
    --���O��'Y'��,���A���s�p�� amount
		v_keep_amount_flag    VARCHAR2 (01) := 'N';

    --v_days     integer;
    --v_lastdate date;
		v_birthday            DATE;
		v_disctype            VARCHAR2 (01); --�۶O(p)�άO�S��(b)�馩�ɧP�_
		v_insu_per            NUMBER (5, 2); --�۶O(p)�άO�S��(b)�馩�����O�馩����

    --v_breakFlag varchar2(01) := 'N';
    --v_breakTime varchar2(20);
		v_child_flag_1        VARCHAR2 (01);
		v_child_flag_2        VARCHAR2 (01);
		v_child_flag_3        VARCHAR2 (01);
		v_labchild_inc        VARCHAR2 (01); --���ɨൣ�[���氵 add by kuo 20140128
		v_yy                  INTEGER;
		ls_date               VARCHAR2 (10);
		v_mm                  VARCHAR2 (10);
		c_count               NUMBER;
		labilabi              VARCHAR2 (20); --�馩���O��Ӱ��O
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
		maxcopay              NUMBER; --add by kuo 20170320 for �s�����t��
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

    --�]�w�{���W�٤�session_id
		v_program_name                  := 'emg_calculate_PKG.CompAcntWk';
		v_session_id                    := userenv ('SESSIONID');
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;

    --1152 -- ���ƿ��F��ĵ��s�� �̹�ڪ��p�p��A�ݺⱾ���O by kuo 20160128
    --cancel by kuo 20161227 ��� 1151
    /*
    IF PATEMGCASEREC.EMGSPEU1='1152' THEN
       --delete fixed fee exception 37 from cpoe.emg_occur
       DELETE FROM CPOE.EMG_OCCUR  
       WHERE CASENO = PCASENO
       AND EMCHTYP1 IN ('01', '03', '04', '05');

       COMMIT WORK;
    END IF;	
    */
    --�ק�ͤ������A���@�ӹw�]�� by kuo 20141203
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

    --���X�f�w�~��
    --�P�_�O�_�ŦX�ൣ�[��( 6���H�U , �G���H�U ,���Ӥ�H�U)
    --�~�֤j��6��,�N�S���ൣ�[��
		IF v_yy > 6 THEN
			v_child_flag_1   := 'N';
			v_child_flag_2   := 'N';
			v_child_flag_3   := 'N';
		ELSE
      --�p�󤻷��j��G����
			IF v_yy <= 6 AND to_number (ls_date) > 20000 THEN
				v_child_flag_1 := 'Y';
			ELSE
        --�~�֤p��@��,����S�p�󤻭Ӥ�
        --v_mm := substr(ls_date,4,2);
				IF substr (ls_date, 1, 2) = '00' AND to_number (substr (ls_date, 4, 2)) < 6 THEN
					v_child_flag_3 := 'Y';
          --�p��G���j�󤻭Ӥ�
				ELSE
					v_child_flag_2 := 'Y';
				END IF;
			END IF;
		END IF;

    --�ǳ�EMG_bil_feemst,EMG_bil_feedtl
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

    --���X�i�馩�����綵����?
		INSERT INTO emg_bil_feemst VALUES emgfeemstrec;

    --�u�������O
		IF patemgcaserec.emgregfg = 'Y' THEN
      --�g�@��PROCEDURE�J���������O
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

      --�P�_�O�_���ݫO�dbilltemp������,�������
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

      --�P�_�O�_���ݫO�dbilltemp������,�������
			IF patemgcaserec.emg1fncl = '9' THEN
        --CIVC
				IF substr (emgoccurrec.ordseq, 12, 4) <> '0000' OR emgoccurrec.emocomb = 'N' THEN
					v_keep_amount_flag := 'N';
				ELSE
					v_keep_amount_flag := 'Y';
				END IF;
			END IF;

      --����Xdbpfile�������O
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

      --�����D������,��90212608 ��90212609 �����Q�p��i�h
      /*OPEN BY KUO 1000526
      IF emgOccurRec.EMCHCODE = '90212608' OR
         emgOccurRec.EMCHCODE = '90212609' THEN
        emgAcntWkRec.Emg_Per := 0;
      END IF;
      */
			IF emgacntwkrec.emg_per <> 1 THEN
				emgacntwkrec.emg_per := emgacntwkrec.emg_per;
			END IF;

      --���O�X60413200 �򥻴N�[ 0.65,�ܤ֬�1.65 �b 2008-01-01�H�� by Kuo 970505
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

      --���o���
      --�ī~�ݧ�t�@����
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

          -- ��������, ���O�ĶO�]�� 0
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
          --�S���ī~�p���]�w��
          --�p�إߩ���ɤ������,�ݦAŪ�ī~�D���ഫ�Y��
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

        --�ۥI
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

        --�a��
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
          --�B�z�S������
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

        --�H�W�ĶO�B�z
        --����X�w��
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

        --���o���v��
        --�p�G������ƫhrepalce
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
        --�p�ⰷ�O��,�L�������D
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

        --�뭹�O�P�_,��E�L
        --v_nh_diet_flag := 'N';
				IF v_self_price > 0 THEN
          --�ݭn�ۥI,�ݬݬO�_���i�H���1.PFCLASS
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
               --���Ͽ��~���Q�󥿡A�٬O���@�Ӥ�� by kuo 20151116
							IF emgoccurrec.emocdate >= TO_DATE ('20151101', 'YYYYMMDD') THEN
								v_other_fincal := 'VERT';
							END IF;
						END IF;
					ELSE
            --2.�۶O�馩
						v_disctype := 'B';
						OPEN cur_disc (v_disctype, pcaseno, emgoccurrec.emchtyp1, emgoccurrec.embldate);
						FETCH cur_disc INTO
							v_salf_per,
							v_fincal,
							v_insu_per;
						IF cur_disc%found THEN
              --�i�H�馩�A�h�n�ݬݳ涵�p���X�ѵL��Ө�L�W�h���i�馩
							IF length (v_fincal) > 4 THEN
								v_fincal := substr (v_fincal, 1, 4);
							END IF;
              --�O�_��Ӱ��O
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
                --�ۥI,���i�ӳ����ɷ|
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
				END IF; --�ݭn�ۥIEND

        --�O�_���۶O��
				IF emgoccurrec.emchanes = 'PR' THEN
          --�a���O�_�i�H�ର���ɷ|��I
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
							v_other_fincal := 'VERT'; --�ର���ɷ|
						END IF;
					ELSE            
            --�H�۶O�p
						v_self_price    := v_price;
						v_nh_price      := 0;
						v_other_price   := 0;
            --�P�_�O�_�馩����
						v_disctype      := 'P'; --�۶OTYPE
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

      --��N����p��
      --                     �Ĥ@�M     �ĤG�M     �ĤT�M
      --�P�@�M�f,�h��          100        50        x
      --���P�M�f,�P��          100        50       20
      --���P�M�f,���P��        100       100       33
      --�P�@�M�f,�h��
      --���O�����~�n�̴`
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
            --���P�M�f,�P��
					ELSIF emgoccurrec.emorcat = '3' THEN
						IF emgoccurrec.emororno = '1' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSIF emgoccurrec.emororno = '2' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0.5;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0.2;
						END IF;
            --���P�M�f,���P��
					ELSIF emgoccurrec.emorcat = '4' THEN
						IF emgoccurrec.emororno = '1' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSIF emgoccurrec.emororno = '2' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 1 / 3;
						END IF;
					ELSIF emgoccurrec.emorcat = '7' THEN --7_�h���P���Ψⰼ�ʤ�N(1+0.5+0.5+0) by kuo 20171018
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
					ELSIF emgoccurrec.emorcat = '8' THEN --8_�h�����P����N(1+1+0.5+0) by kuo 20171018
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
					ELSIF emgoccurrec.emorcat = '9' THEN --9_�h���ж�(ISS>=16)�ìI��h���ݸ���N(1+1+1+1) by kuo 20171018
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
          --�ֵo�g,�Ĥ@�M�~���
					IF emgoccurrec.emorcomp = 'Y' THEN
						IF emgoccurrec.emororno = '1' THEN
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0.5;
						ELSE
							emgacntwkrec.emg_per := emgacntwkrec.emg_per * 0;
						END IF;
					END IF;
				END IF; --END IF emgOccurRec.EMCHTYP1 = '07'
			END IF; --f_getnhrangeflag(pCaseNo => pCaseNo...

      --�M�\���p��980303 BY KUO, ��E�|����?
			IF emgoccurrec.emchtyp3 = '1' THEN
				v_keep_amount_flag     := 'Y';
				emgoccurrec.emchamt1   := 0;
			END IF;
			IF v_nh_price > 0 THEN
				v_keep_amount_flag := 'N';
			END IF;

      --�HEMG_OCCUR���B���D������dbpfile���B
			IF v_keep_amount_flag = 'Y' AND v_self_price <> 0 AND v_other_price = 0 THEN
				v_self_price   := emgoccurrec.emchamt1 / emgoccurrec.emchqty1;
				v_self_amt     := emgoccurrec.emchamt1;
        --�]���^�k���,�ҥH�n�����O���k�^��N�O��
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

      --�B�z�s�ͨ�O�����NHI--��E�L

      --�A��@��PFCLASS LABI����     
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

      --��emg_occur��pfkey�ȧǸ��֥[,�����妬�|�Ψ즹���,��E�]�S��Acnt_Seq,�t���Ǹ�(update by amber 20110422)
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

      --emgAcntWkRec.e_Level := v_e_level; ��E�L
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
      --1193 ��� 1151 by kuo 20170517
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
        --���O�ĶO
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
              --MAKE SURE Insu_Amt IS > 0,�]��QTY�|<0
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
          --���O�D�ĶO ,�u���O�X
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

            --add by kuo 20160901�H���� getEMgPer�̭���
						IF TO_CHAR (patemgcaserec.emgdt, 'YYYYMMDD') < '20160901' THEN
               --�p�Gpfclass �n�ൣ�[��,vsnhi���ݥ[��,�n���^��
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

               --add LABCHILD_INC ���ɨൣ�[���氵 add by kuo 20140128
               --�ɶ��bVSNHI����ɤw�g�P�_�F
               --�]����ӳ��������D�u���j�� by kuo 20140221
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

             --20171001�_�ͮ� add by kuo 20171012
            --��E�E��O(���˶ˤ���)'00201B','00202B','00203B','00204B','00225B',�p�J���M����v�[�p50%            
						IF emgacntwkrec.ins_fee_code IN (
							'00201B',
							'00202B',
							'00203B',
							'00204B',
							'00225B'
						) AND emgoccurrec.emocdate >= TO_DATE ('20171001', 'YYYYMMDD') THEN
							vcardno := '';
							OPEN ped_cardno (patemgcaserec.emgvsno); --�令VSNO by kuo 20171013
							FETCH ped_cardno INTO vcardno;
							CLOSE ped_cardno;
               --DBMS_OUTPUT.PUT_LINE(VCARDNO);
							IF vcardno IS NOT NULL THEN
								emgacntwkrec.emg_per := emgacntwkrec.emg_per + 0.5;
							ELSE --�D��M��v���N���H�A�~�֬�6�Ӥ�H�W��6���H�U�ൣ��(�N��~���X�ͦ~��j�󵥩�6�Ӥ�B�p�󵥩�83�Ӥ�)�A�t�[�p50%�C(�۶O�Φ~��109�~1��_�s�W) request by ���s�X 20200110, kuo 20200110   
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

            --�p��ç�����
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
                --MAKE SURE Insu_Amt IS > 0,�]��QTY�|<0
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

          --FOR ���O��
          --�]���S�����O�X�S�n�ⰷ�O��,�u�n�w��i�h....@_@
          --��E�L
				END IF; --IF emgOccurRec.Fee_Kind = '6'
			END IF; --IF v_nh_amt <> 0

      --���u �����O��K,�ѧ馩��
      /*
      IF patemgcaseRec.emg2fncl = '6' AND emgOccurRec.EMCHTYP1 = '37' THEN
        v_other_amt    := v_self_amt + v_other_amt;
        v_nh_amt       := 0;
        v_self_amt     := 0;
        v_other_fincal := 'EMPL';
        */ 
        --FOR ���O�� �����O��K
			IF patemgcaserec.emgcopay = '003' AND emgoccurrec.emchtyp1 = '37' THEN
				v_other_amt      := v_self_amt;
				v_other_price    := v_other_amt;
				v_nh_amt         := 0;
				v_self_amt       := 0;
        --v_other_fincal := 'NHI3';
				v_other_fincal   := 'HOSP';
			END IF;
      --�s�W�ĤG������F,�����O�����ɷ| from 20160301 by kuo
			IF patemgcaserec.emg2fncl = 'F' AND emgoccurrec.emchtyp1 = '37' THEN
				v_other_amt      := v_self_amt;
				v_other_price    := v_other_amt;
				v_nh_amt         := 0;
				v_self_amt       := 0;
				v_other_fincal   := 'VERT';
			END IF;
			IF v_self_amt <> 0 THEN
        --�N�x�f�жO�u������ emg_bil_acnt_wk BY KUO 970430,��E�L
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
      --ADD IF CLERK='NHIMOVE' �O�ݩ��E�h���|�A���O�٬O�n��ܡA����[��FEEDTL
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
      --ADD IF CLERK='NHIMOVE' �O�ݩ��E�h���|�A���O�٬O�n��ܡA����[��FEEDTL
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
      --ADD IF CLERK='NHIMOVE' �O�ݩ��E�h���|�A���O�٬O�n��ܡA����[��FEEDTL
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
      --�ѩ��E�LLEVEL����,�@�ߩ�bLEVLE1,�����t�ᬰ�T�w�O��
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

    --���O�W�h�˵� ���O�����~��
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

    --�����t��
		IF f_getnhrangeflag (pcaseno, patemgcaserec.emgdt, '2') = 'NHI0' THEN
      -- ���쳡���t�� 150
      -- �s�WOS������ by kuo 20151210
      -- add patemgcaseRec.EMGCOPAY='E00' for dent by kuo 20160620
      -- �j��P�p�줣�ũM�A�H�p�쬰�D by kuo 20160620, 20160621�ͮ�
      --SELECT EMG_DEPT FROM VGHTC.DB_SECTION_NEW WHERE EMG_USE='Y' and EMG_CLINIC='PER';
      --IF PATEMGCASEREC.EMGDT >= TO_DATE('20160621','YYYYMMDD') THEN
      --�令 20160809
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
						ename = patemgcaserec.emgsect; --�קK�P�_���� by kuo 20160808
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
        -- ��L�쳡���t�� 450
        -- �˶� 1,2 �ŻP�Ӱ|�ɶ�����0-6���� 450, ��l�˶� 3-5 550 by kuo 20170216
        -- �ɶ����w...
        -- �����ɶ� by Kuo 20170320
        --�ͮĮɶ��� 20170415
				maxcopay := 550;
        --IF TRIAGE IN ('1','2') OR 
        --   (to_CHAR(patemgcaseRec.EMGDT,'HH24') >= 0 AND to_CHAR(patemgcaseRec.EMGDT,'HH24')<=6) THEN
        --�ժ��n�D�]�D���n�D�n�Ƚw15����...by kuo 20170414
				IF triage IN (
					'1',
					'2'
				) OR patemgcaserec.emgdt <= TO_DATE ('201704150015', 'YYYYMMDDHH24MI') THEN
					maxcopay := 450;
				END IF;
        --�H�U 450 �令 MaxCoPay by Kuo 20170216
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
    --('1058','1054','1039','1060','1083') ��;
		IF patemgcaserec.emg2fncl IN (
			'E',
			'1',
			'6'
		) OR v_cnt > 0 THEN
			p_modifityselfpay (pcaseno, patemgcaserec.emg2fncl, v_acnt_seq);
		END IF;

    --�������S999 BY KUO 20121128
    --IF patemgcaseRec.EMGSPEU1='S999' THEN
    --   CONTRACT_ES999(PCASENO);
    --END IF;

        -- ���u��� LABI ���ܡA�h�b���|�ӳ��C�����O�վ�� 1060 ���u���C   
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

  --�p����O����
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

    --���~�T���γ~
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
    --�]�w�{���W�٤�session_id
		v_program_name         := 'emg_calculate_PKG.AcntWkCalculate';
		v_session_id           := userenv ('SESSIONID');
		v_source_seq           := pcaseno;

    --�̦U���O���Xacntwk��Ƨ@���`,�g�J��O���Ӥ�
		emgacntdetrec.caseno   := pcaseno;
		v_seqno                := 0;
		OPEN cur_master;
		LOOP
			FETCH cur_master INTO v_fee_kind;
			EXIT WHEN cur_master%notfound;

      --�ĶO
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
    --�]���p�G�z�L user exception �w�g��n���~�T���J err_code��err_info,�G���ݭ���
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

  --�p�⭼��
	PROCEDURE getemgper (
		pcaseno          VARCHAR2, --��|��
		ppfkey           VARCHAR2, --�p���X
		pfeekind         VARCHAR2, --�b�ɭp�����O
		pemgflag         VARCHAR2, --��@�_
		pfncl            VARCHAR2, --�����O
		ptype            VARCHAR2, --'1'��������� '2',�u���@����
		pdate            DATE,
		emg_per          OUT   NUMBER, --�[����
		holiday_per      OUT   NUMBER, --����[������
		night_per        OUT   NUMBER, --�]���[������
		child_per        OUT   NUMBER, --�ൣ�[������
		urgent_per       OUT   NUMBER, --��@�[������
		operation_per    OUT   NUMBER, --��N�[������
		anesthesia_per   OUT   NUMBER, --�¾K�[������
		materials_per    OUT   NUMBER --���ƥ[������
	) --�p����
	 IS
    --���~�T���γ~
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

    --�۶O���B
		v_pf_self_pay    NUMBER (10, 2);
    --�ӳ����B
		v_pf_nh_pay      NUMBER (10, 2);
    --�ൣ�[��
		v_pf_child_pay   NUMBER (10, 2);
    --��|�i��@�_
		v_feemep_flag    VARCHAR2 (01);
    --��N�_
		v_pfopfg_flag    VARCHAR2 (01);
    --�S������_
		v_pfspexam       VARCHAR2 (01);
		v_child_flag_1   VARCHAR2 (01) := 'N';
		v_child_flag_2   VARCHAR2 (01) := 'N';
		v_child_flag_3   VARCHAR2 (01) := 'N';
		patemgcaserec    common.pat_emg_casen%rowtype;
		ls_date          VARCHAR2 (10);
		v_nh_type        VARCHAR2 (02);
		vnh_lbchild      VARCHAR2 (01);--���ɨൣ�[�� by kuo 201600824
		vnh_child        VARCHAR2 (01);--�ൣ�[�� by kuo 201600824
		vlabkey          VARCHAR2 (12);--�_�����O�X�ൣ�[���� by kuo 20191120
		v_holiday        VARCHAR2 (01);
		v_hweek          CHAR (1);

    --�X�ͦ~��(���O�W�w�~�ֳ����p�⬰�~-�~)
    --����~�O�~���
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
    --�]�������ܤƷs�Wcursor by kuo 20140822
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
    --�]�w�{���W�٤�session_id
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

    --��E�E��O�[��,¾�˥���˶ˤ�����X����
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

      --��990101�}�l,�]���[����50%
			IF TO_CHAR (patemgcaserec.emgdt, 'HH24MI') >= '2200' OR TO_CHAR (patemgcaserec.emgdt, 'HH24MI') <= '0600'
      --OR v_Holiday='Y' 
			 THEN
        --99/09/01�_,   �믫��]���ΨҰ��駡�[�� 20%
        --1001213 ��^ 50% BY KUO 
        --IF patemgcaseRec.Emgdept = 'PSY' THEN
        --  pEmgPer   := pEmgPer + 0.2;
        --  NIGHT_PER := 0.2;
        --ELSE
          --add OS ������ by kuo 20151210
          --mark by kuo 20160411 request by ù��ã,����]����Ӧ���
          --IF (PATEMGCASEREC.EMGDEPT = 'DENT' OR PATEMGCASEREC.EMGSECT='OS') AND PFEEKIND='03' THEN --����E��O�L�]���[��
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
				.emgdt, 'YYYYMMDD') >= '20171001') THEN --�s�W20171001�_�P�������ⰲ��[�� by kuo 20170929
					pemgper       := pemgper + 0.2;
					holiday_per   := 0.2;
				END IF;
			END IF;
      --RETURN pEmgPer;
		END IF;

    -- 74700371  �[�� 37% �� 990602 �_
    --�q������ by kuo 20130422
    --IF pFncl = '7' AND pPFkey IN ('74700371', '74770844') THEN
    --  pEmgPer       := pEmgPer + 0.37;
    --  MATERIALS_PER := 0.37;
    --END IF;

    --���
    --�ק�ͤ������A���@�ӹw�]�� by kuo 20141203
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

      --���X�f�w�~��
      --���O�~���ٺ�H�묰�D
      --�ൣ�[���אּ�̭p������ݥ[���ӫD��|��� BY KUO 1010224,�H10102���|��}�l
			IF TO_CHAR (patemgcaserec.emglvdt, 'YYYYMM') = '201202' THEN
				ls_date := biling_common_pkg.f_datebetween (TO_DATE ((TO_CHAR (v_birthday, 'YYYYMM') || '01'), 'YYYYMMDD'), TO_DATE ((TO_CHAR
				(pdate, 'YYYYMM') || '01'), 'YYYYMMDD'));
         --ls_date := biling_common_pkg.f_datebetween(b_date => v_birthday,
         --                                           E_DATE => PATEMGCASEREC.EMGDT);
         --DBMS_OUTPUT.PUT_LINE('to_number(ls_date):'||TO_NUMBER(LS_DATE));
			ELSE
				ls_date := biling_common_pkg.f_datebetween (TO_DATE ((TO_CHAR (v_birthday, 'YYYYMM') || '01'), 'YYYYMMDD'), TO_DATE ((TO_CHAR
				(patemgcaserec.emgdt, 'YYYYMM') || '01'), 'YYYYMMDD'));
        --add by kuo 20160824, 201609�H��ͮĪ���k,�̤��
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

      --�P�_�O�_�ŦX�ൣ�[��( 6���H�U , �G���H�U ,���Ӥ�H�U)
      --�~�֤j��6��,�N�S���ൣ�[��
      --�����������p��ൣ�[��
      --1.< 6m �� �A+60%
      --2.�j�󵥩�6m�A�p�󵥩�23m �̡A+30%
      --3.�j�󵥩�24m�A�p�󵥩�83m�̡A+20%
			IF pfncl = '7' AND v_birthday IS NOT NULL THEN
				v_child_flag_1   := 'N';
				v_child_flag_2   := 'N';
				v_child_flag_3   := 'N';
				IF v_yy > 6 THEN
					v_child_flag_1   := 'N';
					v_child_flag_2   := 'N';
					v_child_flag_3   := 'N';
				ELSE
          --�p�󤻷��j��G����
          --IF v_yy <= 6 AND v_yy > 2 THEN
					IF TO_CHAR (patemgcaserec.emgdt, 'YYYYMM') < '201609' THEN
						IF v_yy <= 6 AND to_number (ls_date) >= 20000 THEN
							v_child_flag_1 := 'Y';
						ELSE
               --�~�֤p��@��,����S�p�󤻭Ӥ�
							IF substr (ls_date, 1, 3) = '000' AND to_number (substr (ls_date, 4, 2)) < 6 THEN
								v_child_flag_3 := 'Y';
                  --�p��G���j�󤻭Ӥ�
							ELSE
								v_child_flag_2 := 'Y';
							END IF;
						END IF;
					END IF;
				END IF;
        --add by kuo 20160824, 201609�H��ͮĪ���k,�̤��
				IF TO_CHAR (patemgcaserec.emgdt, 'YYYYMM') >= '201609' THEN
           --��N
					IF pfeekind IN (
						'07',
						'08'
					) OR v_nh_type = '07' THEN
						IF ls_date <= 6 THEN --�p�󵥩󤻭Ӥ�
							v_child_flag_3 := 'Y';
						END IF;
						IF ls_date <= 23 AND ls_date >= 7 THEN ---�G����C�Ӥ뤧��
							v_child_flag_2 := 'Y';
						END IF;
						IF ls_date >= 24 AND ls_date <= 83 THEN --�����H�U
							v_child_flag_1 := 'Y';
						END IF;
					ELSE --�D��N           
						IF ls_date < 6 THEN --�p�󤻭Ӥ�
							v_child_flag_3 := 'Y';
						END IF;
						IF ls_date <= 23 AND ls_date >= 6 THEN ---�G���줻�Ӥ뤧��
							v_child_flag_2 := 'Y';
						END IF;
						IF ls_date >= 24 AND ls_date <= 83 THEN --�����H�U
							v_child_flag_1 := 'Y';
						END IF;
					END IF;
				END IF;
			ELSE
        --���������L�ൣ�[��
        --���������L�ൣ�[������ by kuo �q20121115�}�l
				IF v_yy > 6 THEN
					v_child_flag_1   := 'N';
					v_child_flag_2   := 'N';
					v_child_flag_3   := 'N';
				ELSE
          --�p�󤻷��j��G����
          --IF v_yy <= 6 AND v_yy > 2 THEN
					IF v_yy <= 6 AND to_number (ls_date) >= 20000 THEN
						v_child_flag_1 := 'Y';
					ELSE
            --�~�֤p��@��,����S�p�󤻭Ӥ�
						IF substr (ls_date, 1, 3) = '000' AND to_number (substr (ls_date, 4, 2)) < 6 THEN
							v_child_flag_3 := 'Y';
              --�p��G���j�󤻭Ӥ�
						ELSE
							v_child_flag_2 := 'Y';
						END IF;
					END IF;
				END IF;
        --���������L�ൣ�[�� 20121115���e,�令20121113���e
				IF pdate < TO_DATE ('20121113', 'YYYYMMDD') THEN
					v_child_flag_1   := 'N';
					v_child_flag_2   := 'N';
					v_child_flag_3   := 'N';
				END IF;
			END IF;

      --��|�i����@,�B����@���O��
			IF v_feemep_flag = 'Y' AND pemgflag = 'E' THEN
        --��N,���ͥ[��
				IF pfeekind IN (
					'07',
					'08'
				) OR v_nh_type = '07' THEN
					pemgper      := pemgper + 0.3;
					urgent_per   := 0.3;
				ELSE
          -- ���O���� �氵�[�� 0.2
					IF pfncl = '7' THEN
            --��N��@�[���v�O30%.
						IF v_pfopfg_flag = 'Y' THEN
							pemgper      := pemgper + 0.3;
							urgent_per   := 0.3;
						ELSE
							pemgper      := pemgper + 0.2;
							urgent_per   := 0.2;
						END IF;
					ELSE
            -- �������� ��@�[�� 0.3
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
      --��N�[��
			IF v_pfopfg_flag = 'Y' THEN
        --���t���ơA���[�� 80011890 add by kuo 1000525
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
        --�S��[�� by kuo 20140822
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

      --�¾K�[��
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

      --�[���ൣ�[���P�[��
			IF TO_CHAR (patemgcaserec.emgdt, 'YYYYMM') >= '201609' THEN
        --dbpfile ���]�w�ൣ�[�����B��,�L�ൣ�[��,�h�P�_VSNHI�̭��n���ൣ�[���~�� by kuo 20160824
				IF v_pf_child_pay > 0 AND v_pf_child_pay IS NOT NULL AND vnh_child = 'Y' THEN
          --�ൣ�[��(6���H�U)
					IF v_child_flag_1 = 'Y' THEN
						pemgper     := pemgper + 0.2;
						child_per   := 0.2;
					END IF;
          --�ൣ�[��(2���H�U)
					IF v_child_flag_2 = 'Y' THEN
						pemgper     := pemgper + 0.3;
						child_per   := 0.3;
					END IF;
          --�ൣ�[��(���Ӥ�H�U)
					IF v_child_flag_3 = 'Y' THEN
            --�_�����O�X�d��:41000-44599 �ൣ�[�� X�� 23M(�p�󵥩�23M) 30% by kuo 20191120
						IF substr (vlabkey, 1, 5) >= '41000' AND substr (vlabkey, 1, 5) <= '44599' THEN
							pemgper     := pemgper + 0.3;
							child_per   := 0.3;
						ELSE
							pemgper     := pemgper + 0.6;
							child_per   := 0.6;
						END IF;
            --20160401�H�᤻�Ӥ�H�U�E��O�אּ100%(+1) request by �}�v�a by kuo 20160331
						IF patemgcaserec.emgdt >= TO_DATE ('20160401', 'YYYYMMDD') THEN
							IF pfeekind = '03' THEN
								pemgper     := pemgper - 0.6 + 1;
								child_per   := 1;
							END IF;
						END IF;
					END IF;
				ELSE
          --���Ӥ�H�U,��N�[��60
					IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') THEN
						pemgper     := pemgper + 0.6;
						child_per   := 0.6;
					END IF;
				END IF;  
        --�ൣ�[���[��
				IF vnh_lbchild = 'Y' THEN
           --�ൣ�[��(6���H�U)
					IF v_child_flag_1 = 'Y' THEN
						pemgper     := pemgper + 0.6;
						child_per   := child_per + 0.6;
					END IF;
          --�ൣ�[��(2���H�U)
					IF v_child_flag_2 = 'Y' THEN
						pemgper     := pemgper + 0.8;
						child_per   := child_per + 0.8;
					END IF;
          --�ൣ�[��(���Ӥ�H�U)
					IF v_child_flag_3 = 'Y' THEN
						pemgper     := pemgper + 1;
						child_per   := child_per + 1;
					END IF;
				END IF;
			ELSE 
        --dbpfile ���]�w�ൣ�[�����B��,�L�ൣ�[��
				IF v_pf_child_pay > 0 AND v_pf_child_pay IS NOT NULL THEN
          --�ൣ�[��(6���H�U)
					IF v_child_flag_1 = 'Y' THEN
						pemgper     := pemgper + 0.2;
						child_per   := 0.2;
					END IF;
          --�ൣ�[��(2���H�U)
					IF v_child_flag_2 = 'Y' THEN
						pemgper     := pemgper + 0.3;
						child_per   := 0.3;
					END IF;
          --�ൣ�[��(���Ӥ�H�U)
					IF v_child_flag_3 = 'Y' THEN
						pemgper     := pemgper + 0.6;
						child_per   := 0.6;
            --20160401�H�᤻�Ӥ�H�U�E��O�אּ100%(+1) request by �}�v�a by kuo 20160331
						IF patemgcaserec.emgdt >= TO_DATE ('20160401', 'YYYYMMDD') THEN
							IF pfeekind = '03' THEN
								pemgper     := pemgper - 0.6 + 1;
								child_per   := 1;
							END IF;
						END IF;
					END IF;
				ELSE
          --���Ӥ�H�U,��N�[��60
					IF v_child_flag_3 = 'Y' AND (pfeekind = '07' OR pfeekind = '08' OR v_pfopfg_flag = 'Y') THEN
						pemgper     := pemgper + 0.6;
						child_per   := 0.6;
					END IF;
				END IF;
			END IF;

      --����֤J��N�D�����t�C
			IF pfeekind = '11' THEN
				pemgper          := 0;
				anesthesia_per   := 0;
			END IF;
      --�H�U���Ƭ��T�w����
      --�§�
			IF pfeekind IN (
				'12'
			) THEN
        --add 55101401, 55101400 ����§� by kuo 20180221
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

      --���
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

  --�վ������b��
	PROCEDURE p_receivablecomp (
		pcaseno VARCHAR2
	) IS

    --���X�����b�ڽվ�D��
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

    --���X���Q�վ�쪺���O
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

    --���X�즳�����b�ڪ��B
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			emg_bil_feemst
		WHERE
			emg_bil_feemst.caseno = pcaseno;

    --���X�즳�����b�ڪ��B
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

    --���~�T���γ~
		v_program_name      VARCHAR2 (80);
		v_session_id        NUMBER (10);
		v_error_code        VARCHAR2 (20);
		v_error_msg         VARCHAR2 (400);
		v_error_info        VARCHAR2 (600);
		v_source_seq        VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --�]�w�{���W�٤�session_id
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

    --���X�ӯf�w�����b�ڽվ��ɸ��
		OPEN cur_mst;
		LOOP
			FETCH cur_mst INTO emgadjstmstrec;
			EXIT WHEN cur_mst%notfound;
			OPEN cur_dtl (emgadjstmstrec.adjst_seqno);
			LOOP
				FETCH cur_dtl INTO emgadjstdtlrec;
				EXIT WHEN cur_dtl%notfound;
				emgadjstmstrec.blfrunit := rtrim (ltrim (emgadjstmstrec.blfrunit));
        --���X�즳���O���
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

        --���X�s�����O�����,�ק���B
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
          --�L��ƫh�s�W�@��
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

    --���X�ӯf�w�����b�ڽվ��ɸ��
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

        --�p�վ㤧���u���O�����x����
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

    --�a�����N�E�W�L90��(>90)�����O�ۥI by kuo 20150624, 20150701�ͮ�
    --���ic�d�d�� EMGICARD by kuo 20150812
    --20151231 ended by kuo 20160307
    --�n�令20160701-20161231
    --�令20170701-20171231 request by �̮a�W�PĬ�e�N by kuo 20170420
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

  --�u�ݨ����O�B�z
	PROCEDURE p_disfin (
		pcaseno    VARCHAR2,
		pfinacl    VARCHAR2,
		pdiscfin   OUT VARCHAR2
	) IS

    --���~�T���γ~
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
    --�]�w�{���W�٤�session_id
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

      --�L¾�a
			IF patemgcaserec.emg2fncl = '1' THEN
        --�N�x
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
      --��¾�a
			IF patemgcaserec.emg2fncl = 'E' THEN
        --�N�x (03 �ֱN�L�u�� BY KUO
				IF patemgcaserec.vtrnk IN (
					'01',
					'02'
				) THEN
					pdiscfin := 'VTAM';
					return;
				END IF;
        --�W��
				IF patemgcaserec.vtrnk = '04' THEN
					pdiscfin := 'VT04';
					return;
				END IF;
        --�կ�
				IF patemgcaserec.vtrnk IN (
					'05',
					'06'
				) THEN
					pdiscfin := 'VT05';
					return;
				END IF;
        --�L��
				IF patemgcaserec.vtrnk IN (
					'07',
					'08',
					'09',
					'10'
				) THEN
					pdiscfin := 'VT07';
					return;
				END IF;
        --�h�x�L
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

        --00��20160101�}�l�P 11 �ۦP request by �V�p�j by kuo 20160323
				IF patemgcaserec.vtrnk IN (
					'00'
				) AND patemgcaserec.emgdt >= TO_DATE ('20160116', 'YYYYMMDD') THEN
					pdiscfin := 'VT11';
					return;
				END IF;
				IF patemgcaserec.vtrnk IS NOT NULL THEN
					pdiscfin := 'VT04'; --�H�̰��p
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

  --���O�W�h�վ�
	PROCEDURE p_transnhrule (
		pcaseno VARCHAR2
	) IS

    --��X���b�W�h�ഫ�]�w������ƪ��D�����O�X
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

    --�A�ǤJ�ŦX�D�����O�X�������W�w
		CURSOR cur_2 (
			pinsfeecode VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_nhrule_set
		WHERE
			bil_nhrule_set.ins_fee_code1 = pinsfeecode;

    --��X�ŦX�Ӷ��W�w�����ӱb
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

    --��X�C��b�ڵ���
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

    --7.�C��33046B2����33088B,�T���H�W�ন33089B
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

    --8.���X�Ҧ����>30000���ç�
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

    --9.���`�W�ӳ��W�h(���ѭp)
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

    --10.��G�`�W�ֶ��ץ�(�P��)
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

    --���~�T���γ~
		v_program_name    VARCHAR2 (80);
		v_session_id      NUMBER (10);
		v_error_code      VARCHAR2 (20);
		v_error_msg       VARCHAR2 (400);
		v_error_info      VARCHAR2 (600);
		v_source_seq      VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --�]�w�{���W�٤�session_id
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
    --6.�L�o��N���O(07)�P�餧����48011C,48012C,48013C,CASEPAYMENT���~���L�o
    /*��E�Ldrg
    */
    --7.�C��33046B2����33088B,�T���H�W�ন33089B
		OPEN cur_7;
		LOOP
			FETCH cur_7 INTO
				v_start_date,
				v_cnt;
			EXIT WHEN cur_7%notfound;
      --33046B=2 �ন33088B
			IF v_cnt = 2 THEN
				v_first := 'Y';
				OPEN cur_7_1 (v_start_date);
				LOOP
					FETCH cur_7_1 INTO emgacntwkrec;
					EXIT WHEN cur_7_1%notfound;
					IF v_first = 'Y' THEN
						p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '33088B', pdeletereason => '�C��33076B �G���ন33088B'
						);
						v_first := 'N';
					END IF;
          --reset qty values ,�N���|�Ainsert �@���F...
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '�C��33076B �G���ন33088B');
				END LOOP;
				CLOSE cur_7_1;
        --33076B > 2 �ন33089B
			ELSE
        --reset qty values ,�N���|�Ainsert �@���F...
				v_first := 'Y';
				OPEN cur_7_1 (v_start_date);
				LOOP
					FETCH cur_7_1 INTO emgacntwkrec;
					EXIT WHEN cur_7_1%notfound;
					IF v_first = 'Y' THEN
						p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '33089B', pdeletereason => '�C��33076B �W�L�G���ন33089B'
						);
						v_first := 'N';
					END IF;
          --reset qty values ,�N���|�Ainsert �@���F...
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '�C��33076B �W�L�G���ন33089B');
				END LOOP;
				CLOSE cur_7_1;
			END IF; --IF v_cnt = 2
		END LOOP;
		CLOSE cur_7;

    --8.�ç����B�j��T�U,�޲z�O�W��1500
		OPEN cur_8;
		LOOP
			FETCH cur_8 INTO emgacntwkrec;
			EXIT WHEN cur_8%notfound;
			p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => 'MA12345678NH', pdeletereason => '���ƺ޲z�O�W��1500'
			);
		END LOOP;
		CLOSE cur_8;

    --9.���`�W�ӳ��W�h(���ѭp)
    --�p��06009C�h�H06012C,�L�h�H06013c��
		OPEN cur_9;
		LOOP
			FETCH cur_9 INTO
				v_start_date,
				v_amt;
			EXIT WHEN cur_9%notfound;
      --�p��06009C�h�H06012C,�L�h�H06013c��
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
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '06012C', pdeletereason => '���G�`�W�ӳ��W�h��'
					|| v_ins_fee_code);
					v_first := 'N';
				END IF;
        --reset qty values ,�N���|�Ainsert �@���F...
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��' || v_ins_fee_code);
			END LOOP;
			CLOSE cur_9_1;
		END LOOP;
		CLOSE cur_9;

    --10.��G�`�W�ֶ��ץ�(�P��)
    --����X���@08001C���Ѽ�(�̰򥻪�,�S���N���ŦX�o�ӳW�h)
		OPEN cur_10;
		LOOP
			FETCH cur_10 INTO v_start_date;
			EXIT WHEN cur_10%notfound;
      --check �O�_��08002C
			OPEN cur_10_1 (v_start_date, '08002C');
			FETCH cur_10_1 INTO emgacntwkrec;
      --�䤣��N���X�^��
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;
      --check �O�_��08003C
			OPEN cur_10_1 (v_start_date, '08003C');
			FETCH cur_10_1 INTO emgacntwkrec;
      --�䤣��N���X�^��
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;
      --check �O�_��08004C
			OPEN cur_10_1 (v_start_date, '08004C');
			FETCH cur_10_1 INTO emgacntwkrec;
      --�䤣��N�O 08001C+08002C+08003C����,�ন08014C
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
        --�R��08001C,08002C,08003C
				OPEN cur_10_1 (v_start_date, '08001C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08002C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08003C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
          --�s�W08014C
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '08014C', pdeletereason => '���G�`�W�ӳ��W�h��08014C'
					);
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08014C');
				END IF;
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --check �O�_��08127C
			OPEN cur_10_1 (v_start_date, '08127C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
        --�R��08001C,08002C,08003C
				OPEN cur_10_1 (v_start_date, '08001C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08002C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08014C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08003C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
          --�s�W08014C
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '08014C', pdeletereason => '���G�`�W�ӳ��W�h��08014C'
					);
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08014C');
				END IF;
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --check �O�_��08006C
			OPEN cur_10_1 (v_start_date, '08006C');
			FETCH cur_10_1 INTO emgacntwkrec;
      --�䤣��N�O 08001C+08002C+08003C+08004C+08127C����,�ন08012C
			IF cur_10_1%notfound THEN
				CLOSE cur_10_1;
        --�R��08001C,08002C,08003C,08004C,08127C
				OPEN cur_10_1 (v_start_date, '08001C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08002C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08003C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08004C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08012C');
				END IF;
				CLOSE cur_10_1;
				OPEN cur_10_1 (v_start_date, '08127C');
				FETCH cur_10_1 INTO emgacntwkrec;
				IF cur_10_1%found THEN
          --�s�W08012C
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '08012C', pdeletereason => '���G�`�W�ӳ��W�h��08012C'
					);
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08012C');
				END IF;
				CLOSE cur_10_1;
				EXIT;
			END IF;
			CLOSE cur_10_1;

      --�q�q����
      --08001C+08002C+08003C+08004C+08127C+08006C����,�ন08011C
      --�R��08001C,08002C,08003C,08004C,08127C,08006C
			OPEN cur_10_1 (v_start_date, '08001C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08002C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08003C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08004C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08127C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08011C');
			END IF;
			CLOSE cur_10_1;
			OPEN cur_10_1 (v_start_date, '08006C');
			FETCH cur_10_1 INTO emgacntwkrec;
			IF cur_10_1%found THEN
        --�s�W08011C
				p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '08011C', pdeletereason => '���G�`�W�ӳ��W�h��08011C'
				);
				p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '���G�`�W�ӳ��W�h��08011C');
			END IF;
			CLOSE cur_10_1;
		END LOOP;
		CLOSE cur_10;

    --���o�ݦX�ഫ�]�w�ɪ����
		OPEN cur_1;
		LOOP
			FETCH cur_1 INTO v_ins_fee_code;
			EXIT WHEN cur_1%notfound;
      --���o�Ӱ��O�X�����ӳW�w
			OPEN cur_2 (v_ins_fee_code);
			LOOP
				FETCH cur_2 INTO bilnhrulesetrec;
				EXIT WHEN cur_2%notfound;
        --A���PB�����o�P�ɥӳ�
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
            --�s�b���o�P�ɥӳ���B���O�X,�GA���o�ӳ�
						IF v_cnt > 0 THEN
              --�R��A�X
              --�����ഫ������
              --�վ���B�^ bil_feemst/EMG_bil_feedtl
							p_deleteacntwk (pcaseno, emgacntwkrec.acnt_seq, '���o�P' || bilnhrulesetrec.ins_fee_code2 || '���ɥӳ�');
						END IF;
					END LOOP;
					CLOSE cur_3;
				END IF; --IF bilnhruleSetREC.Rule_Kind = '1'

        --������
				IF bilnhrulesetrec.rule_kind = '2' THEN
					v_qty := 0;
          --����
					IF bilnhrulesetrec.range_type = '1' THEN
            --
						OPEN cur_4 (v_ins_fee_code);
						LOOP
							FETCH cur_4 INTO v_start_date;
							EXIT WHEN cur_4%notfound;
							v_qty := 0;
              --���X�Ҧ��ŦX�����
							OPEN cur_5 (v_ins_fee_code, v_start_date);
							LOOP
								FETCH cur_5 INTO emgacntwkrec;
								EXIT WHEN cur_5%notfound;
								v_qty := v_qty + emgacntwkrec.qty;
								IF v_qty > bilnhrulesetrec.qty THEN
									p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '�W�L�C�魭���');
								END IF;
							END LOOP;
							CLOSE cur_5;
						END LOOP;
						CLOSE cur_4;
					ELSE
						v_qty := 0;
            --���X�Ҧ��ŦX�����
						OPEN cur_3 (v_ins_fee_code);
						LOOP
							FETCH cur_3 INTO emgacntwkrec;
							EXIT WHEN cur_3%notfound;
							v_qty := v_qty + emgacntwkrec.qty;
							IF v_qty > bilnhrulesetrec.qty THEN
								p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '�W�L�C�������');
							END IF;
						END LOOP;
						CLOSE cur_3;
					END IF; --IF bilnhruleSetREC.Range_Type = '1'
				END IF; --IF bilnhruleSetREC.Rule_Kind = '2'

        --A�X�L��X���নB�X
				IF bilnhrulesetrec.rule_kind = '3' THEN
					v_qty := 0;
          --����
					IF bilnhrulesetrec.range_type = '1' THEN
            --
						OPEN cur_4 (v_ins_fee_code);
						LOOP
							FETCH cur_4 INTO v_start_date;
							EXIT WHEN cur_4%notfound;
              --��X�Ӱ��O��Y�����������,�W�L�~�n�ഫ,���M�S��
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

              --CHECK�P�@�餤�����ƬO�_�W�L���ഫ������,
              --�O�N���R,��COPY�@�����ഫ�����O�X
							IF v_qty >= bilnhrulesetrec.qty THEN
								v_first := 'Y';
                --���X�Ҧ��ŦX�����
								OPEN cur_5 (v_ins_fee_code, v_start_date);
								LOOP
									FETCH cur_5 INTO emgacntwkrec;
									EXIT WHEN cur_5%notfound;
                  --�u���Ĥ@���n�s�WB�����O�X,��L�����n�R���t�Ĥ@��,�u�O�Ĥ@���n����copyB�����O�X��.
									IF v_qty >= bilnhrulesetrec.qty AND v_first = 'Y' THEN
										p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => bilnhrulesetrec.ins_fee_code2, pdeletereason
										=> '�W�L�C�魭���,�ഫ��' || bilnhrulesetrec.ins_fee_code2);
                    --reset qty values ,�N���|�Ainsert �@���F...
										v_first := 'N';
									END IF;
									IF v_qty >= bilnhrulesetrec.qty AND emgacntwkrec.tqty <= v_qty THEN
										p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '�W�L�C�魭���,�ഫ��' || bilnhrulesetrec
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
            --��X�Ӱ��O��Y�����������,�W�L�~�n�ഫ,���M�S��
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

            --CHECK�P�@�餤�����ƬO�_�W�L���ഫ������,
            --�O�N���R,��COPY�@�����ഫ�����O�X
						IF v_qty > bilnhrulesetrec.qty THEN
              --���X�Ҧ��ŦX�����
							OPEN cur_3 (v_ins_fee_code);
							LOOP
								FETCH cur_3 INTO emgacntwkrec;
								EXIT WHEN cur_3%notfound;
                --�u���Ĥ@���n�s�WB�����O�X,��L�����n�R���t�Ĥ@��,�u�O�Ĥ@���n����copyB�����O�X��.
								IF v_qty > bilnhrulesetrec.qty THEN
									p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => bilnhrulesetrec.ins_fee_code2, pdeletereason
									=> '�W�L�C����|�����,�ഫ��' || bilnhrulesetrec.ins_fee_code2);
                  --reset qty values ,�N���|�Ainsert �@���F...
									v_qty := 0;
								END IF;
								p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => '�W�L�C����|�����,�ഫ��' || bilnhrulesetrec
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
    --12.�s�ͨऺ�t���R��
    /*��E�L
    */
    --X������
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
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32002C', pdeletereason => 'X���ĤG�i���K��')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X���ĤG�i���K��');
					emgacntwkrec.ins_fee_code := '32002C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32007C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32008C', pdeletereason => 'X���ĤG�i���K��')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X���ĤG�i���K��');
					emgacntwkrec.ins_fee_code := '32008C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32009C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32010C', pdeletereason => 'X���ĤG�i���K��')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X���ĤG�i���K��');
					emgacntwkrec.ins_fee_code := '32010C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32011C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32012C', pdeletereason => 'X���ĤG�i���K��')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X���ĤG�i���K��');
					emgacntwkrec.ins_fee_code := '32012C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32013C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32014C', pdeletereason => 'X���ĤG�i���K��')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X���ĤG�i���K��');
					emgacntwkrec.ins_fee_code := '32014C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32015C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32016C', pdeletereason => 'X���ĤG�i���K��')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X���ĤG�i���K��');
					emgacntwkrec.ins_fee_code := '32016C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32017C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32018C', pdeletereason => 'X���ĤG�i���K��')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X���ĤG�i���K��');
					emgacntwkrec.ins_fee_code := '32018C';
				END IF;
				IF emgacntwkrec.ins_fee_code = '32022C' THEN
					p_insertacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pinsfeecode => '32023C', pdeletereason => 'X���ĤG�i���K��')
					;
					p_deleteacntwk (pcaseno => pcaseno, pacntseq => emgacntwkrec.acnt_seq, pdeletereason => 'X���ĤG�i���K��');
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

    --���~�T���γ~
		v_program_name     VARCHAR2 (80);
		v_session_id       NUMBER (10);
		v_error_code       VARCHAR2 (20);
		v_error_msg        VARCHAR2 (400);
		v_error_info       VARCHAR2 (600);
		v_source_seq       VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --�]�w�{���W�٤�session_id
		v_program_name                          := 'emg_calculate_PKG.p_deleteAcntWk';
		v_session_id                            := userenv ('SESSIONID');
    --v_source_seq := pPfkey;
		OPEN cur_1;
		FETCH cur_1 INTO emgacntwkrec;
		CLOSE cur_1;

    --�ƨ�@����O���ɤ�
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

    --�ק� EMG_bil_feedtl ��bilfeemst�����B
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

    --���~�T���γ~
		v_program_name     VARCHAR2 (80);
		v_session_id       NUMBER (10);
		v_error_code       VARCHAR2 (20);
		v_error_msg        VARCHAR2 (400);
		v_error_info       VARCHAR2 (600);
		v_source_seq       VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --�]�w�{���W�٤�session_id
		v_program_name                          := 'emg_calculate_PKG.p_insertAcntWk';
		v_session_id                            := userenv ('SESSIONID');
    --v_source_seq := pPfkey;
		OPEN cur_1;
		FETCH cur_1 INTO emgacntwkrec;
		CLOSE cur_1;

    --�ƨ�@����O���ɤ�
		emgoccurtransrec.caseno                 := emgacntwkrec.caseno;
    --emgOccurTransRec.Patient_Id  :=
		emgoccurtransrec.acnt_seq               := emgacntwkrec.acnt_seq;
		emgoccurtransrec.id                     := emgacntwkrec.emblpk;
		emgoccurtransrec.bil_date               := emgacntwkrec.start_date;
		emgoccurtransrec.order_seqno            := emgacntwkrec.seq_no;
    --emgOccurTransRec.Id          := emgAcntWkRec.Order_Seq;
		emgoccurtransrec.discharged             := emgacntwkrec.discharged;
		emgoccurtransrec.create_dt              := emgacntwkrec.keyin_date;
    --�s�ͨ���U�O
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

    --�ק� EMG_bil_feedtl ��bilfeemst�����B
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

  --�P�_�O�_���N�i�a��,�ϥ�bill��

  --�ۥI�]������(�a��),�S���վ�
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

    --���~�T���γ~
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --�]�w�{���W�٤�session_id
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

      --�٭n����϶�
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

  --���o��騭���O
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
    --���~�T���γ~
		v_program_name   VARCHAR2 (80);
		v_session_id     NUMBER (10);
		v_error_code     VARCHAR2 (20);
		v_error_msg      VARCHAR2 (400);
		v_error_info     VARCHAR2 (600);
		v_source_seq     VARCHAR2 (20);
		e_user_exception EXCEPTION;
	BEGIN
    --�]�w�{���W�٤�session_id
		v_program_name   := 'emg_calculate_PKG.f_getNhRangeFlag';
		v_session_id     := userenv ('SESSIONID');
		OPEN cur_2;
		FETCH cur_2 INTO emgcaserec;
		CLOSE cur_2;

    --RETURN LABI/CIVC/�S�� ������
		IF pfinflag = '1' THEN
      /*
      OPEN CUR_1;
      FETCH CUR_1 INTO tmpFincalRec;
      CLOSE CUR_1;
      RETURN tmpFincalRec.Fincalcode;
      */
      -- �אּ�@�Ө����쩳
			IF emgcaserec.emg1fncl = '7' THEN
				RETURN 'LABI';
			ELSE
				RETURN 'CIVC';
			END IF;
		ELSIF pfinflag = '2' THEN
      --�����t��N�X001-009, 902 �K�����t��
      --�s�WNHI7 (906) by kuo 20121212
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
				IF emgcaserec.emg2fncl = 'G' THEN --�s�Wĵ����������ŶԤH���������@��I��סiG�j���ⳡ���t��:NHIA by kuo 20190422
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
    --���~�T����
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
    --�]�w�{���W�٤�session_id
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

    --�R���W�@����J��occur��� IF IMSDB HAS DATA
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
    --�NIMSDB EMGOCCUR ��J
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

      --IDEP �Ȯɥ����J BY KUO 990629
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
    --�ܼƫŧi��
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
			nhsppfcd = ppfkey; --�D�p���X�P�l�p���X�������ɡA�䤤�������X
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

    --���~�T����
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
    --�]�w�{���W�٤�session_id
		v_program_name   := 'p_emgOccurByCase';
		v_session_id     := userenv ('SESSIONID');

    --�R���W�@����J��occur���
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

      --�Hbilltemp����bltmcomb flag �ӧP�_�O�_���զX��
			IF v_comb_flag = 'Y' THEN

        --�P�_spec 
				t_spfg := special_code_check (biloccurrec.emchcode);

        --NORMAL_ROUTINE   
				IF t_spfg = '0' THEN
					IF v_nhspdefg = '2' THEN

            --���oorder_tmp
						BEGIN
							SELECT
								orflag
							INTO v_orflag
							FROM
								cpoe.ordlabexam
							WHERE
								ordseq = biloccurrec.ordseq;

              /*
              --���o�ӽЧǸ�
              select ordapno 
              into v_ordapno
              from cpoe.common_order 
              where ordseq = bilOccurRec.ORDSEQ;

              --�������綵�ؽs�X orflag
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
              --����쬰100,�אּ1000 FOR COMBO MORE THAN 100
							biloccurrec.emblpk := 'C' || pcaseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 13) || MOD (v_seqno, 1000
							);
                                           --14) || mod(v_seqno, 100);
							IF substr (v_orflag, vsnhspctrec.nhsindex + 1, 1) = '1' AND vsnhspctrec.nhspit IS NOT NULL THEN
								biloccurrec.ordseq     := rtrim (biloccurrec.ordseq);
								biloccurrec.emchcode   := rtrim (vsnhspctrec.nhspit);

                --����X�w��
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
              --����쬰100,�אּ1000 FOR COMBO MORE THAN 100
							biloccurrec.emblpk     := 'C' || pcaseno || substr (TO_CHAR (systimestamp, 'YYYYMMDDHH24MISSFF'), 1, 13) || MOD (v_seqno, 1000)
							;
                                           --14) || mod(v_seqno, 100);
							biloccurrec.ordseq     := rtrim (biloccurrec.ordseq);
							biloccurrec.emchcode   := rtrim (bilspctdtlrec.child_code);

              --����X�w��
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
          --����쬰100,�אּ1000 FOR COMBO MORE THAN 100
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

  --�զX���S��W�hcehck
	FUNCTION special_code_check (
		ppfkey VARCHAR2
	) RETURN VARCHAR2 IS
		t_fg              VARCHAR2 (01) := '0';
    --���~�T����
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
    --�]�w�{���W�٤�session_id
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

  --�����O�J�b
	PROCEDURE emgregfee (
		pcaseno VARCHAR2
	) IS
    --���~�T���γ~
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
    --�]�w�{���W�٤�session_id
		v_program_name   := 'emg_calculate_PKG.EMGREGFEE';
		v_session_id     := userenv ('SESSIONID');
		SELECT
			*
		INTO patemgcaserec
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = pcaseno;

    --�u�������O
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

  --�w���b
  /*PROCEDURE pOverDueOrder(pCaseNo varchar2) IS
    --��X���񤣬O�ġA�B��ñ��(<38)         
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

    --���~�T����
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

          --�P�_�O�_���j���۶O���� �ίf�w���۶O����
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

          --�f�w�����O����                   
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

              --�줣����,���i��O�۶O�����ί¦۶O��      
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

    --�]�w�{���W�٤�session_id
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
    --�w���b
  --���޿�O�N���B�����bfeedtl��,�קאּ�����N�b�ڥ[�Jemg_occur��(update by amber 20110426)
	PROCEDURE poverdueorder (
		pcaseno VARCHAR2
	) IS
    --��X���񤣬O�ġA�B��ñ��(<38),ADD OR ���w�� BY KUO 1000509
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

    --���~�T����
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
    --�]�w�{���W�٤�session_id
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

        --v_Emg_Per��@����
				getemgper (pcaseno, ppfkey => commonorderrec.pfcode, pfeekind => v_fee_type, pemgflag => v_emg, pfncl => emgcaserec.emg1fncl,
				ptype => '1', pdate => SYSDATE, emg_per => v_emg_per, holiday_per => vholiday_per, night_per => vnight_per, child_per => vchild_per
				, urgent_per => vurgent_per, operation_per => voperation_per, anesthesia_per => vanesthesia_per, materials_per => vmaterials_per
				);

        --�P�_�O�_���j���۶O���� �ίf�w���۶O����,�۶O����
				IF commonorderrec.ordpayfg = 'S' OR emgcaserec.emg1fncl = '9' THEN
					v_amt                := v_price * 1;
					v_pfincode           := 'CIVC';
					v_emg                := 'R';
					emgoccrec.emchanes   := 'PR'; --20160815 �[�Jby kuo 
				ELSE
					emgoccrec.emchanes := '';
				END IF;

        --�f�w�����O����
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
            --�줣����,���i��O�۶O�����ί¦۶O��
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

        --�P�_�O�_���զX��
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
				emgoccrec.emocdate   := commonorderrec.orddttm; --v_date; --�令COMMON_ORDER �� ORDDTTM        
				emgoccrec.embldate   := SYSDATE; --v_date; --�אּSYSDATE
				emgoccrec.ordseq     := commonorderrec.ordseq;
				emgoccrec.emchrgcr   := '+';
				emgoccrec.emchcode   := commonorderrec.pfcode;
				emgoccrec.emchtyp1   := v_fee_type;
				emgoccrec.emchqty1   := 1;
				emgoccrec.emchamt1   := v_amt;
				emgoccrec.emchtyp2   := '99';
				emgoccrec.emchtyp4   := '99';
				emgoccrec.emchemg    := v_emg;
				emgoccrec.emchidep   := '';--emgcaserec.emgns; --�j��J�k�ݬ�(4 BYTES)
				emgoccrec.emchstat   := emgcaserec.emgns; --���Ӧa�I(4 BYTES)
				emgoccrec.emocomb    := v_comb_flag;
				emgoccrec.emocsect   := emgcaserec.emgns; --�p����O(4 BYTES)
				emgoccrec.emocns     := emgcaserec.emgns; --�f��(4 BYTES)
				emgoccrec.emoedept   := emgcaserec.emgns; --�}�߬�O(4 BYTES, EMG ONLY)
				emgoccrec.hisst      := 'S';
				emgoccrec.emuserid   := 'OVRORDER';
				emgoccrec.card_no    := 'OVRORDER';
				INSERT INTO cpoe.emg_occur VALUES emgoccrec;
        --INSERT INTO BIL_CALLREPORT_LOG(CASENO,DATE_CALLED,REPORT,MSG,HTTP_STRING)
        --VALUES(PCASENO,SYSDATE,'OVERORDER',emgoccrec.emchcode,emgoccrec.ordseq);
        --�f�z�����X by kuo 20161021
				IF emgoccrec.emocdate >= TO_DATE ('20161101', 'YYYYMMDD') AND emgoccrec.emchcode IN (
					'94002030',
					'94002031'
				) THEN
					emgoccrec.emblpk     := f_getemg_occrpk (emgoccrec.emblpk);
					emgoccrec.emchcode   := 'PATH0000';--�����X
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

  --��E�C��b�ڭ���(�]���妬�ݨC�鵲��,�ݨC��N���o�ͱb�ڪ�CASENO����)(add by amber 20110413)  
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
    --�W�[LOG by Kuo 20130416
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
    --�R�����w�����������O�����b�ڪ�caseno
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
    --�W�[LOG by Kuo 20130416
		UPDATE bil_daliyjoblog
		SET
			finished_flag = 'Y',
			last_update_date = SYSDATE,
			last_updated_by = 'BILLING',
			log_msg = TO_CHAR (SYSDATE - 1, 'YYYYMMDD') || ' ��E�L�b���\!'
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

  --emg_occur�ƥ�(add by amber 20110412) 
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
  --2012.03.20 �A�N�쥻��max�g�k�令rownum�g�k
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
				TRIM (biling_common_pkg.f_return_date7 (SYSDATE)), --�������v�b�إߤ��(����~YYYMMDD)
				TO_CHAR (SYSDATE, 'hh24MI'),   --�������v�b�إ߮ɶ�(�ɤ�)
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

  --��s����� - ����b�ګ�O�_�w�L��کάO��ڪ��B������(add by amber 20110420) 
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
        --����ثe�̷s���b����ú���B
				SELECT
					SUM (round (nvl (tot_self_amt, 0) + nvl (tot_gl_amt, 0)))
				INTO v_tot_amt
				FROM
					emg_bil_feemst
				WHERE
					caseno = pcaseno;

        --�ˬd����ɤ����B�O�_�ۦP,�Y���ۦP,�h�n��s����ɸ��
				IF abs (emgdebtrec.total_self_amt - v_tot_amt) > 1 THEN
					v_debt_amt := v_tot_amt - emgdebtrec.total_paid_amt;
					UPDATE emg_bil_debt_rec
					SET
						total_self_amt = v_tot_amt,
						debt_amt = v_debt_amt
					WHERE
						caseno = pcaseno;
          --DBMS_OUTPUT.put_line(pcaseno || ':' || v_tot_amt || ',' ||v_debt_amt);

          --�Y��ڪ��B��0,��ܭ쥻��ڦ���鶴����w����ú�O,�N��ڪ��A�אּ'C'-����
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

  --�l�ܹw������
	PROCEDURE t_ovrordlog (
		pcaseno VARCHAR2
	) IS
		v_error_code   VARCHAR2 (20);
		v_error_info   VARCHAR2 (600);
    --���|�٦b�}�ߪ��A������
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
    --�զX�X���
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
         --�䤣��D���A��զX��
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
  --�b�ȥ���(�ۥI��0)�����[�J EMG_BIL_ACNT_WK BY KUO 1000601
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

  --��E�ӳ��e���� BY KUO 1000628
	PROCEDURE emg_recalmon (
		pmonth VARCHAR2
	) IS
    --PMONTH���|��CASE
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

  --��E���u�D�n�{��--�j��H���O�p�� BY KUO 1000808
	PROCEDURE main_process_labi (
		pcaseno       VARCHAR2,
		poper         VARCHAR2,
		pmessageout   OUT VARCHAR2
	) IS
    --�ܼƫŧi��

    --���~�T���γ~
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
    --�W�[HIS��ڤ����⪺�P�_(add by amber 20110401)
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

      --�]�w�{���W�٤�session_id
			v_program_name   := 'emg_calculate_PKG_A.Main_Process_LABI';
			v_session_id     := userenv ('SESSIONID');
			v_source_seq     := trim (pcaseno);

      --�b����e���N��caseno��emg_occur�ƥ�
      --dbms_output.put_line('bkOccur');
			bkoccur (trim (pcaseno));

      --�R���즳�p����
      --dbms_output.put_line('initdata');
			initdata (trim (pcaseno));

      --�i�}�����O
      --dbms_output.put_line('extanfin');
      --extandfin(trim(pCaseNo));
      --�u�Ҽ{�����O(EMG1FNCL=7)����k,�w�g���|�~�A��
      --�W�[�@��PAT_EMG_FINANCL DATA, �⧹��R��
      --PAT_EMG_CASEN.EMG1FNCL�אּ 7,�⧹���^
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

      --�J�T�w�O�Ψ�emg_occur
      --dbms_output.put_line('EMGFixFees');
			emgfixfees (trim (pcaseno));

      --�w���J��
      --dbms_output.put_line('pOverDueOrder');
      --POVERDUEORDER(TRIM(PCASENO));
      --�qIMSDB ��JHIS�W�b��
      --dbms_output.put_line('emgOccurFromImsdb');
			emgoccurfromimsdb (trim (pcaseno));

      --need add�Ҷq�X�ֶ��D���A��X�ֶ����Ӷ����w���ζO�����O�v�@�s�W�Jemg_occur�A�A�N�X�ֶ��D���R��
      --dbms_output.put_line('p_emgOccurByCase');
			p_emgoccurbycase (pcaseno => TRIM (pcaseno));

      --trace log to billtemp_leave
      --SAVEOVR2BLTMP(PCASENO);
      --�p����u
      --dbms_output.put_line('CompAcntWk');
			compacntwk (trim (pcaseno), poper);

      --�S���A�������վ�
      --dbms_output.put_line('p_receivableComp');
			p_receivablecomp (pcaseno => TRIM (pcaseno));

      --��s����� - ����b�ګ�O�_�w�L��کάO��ڪ��B������(add by amber 20110420)   
      --p_debt_check(pCaseNo => trim(pCaseNo));

      --�Nemg_occur�w����ƧR��
			DELETE cpoe.emg_occur
			WHERE
				caseno = TRIM (pcaseno)
				AND
				emuserid = 'OVRORDER';
			COMMIT WORK;
      --�[�J�ۥI��0���O��FOR �妬
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

--��������p��ΡA���½�s BY KUO 20121108
  --���O���I��=���O��*1.63 20151102 �H�ᬰ 2.21 request by ��������p�� add by kuo
  --�۶O=�۶O*1.3 20151015 �H�ᬰ 1.7 request by ��������p�� add by kuo
  --���������I��b�۶O(�t�f�жO�A�@�z�O)
  --�L�ĨƪA�ȶO
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
    --��CPOE.DBPFILE�w��
		CURSOR cur_dbpfile_price (
			ppfkey VARCHAR2
		) IS
		SELECT
			pfprice1
		FROM
			cpoe.dbpfile
		WHERE
			pfkey = ppfkey;
    --��pfmlog
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
    --��S���O��PFCLASS(�t���v��)���L"LABI���"
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
    --�������S999 BY KUO 20121128
    --�Y�[�JS998,�ۦP�W�h�A�u�n�NCIVC�令S998�Y�i
    --�[�JS995,�ۦP�W�h�A�u�n�NCIVC�令S995�Y�i by kuo 20150721
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
      --20151102��վ㬰 1.7 by kuo 20151014
			IF acntwk_rec.bildate >= TO_DATE ('20151102', 'YYYYMMDD') THEN
				emper := 1.7;
			ELSE
				emper := 1.3;
			END IF;
      --��DBPFILE����
			OPEN cur_dbpfile_price (acntwk_rec.price_code);
			FETCH cur_dbpfile_price INTO sprice;
			CLOSE cur_dbpfile_price;
      --��PFMLOG
			OPEN cur_pfmlog (acntwk_rec.price_code, acntwk_rec.bildate, sprice);
			FETCH cur_pfmlog INTO pfmlogrec;
			IF cur_pfmlog%found THEN
				sprice := pfmlogrec.pflprice;
			END IF;
			CLOSE cur_pfmlog;
      --��PFCLASS,PFHISCLS���O���P�����ۥI��
			OPEN cur_pfclass_labi (acntwk_rec.price_code, acntwk_rec.bildate);
			FETCH cur_pfclass_labi INTO
				pfcselprice,
				pfcnhiprice;
			IF cur_pfclass_labi%found THEN
				IF pfcselprice = 0 AND pfcnhiprice > 0 THEN
					sprice := pfcnhiprice;
            --20151102��վ㬰 2.21 by kuo 20151014
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
      --�DCU�f�жE��O�@��1500,��E�L
      --�ĨƪA�ȶO����
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
      --�@�붵��
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
    --�ק�BIL_FEEMST�PBIL_FEEDTL,�]���u��CIVC,�ҥH���S�O���X�F
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

  --��E���y�� by kuo 20160405
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

	--��20160601 �}�l by kuo 20160405 
		IF patemgcase.emgdt < TO_DATE ('20160601', 'YYYYMMDD') THEN
			return;
		END IF;

  --�D���O�������� by kuo 20160518
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

    --��X��J
    --��|level �ϥ� OPDUSR.BASHOSP
    --NHIROOT_REC.INHOSPNO  := PATEMGCASE.EMGINHOSPNO;                -- ��J�|��or���
    --INHOSPNO,OUTHOSPNO
    --��J
    --�u�����W
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
				emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --�j��J�k�ݬ�(4 BYTES)
				emgoccrec.emchstat   := patemgcase.emgns; --���Ӧa�I(4 BYTES)
				emgoccrec.card_no    := 'EMPRIZE'; --��E���y�A���C�J�b�ڭp�� by kuo 20160517
				emgoccrec.emocomb    := 'N';
				emgoccrec.emapply    := 'N';        --��E���y�A���C�J�b�ڭp�� by kuo 20160517
				emgoccrec.emocsect   := patemgcase.emgsect; --�p����O(4 BYTES)
				emgoccrec.emocns     := patemgcase.emgns; --�f��(4 BYTES)
				emgoccrec.emoedept   := patemgcase.emgsect; --�}�߬�O(4 BYTES, EMG ONLY)
				emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert '||PPFKEY||' to date:'||v_date);
          --dbms_output.put_line('��J insert');
				INSERT INTO cpoe.emg_occur VALUES emgoccrec;
				COMMIT WORK;
			END IF;
		END IF;
    --��X
    --�u�����U
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
         --P4605B �� UP by kuo 20150811
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
				emgoccrec.emchidep   := '';--patemgcaseRec.EMGSECT; --�j��J�k�ݬ�(4 BYTES)
				emgoccrec.emchstat   := patemgcase.emgns; --���Ӧa�I(4 BYTES)
				emgoccrec.card_no    := 'EMPRIZE'; --��E���y�A���C�J�b�ڭp�� by kuo 20160517
				emgoccrec.emocomb    := 'N';
				emgoccrec.emapply    := 'N';        --��E���y�A���C�J�b�ڭp�� by kuo 20160517
				emgoccrec.emocsect   := patemgcase.emgsect; --�p����O(4 BYTES)
				emgoccrec.emocns     := patemgcase.emgns; --�f��(4 BYTES)
				emgoccrec.emoedept   := patemgcase.emgsect; --�}�߬�O(4 BYTES, EMG ONLY)
				emgoccrec.hisst      := 'S'; --S:HIS OK, F:HIS FAIL, N:NOT SENT YET
          --dbms_output.put_line('insert '||PPFKEY||' to date:'||v_date);
          --dbms_output.put_line('��X insert');
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

    -- �]�w 1060 ��b����
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

	-- �վ� 1060 �b�ڤ��u
	PROCEDURE adjust_1060_acnt_wk (
		i_ecaseno VARCHAR2
	) IS
	BEGIN
		-- 1060 �S���ͮĴ������[�\��q��E����
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
			-- �����O�զ� 1060 ���u���
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

    -- ����O�Ω�����
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

		-- ���㳡���t��
		recalculate_copay (i_caseno);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
	END;

    -- ���㳡���t��
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
		-- ���o��E�D��
		SELECT
			*
		INTO r_pat_emg_casen
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = i_ecaseno;

		-- ���o�����t��W�h
		OPEN c_pf_baserule ('E', r_pat_emg_casen.emgdt);
		FETCH c_pf_baserule INTO r_pf_baserule;
		CLOSE c_pf_baserule;

		-- �p�ⰷ�O���B
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

        -- �p�ⳡ���t����B
		l_copay_amt   := l_labi_amt;

        -- ���o�˶˵���
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

            -- ���̫Ყ�ʤ@��
			EXIT;
		END LOOP;

        -- �����t��W��
		l_copay_lmt   :=
			CASE
				WHEN l_triage_degree IN (
					'1',
					'2'
				) THEN
					r_pf_baserule.emg_pay_lmt3
				ELSE r_pf_baserule.emg_pay_lmt1
			END;
        -- ���쳡���t��W��
		IF r_pat_emg_casen.emgcopay = 'E00' THEN
			l_copay_lmt := r_pf_baserule.emg_pay_lmt2;
		END IF;

        -- �W�L�W���H�W���p
		IF l_copay_amt > l_copay_lmt THEN
			l_copay_amt := l_copay_lmt;
		END IF;

        -- �馩�����t��
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

            -- �u���̰��馩���
			EXIT;
		END LOOP;

        -- �g�J�����t����B
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

		-- �վ� 1060 �����t��
		adjust_1060_copay (r_pat_emg_casen.ecaseno);
	END;

	-- �վ� 1060 �����t��
	PROCEDURE adjust_1060_copay (
		i_ecaseno VARCHAR2
	) IS
	BEGIN
		-- 1060 �S���ͮĴ������[�\��q��E����
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
			-- �����t��զ� 1060 ���u���
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

    -- ����O�ΥD��
	PROCEDURE recalculate_feemst (
		i_ecaseno    VARCHAR2,
		i_end_date   DATE
	) IS
		r_pat_emg_casen       common.pat_emg_casen%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
		r_emg_bil_feemst      emg_bil_feemst%rowtype;
	BEGIN
        -- ���o��E�D��
		SELECT
			*
		INTO r_pat_emg_casen
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = i_ecaseno;

        -- �R���O�ΥD��
		DELETE FROM emg_bil_feemst
		WHERE
			caseno = r_pat_emg_casen.ecaseno;

        -- ��l�ƶO�ΥD��
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
        -- ��ʧɤѼ�
		r_emg_bil_feemst.emg_bed_days       := trunc (r_emg_bil_feemst.end_date) - trunc (r_emg_bil_feemst.st_date);
		IF r_emg_bil_feemst.emg_bed_days = 0 THEN
			r_emg_bil_feemst.emg_bed_days := 1;
		END IF;
        -- �p��Ĥ@���q���O���B
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

        -- �p��Ĥ@���q�����t��
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

        -- �p��ۥI�����t��
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

        -- �p��ۥI�۶O����
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

        -- �p��S���`�B
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

        -- �g�J�O�ΥD��
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

	-- �h��E�b�ܦ�|�b�]�̭p������^
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
		-- ���X��|�D��
		SELECT
			*
		INTO r_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = i_hcaseno;

		-- ���X��|�b�ȥD��
		SELECT
			*
		INTO r_bil_root
		FROM
			bil_root
		WHERE
			caseno = r_pat_adm_case.hcaseno;

		-- ���o��E�D��
		SELECT
			*
		INTO r_pat_emg_casen
		FROM
			common.pat_emg_casen
		WHERE
			ecaseno = i_ecaseno;

		-- �ˬd�O�_�w�h�b
		OPEN c_emg_occur (r_pat_emg_casen.ecaseno, i_sta_emocdate, i_end_emocdate);
		LOOP
			FETCH c_emg_occur INTO r_emg_occur;
			EXIT WHEN c_emg_occur%notfound;
			IF r_emg_occur.emuserid = 'NHIMOVE' THEN
				o_msg := '��E�Ǹ��G' || r_emg_occur.caseno || '�A�p������G' || r_emg_occur.emocdate || '�A�w����L�h�b';
				return;
			END IF;
		END LOOP;
		CLOSE c_emg_occur;

		-- �h�b
		OPEN c_emg_occur (r_pat_emg_casen.ecaseno, i_sta_emocdate, i_end_emocdate);
		LOOP
			FETCH c_emg_occur INTO r_emg_occur;
			EXIT WHEN c_emg_occur%notfound;
			IF 
			-- emapply != 'N'
			 (r_emg_occur.emapply != 'N' OR r_emg_occur.emapply IS NULL) 
			-- �D PR
			 AND (r_emg_occur.emchanes != 'PR' OR r_emg_occur.emchanes IS NULL 
				-- �S���O�L�׬O�_ PR ���h
			 OR r_emg_occur.emchtyp1 = '14') 
			-- �D�f�жO�B��v�O�B�Įv�O�B�@�z�O
			 AND trim (r_emg_occur.ordseq) != '0000' THEN
				l_cnt                  := l_cnt + 1;

				-- �J��|�b
				order_bill ('A', -- �N�E�O (A/E)
				 r_pat_adm_case.hcaseno, -- �N�E�Ǹ�
				 r_emg_occur.emocdate, -- �p����
				 r_emg_occur.ordseq, -- ����Ǹ�
					CASE
						WHEN trunc (SYSDATE, 'MI') > r_bil_root.dischg_date THEN
							'Y'
						ELSE 'N'
					END, -- ���|�ɱb���O (Y/N)
					 r_emg_occur.emchcode, -- �p���X
					 r_emg_occur.emchrgcr, -- ���t�� (+/-)
					 r_emg_occur.emchtyp1, -- �O�����O
					 TO_CHAR (r_emg_occur.emchqty1), -- �ƶq
					 TO_CHAR (r_emg_occur.emchamt1), -- �`���B
					 r_emg_occur.emchemg, -- ��@�[�� (E/R)
					CASE i_is_charge_flag
						WHEN 'N' THEN
							'DR'
						ELSE r_emg_occur.emchanes
					END, -- �j��۶O�Υu�ӳ����p�����O (PR/DR)
					 NULL, -- IV PUMP(Y/N)
					 r_emg_occur.emchidep, -- �j��J�k�ݬ�
					 r_emg_occur.emrescod, -- �h�b�z��
					 r_emg_occur.emchstat, -- ���Ӧa�I
					 r_emg_occur.caseno, -- �J�b�̥d�� (�h�b�Ϋ�E�Ǹ��@�J�b�̥d��)
					 r_emg_occur.emorcat, -- OR catalog
					 r_emg_occur.emorcomp, -- �]�ֵo�g���ͪ��b (Y/N)
					 r_emg_occur.emororno, -- ��N�ĴX�M
					 NULL, -- discharge bring back (Y/N)
					 r_emg_occur.emocomb, -- �զX�� (Y/N)
					 r_emg_occur.emocdist, -- ��b���
					 r_emg_occur.emocsect, -- �p����O
					 r_emg_occur.emocns, -- �@�z��
					 r_emg_occur.emoedept, -- �}�߬�O 
					 o_msg, -- ��X�T��
					 'N' -- �۰� commit (Y/N)
					);

				-- �R��E�b
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

	-- �h��E�b�ܦ�|�b�]������Ǹ��^
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
		-- ���X��|�D��
		SELECT
			*
		INTO r_pat_adm_case
		FROM
			common.pat_adm_case
		WHERE
			hcaseno = substr (i_aordseq, 2, 8);

		-- ���X��|�b�ȥD��
		SELECT
			*
		INTO r_bil_root
		FROM
			bil_root
		WHERE
			caseno = r_pat_adm_case.hcaseno;

		-- ���o��E�D��
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

			-- �J��|�b
			order_bill ('A', -- �N�E�O (A/E)
			 r_pat_adm_case.hcaseno, -- �N�E�Ǹ�
			 r_emg_occur.emocdate, -- �p����
			 i_aordseq, -- ����Ǹ�
				CASE
					WHEN trunc (SYSDATE, 'MI') > r_bil_root.dischg_date THEN
						'Y'
					ELSE 'N'
				END, -- ���|�ɱb���O (Y/N)
				 r_emg_occur.emchcode, -- �p���X
				 r_emg_occur.emchrgcr, -- ���t�� (+/-)
				 r_emg_occur.emchtyp1, -- �O�����O
				 TO_CHAR (r_emg_occur.emchqty1), -- �ƶq
				 TO_CHAR (r_emg_occur.emchamt1), -- �`���B
				 r_emg_occur.emchemg, -- ��@�[�� (E/R)
				 r_emg_occur.emchanes, -- �j��۶O�Υu�ӳ����p�����O (PR/DR)
				 NULL, -- IV PUMP(Y/N)
				 r_emg_occur.emchidep, -- �j��J�k�ݬ�
				 r_emg_occur.emrescod, -- �h�b�z��
				 r_emg_occur.emchstat, -- ���Ӧa�I
				 r_emg_occur.emuserid, -- �J�b�̥d��
				 r_emg_occur.emorcat, -- OR catalog
				 r_emg_occur.emorcomp, -- �]�ֵo�g���ͪ��b (Y/N)
				 r_emg_occur.emororno, -- ��N�ĴX�M
				 NULL, -- discharge bring back (Y/N)
				 r_emg_occur.emocomb, -- �զX�� (Y/N)
				 r_emg_occur.emocdist, -- ��b���
				 r_emg_occur.emocsect, -- �p����O
				 r_pat_adm_case.hnursta, -- �@�z��
				 NULL, -- �}�߬�O 
				 o_msg, -- ��X�T��
				 'N' -- �۰� commit (Y/N)
				);

			-- �R��E�b
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

	-- �]�ݧR���^�h��E�b�ܦ�|�b�]������Ǹ��^
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
    --�J��|�b
		OPEN get_emg_occur (pecaseno, eordseq);
		LOOP
			FETCH get_emg_occur INTO emgoccrec;
			EXIT WHEN get_emg_occur%notfound;
      --�J��|�b��
      --�DPR�~�J�b(FOR NHI)
			order_bill ('A',                    --��|(A)��E(E)
			 phcaseno,                --��|���άO��E��
			 emgoccrec.emocdate,     --�p����,DATE TIME
			 aordseq,       --����Ǹ�(FULL COMON_ORDER KEY 15 BYTES)
			 'N',                    --���|��J�b(Y/N)
			 emgoccrec.emchcode,     --�p���X
			 emgoccrec.emchrgcr,     --�[�h�b(+/-)
			 emgoccrec.emchtyp1,     --�p�����O(01-40)
			 lpad (TO_CHAR (emgoccrec.emchqty1), 4, '0'), --�ƶq(4BYTES)
			 TO_CHAR (emgoccrec.emchamt1),             --�`���B(7.1)
			 emgoccrec.emchemg,                       --�O�_��@(E��@/R�D��@)
			 emgoccrec.emchanes,--'DR',         --�¾K�覡(�pLA)/���ʵ��O(PR)(2 BYTES) DR IS NHI ONLY
			 '',           --IV PUMP(Y/N)
			 emgoccrec.emchidep, --�j��J�k�ݬ�(4 BYTES)
			 emgoccrec.emrescod, --�h�b�z��LCOMMENT KEY(6 BYTES)
			 emgoccrec.emchstat, --���Ӧa�I(4 BYTES)
			 emgoccrec.emuserid, --�J�b��(���ഫ��ID�d��)(8 BYTES)
			 emgoccrec.emorcat,  --OR. ORDER CATALOG(1/2/3/4/5)(1 BYTE)
			 emgoccrec.emorcomp, --�O�_�]�ֵo�g�Ҳ��ͪ��b(Y/N)(1 BYTE)
			 emgoccrec.emororno, --��N�ĴX�M(1 BYTE)
			 '',           --DISCHARGE BRING BACK(Y/NULL)(1 BYTE)
			 emgoccrec.emocomb,  --�O�զX��(Y/N)(1 BYTE)
			 emgoccrec.emocdist, --��b��v(4 BYTES)
			 emgoccrec.emocsect, --�p����O(4 BYTES)
			 patadmcase.hnursta, --EMGOCCREC.EMOCNS,   --�f��(4 BYTES)
			 '',           --�}�߬�O(4 BYTES, EMG ONLY)
			 pmessage      --RETURN MESSAGE,(0 IS OK ELSE ERROR)
			);
		END LOOP;
		CLOSE get_emg_occur;
		COMMIT WORK;
    --�J�t�b
		emg_minus_occ (pecaseno, eordseq);
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line ('EMG_ORD2ADM_ORD_BIL:' || v_error_code || ',' || v_error_info || ',A:' || aordseq || ',E:' || eordseq);
			ROLLBACK WORK;
	END;

	-- �]�ݧR���^emg_ord2adm_ord_bil �R�b��
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
      --EMBLPK�ק�
			v_seq                := v_seq + 1;
      --EMGOCCREC.EMBLPK:='D' || ECASENO || SUBSTR(TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISSFF'),1,13) || MOD(V_SEQ, 1000);
			emgoccrec.emblpk     := 'M' || substr (emgoccrec.emblpk, 2, length (emgoccrec.emblpk) - 1);
			emgoccrec.embldate   := SYSDATE;
      --USER �אּ�ӳ�NHIMOVE
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
