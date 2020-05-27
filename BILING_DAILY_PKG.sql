CREATE OR REPLACE PACKAGE biling_daily_pkg IS
  --���~�T����
	v_program_name VARCHAR2 (80);
	v_session_id NUMBER (10);
	v_error_code VARCHAR2 (20);
	v_error_msg VARCHAR2 (400);
	v_error_info VARCHAR2 (600);
	v_source_seq VARCHAR2 (20);
	e_user_exception EXCEPTION;

      --��J��|�f�w�򥻸�� pat_adm_case into bil_root       
      --PROCEDURE ImportBilRootBatch(pDate date);      

      --��s�b�|���f�w�򥻸��
	PROCEDURE updatebilroot;

      --��Jbiltemp��Ʀ�biloccur
	PROCEDURE importbiltempbath (
		pdate VARCHAR2
	);
	PROCEDURE adddailyservicefeeforcase (
		i_hcaseno    VARCHAR2,
		i_bil_date   DATE
	);

      --�g�J�C��T�w�O�ζibilOccur
	PROCEDURE adddailyservicefee (
		psysdate DATE
	);

      --�g�J�C��T�w�O�ζibilOccur
	PROCEDURE adddailyservicefee1 (
		psysdate DATE
	);

      --��|�b�Ȥ鵲�@�~
	PROCEDURE bilingdailybatch (
		pdate DATE
	);
	PROCEDURE expandbildate (
		i_hcaseno    VARCHAR2,
		i_bil_date   DATE
	);

      --��Jbiltemp_leave��Ʀ�biloccur
	PROCEDURE importbiltempleave (
		pcaseno VARCHAR2
	);

      --�s�W�b�ɩ���
	PROCEDURE insertbiloccur (
		pcaseno    VARCHAR2,
		ppatnum    VARCHAR2,
		ppfkey     VARCHAR2,
		pbildate   DATE,
		pward      VARCHAR2,
		pbedno     VARCHAR2
	);

      --�s�W�b�ɩ���
      --for diet
	PROCEDURE insertbiloccurfordiet (
		pcaseno    VARCHAR2,
		pbildate   DATE
	);
	PROCEDURE insertbiloccurfordiet_backup (
		pcaseno    VARCHAR2,
		pbildate   DATE
	);
	PROCEDURE insertbiloccurfordiet_new (
		pcaseno    VARCHAR2,
		pbildate   DATE
	);

      --�զX���S��W�hcehck
	FUNCTION special_code_check (
		ppfkey VARCHAR2
	) RETURN VARCHAR2;

      --�C��妸�C�L����
	PROCEDURE print_daily_report (
		puser VARCHAR2
	);

      --��ڤ뵲�@�~_�妸
	PROCEDURE p_debt_batch (
		pstartdate   DATE,
		penddate     DATE
	);

      --��ڤ뵲�@�~_��|��
	PROCEDURE p_debt_bycase (
		vcaseno     VARCHAR2,
		p_out_msg   OUT VARCHAR2
	);
	PROCEDURE p_diet_inadm (
		i_hcaseno     VARCHAR2,
		i_bill_date   DATE
	);

      --�s,�����JBILLTEMP1 BY KUO 1001215,���ޤѼƥ����J�b
	PROCEDURE p_diet_inadm_bycase (
		pcaseno VARCHAR2
	);
END;

/


CREATE OR REPLACE PACKAGE BODY biling_daily_pkg IS

  --��Jbiltemp��Ʀ�biloccur
	PROCEDURE importbiltempbath (
		pdate VARCHAR2
	) IS
     --�ܼƫŧi��
		billtemprec        billtemp1%rowtype;
		biloccurrec        bil_occur%rowtype;
		bilrootrec         bil_root%rowtype;
		CURSOR cur_1 IS
		SELECT
			billtemp1.caseno
		FROM
			billtemp1
		WHERE
			billtemp1.upd_date >= TO_DATE ('2007/09/01', 'yyyy/mm/dd')
			AND
			trn_flag = 'N'
		GROUP BY
			caseno;
		CURSOR cur_billtemp (
			pcaseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			billtemp1
		WHERE
			caseno = pcaseno
			AND
			trn_flag IN (
				'N',
				'S'
			)
		FOR UPDATE;
		CURSOR cur_spct_order (
			ppfkey VARCHAR2
		) IS
		SELECT
			*
		FROM
			cpoe.vsnhspct
		WHERE
			nhsppfcd = ppfkey;
		CURSOR cur_spct (
			ppfkey VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_spct_dtl
		WHERE
			bil_spct_dtl.pf_key = ppfkey;
		v_caseno           VARCHAR2 (20);
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
		v_fee_type         VARCHAR2 (02);
		bilspctdtlrec      bil_spct_dtl%rowtype;
		vsnhspctrec        cpoe.vsnhspct%rowtype;
		t_spfg             VARCHAR2 (01);
		v_nhspdefg         VARCHAR2 (01);
		v_orflag           VARCHAR2 (30);
		v_comb_flag        VARCHAR2 (01);
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name   := 'biling_daily_pkg.importbilTempBath';
		v_session_id     := userenv ('SESSIONID');
		v_cnt            := 0;
		OPEN cur_1;
		LOOP
			FETCH cur_1 INTO v_caseno;
			EXIT WHEN cur_1%notfound OR v_cnt > 50;
			v_cnt          := v_cnt + 1;
			v_skip         := 'N';
			v_new_caseno   := lpad (v_caseno, 8, '0');
			v_source_seq   := v_new_caseno;

             -- CHECK �ӯf�w��ƬO�_�w�s�b�bBILROOT
             --�S���N�qPAT_ADM_CASE INSERT �i��
			BEGIN
				SELECT
					bil_root.hpatnum
				INTO v_patnum
				FROM
					bil_root
				WHERE
					bil_root.caseno = v_new_caseno;
				SELECT
					MAX (bil_occur.acnt_seq)
				INTO v_seqno
				FROM
					bil_occur
				WHERE
					bil_occur.caseno = v_new_caseno;
			EXCEPTION
				WHEN no_data_found THEN
					biling_interface_pkg.importtointpatadmcase;
					BEGIN
						SELECT
							bil_root.hpatnum
						INTO v_patnum
						FROM
							bil_root
						WHERE
							bil_root.caseno = v_new_caseno;
					EXCEPTION
						WHEN OTHERS THEN
							v_error_code   := sqlcode;
							v_error_info   := sqlerrm;
							v_skip         := 'Y';
							v_cnt          := v_cnt - 1;
					END;
					v_seqno := 0;
			END;
			IF v_skip = 'N' THEN
				SELECT
					*
				INTO bilrootrec
				FROM
					bil_root
				WHERE
					bil_root.caseno = v_caseno;
				IF v_seqno IS NULL THEN
					v_seqno := 0;
				END IF;
				OPEN cur_billtemp (v_caseno);
				LOOP
					FETCH cur_billtemp INTO billtemprec;
					EXIT WHEN cur_billtemp%notfound;
					v_seqno                := v_seqno + 1;
					billtemprec.bltmcode   := rtrim (billtemprec.bltmcode);
					IF billtemprec.bltmcode IN (
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
						'15007080'
					) THEN
						billtemprec.bltmcode := rtrim (billtemprec.bltmcode);
					END IF;

                      --�B�z�뭹����
					IF billtemprec.bltmcode LIKE 'DIET%' AND length (trim (billtemprec.bltmcode)) = 5 THEN
                        /*A.�榡
                            COL. 1 - 8    HCASENO
                            COL. 9 - 14   DATE
                            COL. 28-35   �p���X (DIET + ONE DAY DIET TYPE)
                            COL. 117     �O�_�j���\( Y/N)
                            COL. 118     ���[��i�~�\��
                            COL. 124-129  BREAKFAST,LUNCH,DINNER DIET TYPE

                          B. �p��W�h
                             1. IF (ONE DAY DIET TYPE) >='P & (ONE DAY DIET TYPE) <='V'  THEN
                               �ݩ����p���Ҧ�,�B��i����X
                             2. IF SUBSTR(�p���X,1,7) ='DIETTCM' THEN �`���`���u�Ҧ�
                             3. IF (COL. 118) >='1'  & (COL. 118) <='3' THEN�����O+ [ NT$50 * (COL.
                               118)]
                             4. IF (COL. 117) = 'Y' THEN �����O+ NT$10 */
						v_onedaydiettype               := substr (billtemprec.bltmcode, 5, 1);
						v_segregateflag                := substr (billtemprec.bltmfill, 1, 1);
						v_additionalqty                := to_number (substr (billtemprec.bltmfill, 2, 1));
						v_diet1                        := substr (billtemprec.bltmrscd, 1, 2);
						v_diet2                        := substr (billtemprec.bltmrscd, 3, 2);
						v_diet3                        := substr (billtemprec.bltmrscd, 5, 2);
						biloccurrec.caseno             := v_new_caseno;
						biloccurrec.patient_id         := v_patnum;
						biloccurrec.acnt_seq           := v_seqno;
						biloccurrec.bil_date           := biling_common_pkg.f_get_chdate (billtemprec.bltmdate);
						IF biloccurrec.bil_date > nvl (bilrootrec.dischg_date, SYSDATE) OR biloccurrec.bil_date IS NULL THEN
							biloccurrec.bil_date := trunc (nvl (bilrootrec.dischg_date, SYSDATE));
						END IF;
						IF biloccurrec.bil_date < bilrootrec.admit_date THEN
							biloccurrec.bil_date := trunc (bilrootrec.admit_date);
						END IF;
						biloccurrec.order_seqno        := billtemprec.bltmseq;
						biloccurrec.discharged         := billtemprec.bitmltfg;
						biloccurrec.credit_debit       := '+';
						IF billtemprec.bltmbldt IS NOT NULL THEN
							biloccurrec.create_dt := biling_common_pkg.f_get_chdate (billtemprec.bltmbldt);
						ELSE
							biloccurrec.create_dt := biloccurrec.bil_date;
						END IF;
						biloccurrec.fee_kind           := '02';
						biloccurrec.qty                := 1;
						biloccurrec.emergency          := billtemprec.bltmemg;

                          --�ݭץ�,���ӬOself_flag
						IF billtemprec.bltmanes = 'PR' THEN
							biloccurrec.elf_flag := 'Y';
						ELSE
							biloccurrec.elf_flag := 'N';
						END IF;
						biloccurrec.anesthesia         := billtemprec.bltmanes;
						biloccurrec.income_dept        := billtemprec.bltmidep;
						biloccurrec.log_location       := billtemprec.bltmstat;
						biloccurrec.operator_name      := billtemprec.bluserid;
						biloccurrec.or_order_catalog   := billtemprec.bltmcat;
						biloccurrec.complication       := billtemprec.bltmcomp;
						biloccurrec.or_order_item_no   := billtemprec.bltmorno;
						biloccurrec.combination_item   := billtemprec.bltmcomb;
						biloccurrec.patient_section    := billtemprec.bltmsect;
						biloccurrec.ward               := billtemprec.bltmsect;
						biloccurrec.created_by         := 'billing';
						biloccurrec.creation_date      := SYSDATE;
						biloccurrec.last_updated_by    := 'billing';
						biloccurrec.last_update_date   := SYSDATE;
						v_add_amt                      := 0;

                         --�j���\+10��
						IF v_segregateflag = 'Y' THEN
							v_add_amt := v_add_amt + 10;
						END IF;

                          --���[��i�\ >='1'  &  <='3' �����O+ [ NT$50 * v_additionalQty
						IF v_additionalqty >= 1 AND v_additionalqty <= 3 THEN
							v_add_amt := v_add_amt + (v_additionalqty * 50);
						END IF;

                         --����p���Ҧ��κ֫O�f�H
						IF v_onedaydiettype >= 'P' AND v_onedaydiettype <= 'V' OR bilrootrec.hfinacl = 'NHI3' THEN
							biloccurrec.pf_key          := billtemprec.bltmcode;

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
									dbpfile.pfkey = biloccurrec.pf_key;
							EXCEPTION
								WHEN OTHERS THEN
									v_error_code   := sqlcode;
									v_error_info   := sqlerrm;
							END;
							biloccurrec.charge_amount   := v_price + v_add_amt;
							INSERT INTO bil_occur VALUES biloccurrec;
						ELSE
							biloccurrec.pf_key          := 'DIET' || rtrim (v_diet1);
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
									dbpfile.pfkey = biloccurrec.pf_key;
							EXCEPTION
								WHEN OTHERS THEN
									v_error_code   := sqlcode;
									v_error_info   := sqlerrm;
							END;
							biloccurrec.charge_amount   := v_price + v_add_amt;
							INSERT INTO bil_occur VALUES biloccurrec;
							v_seqno                     := v_seqno + 1;
							biloccurrec.acnt_seq        := v_seqno;
							biloccurrec.pf_key          := 'DIET' || rtrim (v_diet2);
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
									dbpfile.pfkey = biloccurrec.pf_key;
							EXCEPTION
								WHEN OTHERS THEN
									v_error_code   := sqlcode;
									v_error_info   := sqlerrm;
							END;
							biloccurrec.charge_amount   := v_price + v_add_amt;
							INSERT INTO bil_occur VALUES biloccurrec;
							v_seqno                     := v_seqno + 1;
							biloccurrec.acnt_seq        := v_seqno;
							biloccurrec.pf_key          := 'DIET' || rtrim (v_diet3);
							biloccurrec.charge_amount   := v_price;
							INSERT INTO bil_occur VALUES biloccurrec;
						END IF;
					ELSE
						biloccurrec.caseno             := v_new_caseno;
						biloccurrec.patient_id         := v_patnum;
						IF biloccurrec.bil_date > nvl (bilrootrec.dischg_date, SYSDATE) OR biloccurrec.bil_date IS NULL THEN
							biloccurrec.bil_date := trunc (nvl (bilrootrec.dischg_date, SYSDATE));
						END IF;
						IF biloccurrec.bil_date < bilrootrec.admit_date THEN
							biloccurrec.bil_date := trunc (bilrootrec.admit_date);
						END IF;
						biloccurrec.order_seqno        := rtrim (billtemprec.bltmseq);
						biloccurrec.charge_amount      := billtemprec.bltmamt;
						biloccurrec.bil_date           := biling_common_pkg.f_get_chdate (billtemprec.bltmdate);
						biloccurrec.credit_debit       := rtrim (billtemprec.bltmcrdb);
						IF billtemprec.bltmbldt IS NOT NULL THEN
							biloccurrec.create_dt := biling_common_pkg.f_get_chdate (billtemprec.bltmbldt);
						ELSE
							biloccurrec.create_dt := biloccurrec.bil_date;
						END IF;
						biloccurrec.qty                := 1;
						biloccurrec.charge_amount      := v_price;
						biloccurrec.emergency          := billtemprec.bltmemg;

                          --�ݭץ�,���ӬOself_flag
						IF billtemprec.bltmanes = 'PR' THEN
							biloccurrec.elf_flag := 'Y';
						ELSE
							biloccurrec.elf_flag := 'N';
						END IF;
						biloccurrec.anesthesia         := rtrim (billtemprec.bltmanes);
						biloccurrec.income_dept        := rtrim (billtemprec.bltmidep);
						biloccurrec.log_location       := rtrim (billtemprec.bltmstat);
						biloccurrec.operator_name      := rtrim (billtemprec.bluserid);
						biloccurrec.or_order_catalog   := rtrim (billtemprec.bltmcat);
						biloccurrec.complication       := rtrim (billtemprec.bltmcomp);
						biloccurrec.or_order_item_no   := rtrim (billtemprec.bltmorno);
						biloccurrec.combination_item   := rtrim (billtemprec.bltmcomb);
						biloccurrec.patient_section    := rtrim (billtemprec.bltmsect);
						biloccurrec.ward               := rtrim (billtemprec.bltmsect);
						biloccurrec.created_by         := 'billing';
						biloccurrec.creation_date      := SYSDATE;
						biloccurrec.last_updated_by    := 'billing';
						biloccurrec.last_update_date   := SYSDATE;
						BEGIN
							SELECT
								bil_spct_mst.spdefg
							INTO v_nhspdefg
							FROM
								bil_spct_mst
							WHERE
								bil_spct_mst.pf_key = billtemprec.bltmcode;
							v_comb_flag := 'Y';
						EXCEPTION
							WHEN OTHERS THEN
								v_comb_flag := 'N';
						END;

                         --�Hbilltemp����bltmcomb flag �ӧP�_�O�_���զX��
						IF v_comb_flag = 'Y' THEN
                             --�P�_spec
							t_spfg := special_code_check (billtemprec.bltmcode);
                             --NORMAL_ROUTINE
							IF t_spfg = '0' THEN
								IF v_nhspdefg = '2' THEN
                                     --���oorder_tmp
									BEGIN
										SELECT
											orflag
										INTO v_orflag
										FROM
											cpoe.cpoe_ordertmp
										WHERE
											encounter_id = v_new_caseno
											AND
											substr (udocasorseq, 12, 4) = billtemprec.bltmseq;
									EXCEPTION
										WHEN OTHERS THEN
											v_orflag := '111111111111';
									END;

                                     --CHECK ORFLAG
									OPEN cur_spct_order (billtemprec.bltmcode);
									LOOP
										FETCH cur_spct_order INTO vsnhspctrec;
										EXIT WHEN cur_spct_order%notfound;
										biloccurrec.acnt_seq := v_seqno;
										IF substr (v_orflag, vsnhspctrec.nhsindex + 1, 1) = '1' AND vsnhspctrec.nhspit IS NOT NULL THEN
											biloccurrec.order_seqno     := rtrim (billtemprec.bltmseq);
											biloccurrec.pf_key          := rtrim (vsnhspctrec.nhspit);

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
													dbpfile.pfkey = biloccurrec.pf_key;
											EXCEPTION
												WHEN OTHERS THEN
													v_error_code   := sqlcode;
													v_error_info   := sqlerrm;
											END;
											IF rtrim (v_fee_type) <> '' AND v_fee_type IS NOT NULL AND length (rtrim (v_fee_type)) = 2 THEN
												biloccurrec.fee_kind := v_fee_type;
											ELSE
												biloccurrec.fee_kind := rtrim (billtemprec.bltmtp);
											END IF;
											biloccurrec.charge_amount   := v_price;
											INSERT INTO bil_occur VALUES biloccurrec;
											v_seqno                     := v_seqno + 1;
										END IF;
									END LOOP;
									CLOSE cur_spct_order;
								ELSE
									OPEN cur_spct (billtemprec.bltmcode);
									LOOP
										FETCH cur_spct INTO bilspctdtlrec;
										EXIT WHEN cur_spct%notfound;
										biloccurrec.acnt_seq        := v_seqno;
										biloccurrec.order_seqno     := rtrim (billtemprec.bltmseq);
										biloccurrec.pf_key          := rtrim (bilspctdtlrec.child_code);

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
												dbpfile.pfkey = biloccurrec.pf_key;
										EXCEPTION
											WHEN OTHERS THEN
												v_error_code   := sqlcode;
												v_error_info   := sqlerrm;
										END;
										IF rtrim (v_fee_type) <> '' AND v_fee_type IS NOT NULL AND length (rtrim (v_fee_type)) = 2 THEN
											biloccurrec.fee_kind := v_fee_type;
										ELSE
											biloccurrec.fee_kind := rtrim (billtemprec.bltmtp);
										END IF;
										biloccurrec.charge_amount   := v_price;
										INSERT INTO bil_occur VALUES biloccurrec;
										v_seqno                     := v_seqno + 1;
									END LOOP;
									CLOSE cur_spct;
								END IF;
							ELSE
								biloccurrec.acnt_seq        := v_seqno;
								biloccurrec.order_seqno     := rtrim (billtemprec.bltmseq);
								biloccurrec.pf_key          := billtemprec.bltmcode;
								biloccurrec.fee_kind        := rtrim (billtemprec.bltmtp);
								biloccurrec.charge_amount   := billtemprec.bltmamt;
								INSERT INTO bil_occur VALUES biloccurrec;
								v_seqno                     := v_seqno + 1;
							END IF;
						ELSE
							biloccurrec.caseno             := v_new_caseno;
							biloccurrec.patient_id         := v_patnum;
							biloccurrec.acnt_seq           := v_seqno;
							biloccurrec.bil_date           := biling_common_pkg.f_get_chdate (billtemprec.bltmdate);
							IF biloccurrec.bil_date > nvl (bilrootrec.dischg_date, SYSDATE) OR biloccurrec.bil_date IS NULL THEN
								biloccurrec.bil_date := trunc (nvl (bilrootrec.dischg_date, SYSDATE));
							END IF;
							biloccurrec.order_seqno        := rtrim (billtemprec.bltmseq);
							biloccurrec.pf_key             := rtrim (billtemprec.bltmcode);

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
									dbpfile.pfkey = biloccurrec.pf_key;
							EXCEPTION
								WHEN OTHERS THEN
									v_error_code   := sqlcode;
									v_error_info   := sqlerrm;
							END;
							IF rtrim (v_fee_type) <> '' AND v_fee_type IS NOT NULL AND length (rtrim (v_fee_type)) = 2 THEN
								biloccurrec.fee_kind := v_fee_type;
							ELSE
								biloccurrec.fee_kind := rtrim (billtemprec.bltmtp);
							END IF;
							biloccurrec.credit_debit       := rtrim (billtemprec.bltmcrdb);
							IF billtemprec.bltmbldt IS NOT NULL THEN
								biloccurrec.create_dt := biling_common_pkg.f_get_chdate (billtemprec.bltmbldt);
							ELSE
								biloccurrec.create_dt := biloccurrec.bil_date;
							END IF;
							biloccurrec.qty                := billtemprec.bltmqty;
							biloccurrec.charge_amount      := billtemprec.bltmamt / 10;
							biloccurrec.emergency          := billtemprec.bltmemg;

                              --�ݭץ�,���ӬOself_flag
							IF billtemprec.bltmanes = 'PR' THEN
								biloccurrec.elf_flag := 'Y';
							ELSE
								biloccurrec.elf_flag := 'N';
							END IF;
							biloccurrec.anesthesia         := rtrim (billtemprec.bltmanes);
							biloccurrec.income_dept        := rtrim (billtemprec.bltmidep);
							biloccurrec.log_location       := rtrim (billtemprec.bltmstat);
							biloccurrec.operator_name      := rtrim (billtemprec.bluserid);
							biloccurrec.or_order_catalog   := rtrim (billtemprec.bltmcat);
							biloccurrec.complication       := rtrim (billtemprec.bltmcomp);
							biloccurrec.or_order_item_no   := rtrim (billtemprec.bltmorno);
							biloccurrec.combination_item   := rtrim (billtemprec.bltmcomb);
							biloccurrec.patient_section    := rtrim (billtemprec.bltmsect);
							biloccurrec.ward               := rtrim (billtemprec.bltmsect);
							biloccurrec.created_by         := 'billing';
							biloccurrec.creation_date      := SYSDATE;
							biloccurrec.last_updated_by    := 'billing';
							biloccurrec.last_update_date   := SYSDATE;
							INSERT INTO bil_occur VALUES biloccurrec;
						END IF;
					END IF;
					UPDATE billtemp1
					SET
						trn_flag = 'Y',
						trn_date = SYSDATE
					WHERE
						CURRENT OF cur_billtemp;
				END LOOP;
				CLOSE cur_billtemp;
			END IF;
			UPDATE bil_root
			SET
				bil_root.acnt_upd_flag = 'Y'
			WHERE
				bil_root.caseno = v_new_caseno;
		END LOOP;
		CLOSE cur_1;
		COMMIT WORK;
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

  --�i�}bildate
  --�g�J�C��T�w�O�ζibilOccur
	PROCEDURE adddailyservicefee (
		psysdate DATE
	) IS
        --���o���b�|���f�w
		CURSOR cur_bildate IS
		SELECT
			*
		FROM
			bil_date
		WHERE
			bil_date.bil_date = psysdate
			AND
			(bil_date.daily_flag = 'N'
			 OR
			 bil_date.daily_flag IS NULL);
--          FOR UPDATE;
		patadmcaserec     common.pat_adm_case%rowtype;
		bildaterec        bil_date%rowtype;
		v_pfkey           VARCHAR2 (12);
		bilrootrec        bil_root%rowtype;
		v_dischage_flag   VARCHAR2 (01);
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name   := 'biling_daily_pkg.AdddailyServiceFee';
		v_session_id     := userenv ('SESSIONID');
		OPEN cur_bildate;
		LOOP
			FETCH cur_bildate INTO bildaterec;
			EXIT WHEN cur_bildate%notfound;
			v_dischage_flag := 'N';
			SELECT
				*
			INTO bilrootrec
			FROM
				bil_root
			WHERE
				bil_root.caseno = bildaterec.caseno;
			IF trunc (bilrootrec.dischg_date) = trunc (psysdate) AND trunc (bilrootrec.admit_date) <> trunc (bilrootrec.dischg_date) THEN
				v_dischage_flag := 'Y';
			ELSE
				v_dischage_flag := 'N';
			END IF;
			BEGIN
				SELECT
					*
				INTO patadmcaserec
				FROM
					common.pat_adm_case
				WHERE
					pat_adm_case.hcaseno = bildaterec.caseno;
				UPDATE bil_date
				SET
					bil_date.daily_flag = 'Y'
				WHERE
					caseno = bildaterec.caseno
					AND
					bil_date = bildaterec.bil_date;  
--                      WHERE CURRENT OF CUR_bildate;
			EXCEPTION
				WHEN OTHERS THEN
					bildaterec.beddge := NULL;
			END;
			IF bildaterec.beddge IS NULL THEN
                    --SELECT �f�е���
				BEGIN
					SELECT
						hbeddge
					INTO
						bildaterec
					.beddge
					FROM
						common.adm_bed
					WHERE
						rtrim (hnurstat) = rtrim (bildaterec.wardno)
						AND
						rtrim (hbedno) = rtrim (bildaterec.bed_no);
				EXCEPTION
					WHEN OTHERS THEN
						bildaterec.beddge := NULL;
				END;
			END IF;

                 --�}�l�J�T�w�O��
                 --��BEDDGE���~�J(�]����Ƥ���)
			IF bildaterec.beddge IS NOT NULL THEN
				IF v_dischage_flag = 'N' THEN
                         --1.�f�жO
					v_pfkey   := 'WARD' || bildaterec.beddge;
					insertbiloccur (pcaseno => patadmcaserec.hcaseno, ppatnum => patadmcaserec.hhisnum, ppfkey => v_pfkey, pbildate => psysdate,
					pward => bildaterec.wardno, pbedno => bildaterec.bed_no);

                         --2.�@�z�O
					v_pfkey   := 'NURS' || bildaterec.beddge;
					insertbiloccur (pcaseno => patadmcaserec.hcaseno, ppatnum => patadmcaserec.hhisnum, ppfkey => v_pfkey, pbildate => psysdate,
					pward => bildaterec.wardno, pbedno => bildaterec.bed_no);
				END IF;
                     --3.��v�O
				v_pfkey := 'DIAG' || bildaterec.beddge;
				insertbiloccur (pcaseno => patadmcaserec.hcaseno, ppatnum => patadmcaserec.hhisnum, ppfkey => v_pfkey, pbildate => psysdate, pward
				=> bildaterec.wardno, pbedno => bildaterec.bed_no);
			END IF;
		END LOOP;
		CLOSE cur_bildate;
		COMMIT WORK;
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
	PROCEDURE insertbiloccur (
		pcaseno    VARCHAR2,
		ppatnum    VARCHAR2,
		ppfkey     VARCHAR2,
		pbildate   DATE,
		pward      VARCHAR2,
		pbedno     VARCHAR2
	) IS
		v_acnt_seq      INTEGER;
		CURSOR cur_dbpfile (
			ppfkey1 VARCHAR2
		) IS
		SELECT
			*
		FROM
			cpoe.dbpfile
		WHERE
			dbpfile.pfkey = ppfkey1;
		dbpfilerec      cpoe.dbpfile%rowtype;
		biloccurrec     bil_occur%rowtype;
		patadmcaserec   common.pat_adm_case%rowtype;
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name                 := 'biling_daily_pkg.insertBilOccur';
		v_session_id                   := userenv ('SESSIONID');
		SELECT
			MAX (acnt_seq)
		INTO v_acnt_seq
		FROM
			bil_occur
		WHERE
			bil_occur.caseno = pcaseno;
		SELECT
			*
		INTO patadmcaserec
		FROM
			common.pat_adm_case
		WHERE
			common.pat_adm_case.hcaseno = pcaseno;
		IF v_acnt_seq IS NULL THEN
			v_acnt_seq := 1;
		ELSE
			v_acnt_seq := v_acnt_seq + 1;
		END IF;
		biloccurrec.caseno             := pcaseno;
		biloccurrec.patient_id         := ppatnum;
		biloccurrec.acnt_seq           := v_acnt_seq;
		biloccurrec.bil_date           := pbildate;
		biloccurrec.order_seqno        := '';
		biloccurrec.pf_key             := rtrim (ppfkey);
		biloccurrec.credit_debit       := '+';
		biloccurrec.create_dt          := SYSDATE;
		OPEN cur_dbpfile (biloccurrec.pf_key);
		FETCH cur_dbpfile INTO dbpfilerec;
		CLOSE cur_dbpfile;
		biloccurrec.fee_kind           := dbpfilerec.pfppfkd;
		IF ppfkey LIKE 'WARD%' THEN
			biloccurrec.fee_kind := '01';
		END IF;
		IF ppfkey LIKE 'DIAG%' THEN
			biloccurrec.fee_kind := '03';
		END IF;
		IF ppfkey LIKE 'NURS%' THEN
			biloccurrec.fee_kind := '05';
		END IF;
		biloccurrec.charge_amount      := round (dbpfilerec.pfprice1);
		biloccurrec.qty                := 1;
		biloccurrec.emergency          := 'N';
            --�ݭץ�,���ӬOself_flag
		biloccurrec.elf_flag           := 'N';
		biloccurrec.income_dept        := patadmcaserec.hcursvcl;
		biloccurrec.log_location       := pward;
		biloccurrec.operator_name      := 'dailyBatch';
		biloccurrec.patient_section    := patadmcaserec.hcursvcl;--pWard;
		biloccurrec.ward               := pward;
		biloccurrec.create_dt          := pbildate;
		biloccurrec.bed_no             := pbedno;
		biloccurrec.created_by         := 'billing';
		biloccurrec.creation_date      := SYSDATE;
		biloccurrec.last_updated_by    := 'billing';
		biloccurrec.last_update_date   := SYSDATE;
		biloccurrec.bildate            := pbildate;
		INSERT INTO bil_occur VALUES biloccurrec;
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

  --this is old one for switch back in case by kuo 1010628
	PROCEDURE insertbiloccurfordiet_new (
		pcaseno    VARCHAR2,
		pbildate   DATE
	) IS
		v_acnt_seq         INTEGER;
		biloccurrec        bil_occur%rowtype;
		bildaterec         bil_date%rowtype;
		bilrootrec         bil_root%rowtype;
		v_onedaydiettype   VARCHAR2 (01);
		v_segregateflag    VARCHAR2 (01);
		v_additionalqty    INTEGER;
		v_diet1            VARCHAR2 (02);
		v_diet2            VARCHAR2 (02);
		v_diet3            VARCHAR2 (02);
		v_add_amt          NUMBER (10, 2);
		v_price            NUMBER (10, 2);
		v_dischage_flag    VARCHAR2 (01) := 'N';
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name                 := 'biling_daily_pkg.insertBilOccurForDiet';
		v_session_id                   := userenv ('SESSIONID');
		BEGIN
			SELECT
				*
			INTO bildaterec
			FROM
				bil_date
			WHERE
				bil_date.caseno = pcaseno
				AND
				bil_date.bil_date = pbildate;
		EXCEPTION
			WHEN OTHERS THEN
				expandbildate (pcaseno, pbildate);
		END;
		BEGIN
			SELECT
				*
			INTO bildaterec
			FROM
				bil_date
			WHERE
				bil_date.caseno = pcaseno
				AND
				bil_date.bil_date = pbildate;
			SELECT
				*
			INTO bilrootrec
			FROM
				bil_root
			WHERE
				bil_root.caseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				v_error_code   := sqlcode;
				v_error_info   := sqlerrm;
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
		END;
		IF trunc (bilrootrec.dischg_date) = trunc (pbildate) THEN
			v_dischage_flag := 'Y';
		ELSE
			v_dischage_flag := 'N';
		END IF;
		SELECT
			MAX (acnt_seq)
		INTO v_acnt_seq
		FROM
			bil_occur
		WHERE
			bil_occur.caseno = pcaseno;
		IF v_acnt_seq IS NULL THEN
			v_acnt_seq := 1;
		ELSE
			v_acnt_seq := v_acnt_seq + 1;
		END IF;
		biloccurrec.caseno             := pcaseno;
		biloccurrec.patient_id         := bilrootrec.hpatnum;
		biloccurrec.acnt_seq           := v_acnt_seq;
		biloccurrec.bil_date           := pbildate;
		biloccurrec.order_seqno        := '';
		biloccurrec.credit_debit       := '+';
		biloccurrec.create_dt          := SYSDATE;

        /*A.�榡
          COL. 1 - 8    HCASENO
          COL. 9 - 14   DATE
          COL. 28-35   �p���X (DIET + ONE DAY DIET TYPE)
          COL. 117     �O�_�j���\( Y/N)
          COL. 118     ���[��i�~�\��
          COL. 124-129  BREAKFAST,LUNCH,DINNER DIET TYPE

        B. �p��W�h
           1. IF (ONE DAY DIET TYPE) >='P & (ONE DAY DIET TYPE) <='V'  THEN
             �ݩ����p���Ҧ�,�B��i����X
           2. IF SUBSTR(�p���X,1,7) ='DIETTCM' THEN �`���`���u�Ҧ�
           3. IF (COL. 118) >='1'  & (COL. 118) <='3' THEN�����O+ [ NT$50 * (COL.
             118)]
           4. IF (COL. 117) = 'Y' THEN �����O+ NT$10 */
		v_onedaydiettype               := bildaterec.bldiet;
		v_segregateflag                := bildaterec.bldietis;
		v_additionalqty                := to_number (bildaterec.blmealx);
		v_diet1                        := substr (bildaterec.blmeal, 1, 2);
		v_diet2                        := substr (bildaterec.blmeal, 3, 2);
		v_diet3                        := substr (bildaterec.blmeal, 5, 2);
		biloccurrec.caseno             := pcaseno;
		biloccurrec.patient_id         := bilrootrec.hpatnum;
		biloccurrec.acnt_seq           := v_acnt_seq;
		biloccurrec.bil_date           := pbildate;
		IF biloccurrec.bil_date > nvl (bilrootrec.dischg_date, SYSDATE) OR biloccurrec.bil_date IS NULL THEN
			biloccurrec.bil_date := trunc (nvl (bilrootrec.dischg_date, SYSDATE));
		END IF;
		IF biloccurrec.bil_date < bilrootrec.admit_date THEN
			biloccurrec.bil_date := trunc (bilrootrec.admit_date);
		END IF;
		biloccurrec.discharged         := 'N';
		biloccurrec.credit_debit       := '+';
		biloccurrec.create_dt          := pbildate;
		biloccurrec.fee_kind           := '02';
		biloccurrec.qty                := 1;
		biloccurrec.emergency          := 'R';
		biloccurrec.elf_flag           := 'N';
		biloccurrec.income_dept        := bilrootrec.hcursvcl;
		biloccurrec.log_location       := bildaterec.wardno;
		biloccurrec.patient_section    := bilrootrec.hcursvcl;--bilDateRec.Wardno;
		biloccurrec.ward               := bildaterec.wardno;
		biloccurrec.bed_no             := bildaterec.bed_no;
		biloccurrec.created_by         := 'billing';
		biloccurrec.creation_date      := SYSDATE;
		biloccurrec.last_updated_by    := 'billing';
		biloccurrec.last_update_date   := SYSDATE;
		biloccurrec.bildate            := pbildate;
		v_add_amt                      := 0;

             --�j���\+10��
		IF v_segregateflag = 'Y' THEN
			v_add_amt := 10;
		END IF;
		v_price                        := 0;

              --���[��i�\ >='1'  &  <='3' �����O+ [ NT$50 * v_additionalQty
		IF v_additionalqty >= 1 AND v_additionalqty <= 3 THEN
			v_add_amt := v_add_amt + v_additionalqty * 50;
		END IF;

             --����p���Ҧ��κ֫O�f�H
		IF (v_onedaydiettype >= 'P' AND v_onedaydiettype <= 'V') OR (bilrootrec.hfinacl IN (
			'NHI3',
			'NHI6'
		) AND v_dischage_flag <> 'Y') --���O�a,���O��,�̫�ѥH�\�p
		 OR biling_calculate_pkg.f_checknhdiet (pcaseno => bilrootrec.caseno) = 'Y' THEN
			biloccurrec.pf_key             := 'DIET' || v_onedaydiettype;

                --����X�w��
			BEGIN
				SELECT
					dbpfile.pfprice1
				INTO v_price
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = biloccurrec.pf_key;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
					v_price        := 0;
			END;
			IF v_price > 0 THEN
				biloccurrec.charge_amount := round (v_price) + round (v_add_amt);
			ELSE
				biloccurrec.charge_amount := round (v_price);
			END IF;
			biloccurrec.diet_other_price   := round (v_add_amt);
			INSERT INTO bil_occur VALUES biloccurrec;
		ELSE
			biloccurrec.pf_key             := 'DIET' || rtrim (v_diet1);
			v_price                        := 0;
                --����X�w��
			BEGIN
				SELECT
					dbpfile.pfprice1
				INTO v_price
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = biloccurrec.pf_key;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
					v_price        := 0;
			END;
			IF v_price > 0 THEN
				biloccurrec.charge_amount   := round (v_price) + round (v_add_amt);
				v_add_amt                   := 0;
			ELSE
				biloccurrec.charge_amount := round (v_price);
			END IF;
			biloccurrec.diet_other_price   := round (v_add_amt);
			INSERT INTO bil_occur VALUES biloccurrec;
			v_acnt_seq                     := v_acnt_seq + 1;
			biloccurrec.acnt_seq           := v_acnt_seq;
			biloccurrec.pf_key             := 'DIET' || rtrim (v_diet2);
                --����X�w��
			BEGIN
				SELECT
					dbpfile.pfprice1
				INTO v_price
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = biloccurrec.pf_key;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
					v_price        := 0;
			END;
			IF v_price > 0 THEN
				biloccurrec.charge_amount   := round (v_price) + round (v_add_amt);
				v_add_amt                   := 0;
			ELSE
				biloccurrec.charge_amount := round (v_price);
			END IF;
			biloccurrec.diet_other_price   := round (v_add_amt);
			INSERT INTO bil_occur VALUES biloccurrec;
			v_acnt_seq                     := v_acnt_seq + 1;
			biloccurrec.acnt_seq           := v_acnt_seq;
			biloccurrec.pf_key             := 'DIET' || rtrim (v_diet3);
			v_price                        := 0;
                --����X�w��
			BEGIN
				SELECT
					dbpfile.pfprice1
				INTO v_price
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = biloccurrec.pf_key;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
					v_price        := 0;
			END;
			IF v_price > 0 THEN
				biloccurrec.charge_amount   := round (v_price) + round (v_add_amt);
				v_add_amt                   := 0;
			ELSE
				biloccurrec.charge_amount := round (v_price);
			END IF;
			biloccurrec.diet_other_price   := round (v_add_amt);
			INSERT INTO bil_occur VALUES biloccurrec;
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

  --this is backup for old one by kuo 1010628
	PROCEDURE insertbiloccurfordiet_backup (
		pcaseno    VARCHAR2,
		pbildate   DATE
	) IS
		v_acnt_seq         INTEGER;
		biloccurrec        bil_occur%rowtype;
		bildaterec         bil_date%rowtype;
		bilrootrec         bil_root%rowtype;
		v_onedaydiettype   VARCHAR2 (01);
		v_segregateflag    VARCHAR2 (01);
		v_additionalqty    INTEGER;
		v_diet1            VARCHAR2 (02);
		v_diet2            VARCHAR2 (02);
		v_diet3            VARCHAR2 (02);
		v_add_amt          NUMBER (10, 2);
		v_price            NUMBER (10, 2);
		v_dischage_flag    VARCHAR2 (01) := 'N';
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name                 := 'biling_daily_pkg.insertBilOccurForDiet';
		v_session_id                   := userenv ('SESSIONID');
		BEGIN
			SELECT
				*
			INTO bildaterec
			FROM
				bil_date
			WHERE
				bil_date.caseno = pcaseno
				AND
				bil_date.bil_date = pbildate;
		EXCEPTION
			WHEN OTHERS THEN
				expandbildate (pcaseno, pbildate);
		END;
		BEGIN
			SELECT
				*
			INTO bildaterec
			FROM
				bil_date
			WHERE
				bil_date.caseno = pcaseno
				AND
				bil_date.bil_date = pbildate;
			SELECT
				*
			INTO bilrootrec
			FROM
				bil_root
			WHERE
				bil_root.caseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				v_error_code   := sqlcode;
				v_error_info   := sqlerrm;
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
		END;
		IF trunc (bilrootrec.dischg_date) = trunc (pbildate) THEN
			v_dischage_flag := 'Y';
		ELSE
			v_dischage_flag := 'N';
		END IF;
		SELECT
			MAX (acnt_seq)
		INTO v_acnt_seq
		FROM
			bil_occur
		WHERE
			bil_occur.caseno = pcaseno;
		IF v_acnt_seq IS NULL THEN
			v_acnt_seq := 1;
		ELSE
			v_acnt_seq := v_acnt_seq + 1;
		END IF;
		biloccurrec.caseno             := pcaseno;
		biloccurrec.patient_id         := bilrootrec.hpatnum;
		biloccurrec.acnt_seq           := v_acnt_seq;
		biloccurrec.bil_date           := pbildate;
		biloccurrec.order_seqno        := '';
		biloccurrec.credit_debit       := '+';
		biloccurrec.create_dt          := SYSDATE;

        /*A.�榡
          COL. 1 - 8    HCASENO
          COL. 9 - 14   DATE
          COL. 28-35   �p���X (DIET + ONE DAY DIET TYPE)
          COL. 117     �O�_�j���\( Y/N)
          COL. 118     ���[��i�~�\��
          COL. 124-129  BREAKFAST,LUNCH,DINNER DIET TYPE

        B. �p��W�h
           1. IF (ONE DAY DIET TYPE) >='P & (ONE DAY DIET TYPE) <='V'  THEN
             �ݩ����p���Ҧ�,�B��i����X
           2. IF SUBSTR(�p���X,1,7) ='DIETTCM' THEN �`���`���u�Ҧ�
           3. IF (COL. 118) >='1'  & (COL. 118) <='3' THEN�����O+ [ NT$50 * (COL.
             118)]
           4. IF (COL. 117) = 'Y' THEN �����O+ NT$10 */
		v_onedaydiettype               := bildaterec.bldiet;
		v_segregateflag                := bildaterec.bldietis;
		v_additionalqty                := to_number (bildaterec.blmealx);
		v_diet1                        := substr (bildaterec.blmeal, 1, 2);
		v_diet2                        := substr (bildaterec.blmeal, 3, 2);
		v_diet3                        := substr (bildaterec.blmeal, 5, 2);
		biloccurrec.caseno             := pcaseno;
		biloccurrec.patient_id         := bilrootrec.hpatnum;
		biloccurrec.acnt_seq           := v_acnt_seq;
		biloccurrec.bil_date           := pbildate;
		IF biloccurrec.bil_date > nvl (bilrootrec.dischg_date, SYSDATE) OR biloccurrec.bil_date IS NULL THEN
			biloccurrec.bil_date := trunc (nvl (bilrootrec.dischg_date, SYSDATE));
		END IF;
		IF biloccurrec.bil_date < bilrootrec.admit_date THEN
			biloccurrec.bil_date := trunc (bilrootrec.admit_date);
		END IF;
		biloccurrec.discharged         := 'N';
		biloccurrec.credit_debit       := '+';
		biloccurrec.create_dt          := pbildate;
		biloccurrec.fee_kind           := '02';
		biloccurrec.qty                := 1;
		biloccurrec.emergency          := 'R';
		biloccurrec.elf_flag           := 'N';
		biloccurrec.income_dept        := bilrootrec.hcursvcl;
		biloccurrec.log_location       := bildaterec.wardno;
		biloccurrec.patient_section    := bilrootrec.hcursvcl;--bilDateRec.Wardno;
		biloccurrec.ward               := bildaterec.wardno;
		biloccurrec.bed_no             := bildaterec.bed_no;
		biloccurrec.created_by         := 'billing';
		biloccurrec.creation_date      := SYSDATE;
		biloccurrec.last_updated_by    := 'billing';
		biloccurrec.last_update_date   := SYSDATE;
		biloccurrec.bildate            := pbildate;
		v_add_amt                      := 0;

             --�j���\+10��
		IF v_segregateflag = 'Y' THEN
			v_add_amt := 10;
		END IF;
		v_price                        := 0;

              --���[��i�\ >='1'  &  <='3' �����O+ [ NT$50 * v_additionalQty
		IF v_additionalqty >= 1 AND v_additionalqty <= 3 THEN
			v_add_amt := v_add_amt + v_additionalqty * 50;
		END IF;

             --����p���Ҧ��κ֫O�f�H
		IF (v_onedaydiettype >= 'P' AND v_onedaydiettype <= 'V') OR (bilrootrec.hfinacl IN (
			'NHI3',
			'NHI6'
		) AND v_dischage_flag <> 'Y') --���O�a,���O��,�̫�ѥH�\�p
		 OR biling_calculate_pkg.f_checknhdiet (pcaseno => bilrootrec.caseno) = 'Y' THEN
			biloccurrec.pf_key             := 'DIET' || v_onedaydiettype;

                --����X�w��
			BEGIN
				SELECT
					dbpfile.pfprice1
				INTO v_price
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = biloccurrec.pf_key;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
					v_price        := 0;
			END;
			IF v_price > 0 THEN
				biloccurrec.charge_amount := round (v_price) + round (v_add_amt);
			ELSE
				biloccurrec.charge_amount := round (v_price);
			END IF;
			biloccurrec.diet_other_price   := round (v_add_amt);
			INSERT INTO bil_occur VALUES biloccurrec;
		ELSE
			biloccurrec.pf_key             := 'DIET' || rtrim (v_diet1);
			v_price                        := 0;
                --����X�w��
			BEGIN
				SELECT
					dbpfile.pfprice1
				INTO v_price
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = biloccurrec.pf_key;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
					v_price        := 0;
			END;
			IF v_price > 0 THEN
				biloccurrec.charge_amount   := round (v_price) + round (v_add_amt);
				v_add_amt                   := 0;
			ELSE
				biloccurrec.charge_amount := round (v_price);
			END IF;
			biloccurrec.diet_other_price   := round (v_add_amt);
			INSERT INTO bil_occur VALUES biloccurrec;
			v_acnt_seq                     := v_acnt_seq + 1;
			biloccurrec.acnt_seq           := v_acnt_seq;
			biloccurrec.pf_key             := 'DIET' || rtrim (v_diet2);
                --����X�w��
			BEGIN
				SELECT
					dbpfile.pfprice1
				INTO v_price
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = biloccurrec.pf_key;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
					v_price        := 0;
			END;
			IF v_price > 0 THEN
				biloccurrec.charge_amount   := round (v_price) + round (v_add_amt);
				v_add_amt                   := 0;
			ELSE
				biloccurrec.charge_amount := round (v_price);
			END IF;
			biloccurrec.diet_other_price   := round (v_add_amt);
			INSERT INTO bil_occur VALUES biloccurrec;
			v_acnt_seq                     := v_acnt_seq + 1;
			biloccurrec.acnt_seq           := v_acnt_seq;
			biloccurrec.pf_key             := 'DIET' || rtrim (v_diet3);
			v_price                        := 0;
                --����X�w��
			BEGIN
				SELECT
					dbpfile.pfprice1
				INTO v_price
				FROM
					cpoe.dbpfile
				WHERE
					dbpfile.pfkey = biloccurrec.pf_key;
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
					v_price        := 0;
			END;
			IF v_price > 0 THEN
				biloccurrec.charge_amount   := round (v_price) + round (v_add_amt);
				v_add_amt                   := 0;
			ELSE
				biloccurrec.charge_amount := round (v_price);
			END IF;
			biloccurrec.diet_other_price   := round (v_add_amt);
			INSERT INTO bil_occur VALUES biloccurrec;
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

  --new one for new diet added by kuo 1001111
	PROCEDURE insertbiloccurfordiet (
		pcaseno    VARCHAR2,
		pbildate   DATE
	) IS
		v_acnt_seq         INTEGER;
		biloccurrec        bil_occur%rowtype;
		bildaterec         bil_date%rowtype;
		bilrootrec         bil_root%rowtype;
		v_onedaydiettype   VARCHAR2 (01);
		v_segregateflag    VARCHAR2 (01);
		v_additionalqty    INTEGER;
		v_diet1            VARCHAR2 (02);
		v_diet2            VARCHAR2 (02);
		v_diet3            VARCHAR2 (02);
		v_dieta            VARCHAR2 (08); --�s�����\
		v_dietb            VARCHAR2 (08); --�s�����\
		v_dietc            VARCHAR2 (08); --�s�����\
		v_dietd            VARCHAR2 (08); --�s�����\
		v_add_amt          NUMBER (10, 2);
		v_price            NUMBER (10, 2);
		v_dischage_flag    VARCHAR2 (01) := 'N';
		innhidiet          NUMBER;
		actionflg          VARCHAR2 (12);
	BEGIN
     --�]�w�{���W�٤�session_id
		v_program_name             := 'biling_daily_pkg.insertBilOccurForDiet';
		v_session_id               := userenv ('SESSIONID');

     --debug
		actionflg                  := '01';
		BEGIN
			SELECT
				*
			INTO bildaterec
			FROM
				bil_date
			WHERE
				bil_date.caseno = pcaseno
				AND
				bil_date.bil_date = pbildate;
		EXCEPTION
			WHEN OTHERS THEN
				expandbildate (pcaseno, pbildate);
		END;

     --debug
		actionflg                  := '02';
		BEGIN
			SELECT
				*
			INTO bildaterec
			FROM
				bil_date
			WHERE
				bil_date.caseno = pcaseno
				AND
				bil_date.bil_date = pbildate;
			SELECT
				*
			INTO bilrootrec
			FROM
				bil_root
			WHERE
				bil_root.caseno = pcaseno;
		EXCEPTION
			WHEN OTHERS THEN
				v_error_code   := sqlcode;
				v_error_info   := sqlerrm;
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
		END;

     --debug
		actionflg                  := '03';
		IF trunc (bilrootrec.dischg_date) = trunc (pbildate) THEN
			v_dischage_flag := 'Y';
		ELSE
			v_dischage_flag := 'N';
		END IF;
		SELECT
			MAX (acnt_seq)
		INTO v_acnt_seq
		FROM
			bil_occur
		WHERE
			bil_occur.caseno = pcaseno;
		IF v_acnt_seq IS NULL THEN
			v_acnt_seq := 1;
		ELSE
			v_acnt_seq := v_acnt_seq + 1;
		END IF;
		biloccurrec.caseno         := pcaseno;
		biloccurrec.patient_id     := bilrootrec.hpatnum;
		biloccurrec.acnt_seq       := v_acnt_seq;
		biloccurrec.bil_date       := pbildate;
		biloccurrec.order_seqno    := '';
		biloccurrec.credit_debit   := '+';
		biloccurrec.create_dt      := SYSDATE;

     --debug
		actionflg                  := '04';

     /*A.�榡 --��
       COL. 1 - 8    HCASENO
       COL. 9 - 14   DATE
       COL. 28-35   �p���X (DIET + ONE DAY DIET TYPE)
       COL. 117     �O�_�j���\( Y/N)
       COL. 118     ���[��i�~�\��
       COL. 124-129  BREAKFAST,LUNCH,DINNER DIET TYPE

       B. �p��W�h
        1. IF (ONE DAY DIET TYPE) >='P & (ONE DAY DIET TYPE) <='V'  THEN
          �ݩ����p���Ҧ�,�B��i����X
        2. IF SUBSTR(�p���X,1,7) ='DIETTCM' THEN �`���`���u�Ҧ�
        3. IF (COL. 118) >='1'  & (COL. 118) <='3' THEN�����O+ [ NT$50 * (COL.
          118)]
        4. IF (COL. 117) = 'Y' THEN �����O+ NT$10 */
		IF bildaterec.bldiet IS NULL THEN --NO INFORMATION ,RETURN
			return;
		END IF;
		IF length (bildaterec.bldiet) < 8 THEN
			IF bildaterec.bldiet IS NULL THEN --NO INFORMATION ,RETURN
				return;
			END IF;
			IF length (bildaterec.bldiet) > 4 THEN
				return;
			END IF;
        --debug
			actionflg                      := '04.1';
			v_onedaydiettype               := bildaterec.bldiet;
			v_segregateflag                := bildaterec.bldietis;
			v_additionalqty                := to_number (bildaterec.blmealx);
			v_diet1                        := substr (bildaterec.blmeal, 1, 2);
			v_diet2                        := substr (bildaterec.blmeal, 3, 2);
			v_diet3                        := substr (bildaterec.blmeal, 5, 2);
			biloccurrec.caseno             := pcaseno;
			biloccurrec.patient_id         := bilrootrec.hpatnum;
			biloccurrec.acnt_seq           := v_acnt_seq;
			biloccurrec.bil_date           := pbildate;
			IF biloccurrec.bil_date > nvl (bilrootrec.dischg_date, SYSDATE) OR biloccurrec.bil_date IS NULL THEN
				biloccurrec.bil_date := trunc (nvl (bilrootrec.dischg_date, SYSDATE));
			END IF;
			IF biloccurrec.bil_date < bilrootrec.admit_date THEN
				biloccurrec.bil_date := trunc (bilrootrec.admit_date);
			END IF;
        --debug
			actionflg                      := '04.2';
			biloccurrec.discharged         := 'N';
			biloccurrec.credit_debit       := '+';
			biloccurrec.create_dt          := pbildate;
			biloccurrec.fee_kind           := '02';
			biloccurrec.qty                := 1;
			biloccurrec.emergency          := 'R';
			biloccurrec.elf_flag           := 'N';
			biloccurrec.income_dept        := bilrootrec.hcursvcl;
			biloccurrec.log_location       := bildaterec.wardno;
			biloccurrec.patient_section    := bilrootrec.hcursvcl;--bilDateRec.Wardno;
			biloccurrec.ward               := bildaterec.wardno;
			biloccurrec.bed_no             := bildaterec.bed_no;
			biloccurrec.created_by         := 'billing';
			biloccurrec.creation_date      := SYSDATE;
			biloccurrec.last_updated_by    := 'billing';
			biloccurrec.last_update_date   := SYSDATE;
			biloccurrec.bildate            := pbildate;
			v_add_amt                      := 0;

        --�j���\+10��
			IF v_segregateflag = 'Y' THEN
				v_add_amt := 10;
			END IF;
			v_price                        := 0;

        --���[��i�\ >='1'  &  <='3' �����O+ [ NT$50 * v_additionalQty
			IF v_additionalqty >= 1 AND v_additionalqty <= 3 THEN
				v_add_amt := v_add_amt + v_additionalqty * 50;
			END IF;

        --����p���Ҧ��κ֫O�f�H
			IF (v_onedaydiettype >= 'P' AND v_onedaydiettype <= 'V') OR (bilrootrec.hfinacl IN (
				'NHI3',
				'NHI6'
			) AND v_dischage_flag <> 'Y') --���O�a,���O��,�̫�ѥH�\�p
			 OR biling_calculate_pkg.f_checknhdiet (pcaseno => bilrootrec.caseno) = 'Y' THEN
				biloccurrec.pf_key             := 'DIET' || v_onedaydiettype;

           --����X�w��
				BEGIN
					SELECT
						dbpfile.pfprice1
					INTO v_price
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = biloccurrec.pf_key;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
						v_price        := 0;
				END;
				IF v_price > 0 THEN
					biloccurrec.charge_amount := round (v_price) + round (v_add_amt);
				ELSE
					biloccurrec.charge_amount := round (v_price);
				END IF;
				biloccurrec.diet_other_price   := round (v_add_amt);
				INSERT INTO bil_occur VALUES biloccurrec;
			ELSE
				biloccurrec.pf_key             := 'DIET' || rtrim (v_diet1);
				v_price                        := 0;
           --����X�w��
				BEGIN
					SELECT
						dbpfile.pfprice1
					INTO v_price
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = biloccurrec.pf_key;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
						v_price        := 0;
				END;
				IF v_price > 0 THEN
					biloccurrec.charge_amount   := round (v_price) + round (v_add_amt);
					v_add_amt                   := 0;
				ELSE
					biloccurrec.charge_amount := round (v_price);
				END IF;
				biloccurrec.diet_other_price   := round (v_add_amt);
				INSERT INTO bil_occur VALUES biloccurrec;
				v_acnt_seq                     := v_acnt_seq + 1;
				biloccurrec.acnt_seq           := v_acnt_seq;
				biloccurrec.pf_key             := 'DIET' || rtrim (v_diet2);
           --����X�w��
				BEGIN
					SELECT
						dbpfile.pfprice1
					INTO v_price
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = biloccurrec.pf_key;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
						v_price        := 0;
				END;
				IF v_price > 0 THEN
					biloccurrec.charge_amount   := round (v_price) + round (v_add_amt);
					v_add_amt                   := 0;
				ELSE
					biloccurrec.charge_amount := round (v_price);
				END IF;
				biloccurrec.diet_other_price   := round (v_add_amt);
				INSERT INTO bil_occur VALUES biloccurrec;
				v_acnt_seq                     := v_acnt_seq + 1;
				biloccurrec.acnt_seq           := v_acnt_seq;
				biloccurrec.pf_key             := 'DIET' || rtrim (v_diet3);
				v_price                        := 0;
           --����X�w��
				BEGIN
					SELECT
						dbpfile.pfprice1
					INTO v_price
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = biloccurrec.pf_key;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
						v_price        := 0;
				END;
				IF v_price > 0 THEN
					biloccurrec.charge_amount   := round (v_price) + round (v_add_amt);
					v_add_amt                   := 0;
				ELSE
					biloccurrec.charge_amount := round (v_price);
				END IF;
				biloccurrec.diet_other_price   := round (v_add_amt);
				INSERT INTO bil_occur VALUES biloccurrec;
			END IF;
		ELSE --�s��
        --debug
			actionflg                      := '05';
			v_dieta                        := bildaterec.bldiet;
        --v_segregateFlag := bilDateRec.Bldietis;
        --v_additionalQty := to_number(bilDateRec.Blmealx);
			v_dietb                        := substr (bildaterec.blmeal, 1, 8);
			v_dietc                        := substr (bildaterec.blmeal, 9, 8);
			v_dietd                        := substr (bildaterec.blmeal, 17, 8);
			biloccurrec.caseno             := pcaseno;
			biloccurrec.patient_id         := bilrootrec.hpatnum;
			biloccurrec.acnt_seq           := v_acnt_seq;
			biloccurrec.bil_date           := pbildate;

        --debug
			actionflg                      := '06';
			IF biloccurrec.bil_date > nvl (bilrootrec.dischg_date, SYSDATE) OR biloccurrec.bil_date IS NULL THEN
				biloccurrec.bil_date := trunc (nvl (bilrootrec.dischg_date, SYSDATE));
			END IF;
			IF biloccurrec.bil_date < bilrootrec.admit_date THEN
				biloccurrec.bil_date := trunc (bilrootrec.admit_date);
			END IF;

        --debug
			actionflg                      := '07';
			biloccurrec.discharged         := 'N';
			biloccurrec.credit_debit       := '+';
			biloccurrec.create_dt          := pbildate;
			biloccurrec.fee_kind           := '02';
			biloccurrec.qty                := 1;
			biloccurrec.emergency          := 'R';
			biloccurrec.elf_flag           := 'N';
			biloccurrec.income_dept        := bilrootrec.hcursvcl;
			biloccurrec.log_location       := bildaterec.wardno;
			biloccurrec.patient_section    := bilrootrec.hcursvcl;--bilDateRec.Wardno;
			biloccurrec.ward               := bildaterec.wardno;
			biloccurrec.bed_no             := bildaterec.bed_no;
			biloccurrec.operator_name      := 'DDAILY';
			biloccurrec.created_by         := 'billing';
			biloccurrec.creation_date      := SYSDATE;
			biloccurrec.last_updated_by    := 'billing';
			biloccurrec.last_update_date   := SYSDATE;
			biloccurrec.bildate            := pbildate;
			v_add_amt                      := 0;

        --debug
			actionflg                      := '08';
        --�j���\+10��
        /*--�s���L�A����W�J�b
        IF v_segregateFlag = 'Y' THEN
             v_add_amt := 10;
        END IF ;

        v_price := 0;

        --���[��i�\ >='1'  &  <='3' �����O+ [ NT$50 * v_additionalQty
        IF V_ADDITIONALQTY >= 1 AND V_ADDITIONALQTY <= 3 THEN
           v_add_amt := v_add_amt + v_additionalQty * 50;
        END IF ;
        */
        --�u�����O�ӳ��H���\ by kuo 1011019, after 20121019
			IF pbildate >= TO_DATE ('20121019', 'YYYYMMDD') THEN
				SELECT
					COUNT (*)
				INTO innhidiet
				FROM
					bil_dietset
				WHERE
					pfincode = bilrootrec.hfinacl
					AND
					pfkey = v_dieta;
			ELSE
				innhidiet := 1;
			END IF;   
        --NHI4�N�i�٬O�̤T�\��
			IF bilrootrec.hfinacl = 'NHI4' THEN
				innhidiet := 0;
			END IF;
			innhidiet                      := 0;
        --����p���Ҧ���¾�֫O�f�H
        --����p���Ҧ���¾�֫O�f�H�����A�٬O�̤T�\�p�� by kuo 1020327
        --IF ( v_oneDayDietType >= 'P' and v_oneDayDietType <= 'V') OR
			IF innhidiet > 0 THEN
        --IF (bilRootRec.Hfinacl IN ('NHI3','NHI6') and v_dischage_flag <> 'Y' and inNHIDIET>0) OR--���O�a,���O��,�̫�ѥH�\�p
        --   (biling_calculate_pkg.f_checkNHDiet(pCaseNo => bilRootRec.CaseNo) = 'Y' and inNHIDIET>0) THEN
				biloccurrec.pf_key             := v_dieta;
				dbms_output.put_line ('A');
           --����X�w��
				BEGIN
					SELECT
						dbpfile.pfprice1
					INTO v_price
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = biloccurrec.pf_key;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
						v_price        := 0;
				END;
				IF v_price > 0 THEN
					biloccurrec.charge_amount := round (v_price) + round (v_add_amt);
				ELSE
					biloccurrec.charge_amount := round (v_price);
				END IF;
				biloccurrec.diet_other_price   := round (v_add_amt);

           --debug
				actionflg                      := '09';

           --�Y�w�g�s�b�N���n�A�s�W�Fby kuo 1011204
				SELECT
					COUNT (*)
				INTO innhidiet
				FROM
					bil_occur
				WHERE
					caseno = pcaseno
					AND
					pf_key = v_dieta
					AND
					bil_date = pbildate;
				dbms_output.put_line (pbildate || ',' || innhidiet);
				IF innhidiet = 0 THEN
					INSERT INTO bil_occur VALUES biloccurrec;
				END IF;
			ELSE
           --���\
           --bilOccurRec.Pf_Key      := 'DIET' ||RTRIM(v_diet1);
				biloccurrec.pf_key          := v_dietb;
				v_price                     := 0;
           --����X�w��
				BEGIN
					SELECT
						dbpfile.pfprice1
					INTO v_price
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = biloccurrec.pf_key;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
						v_price        := 0;
				END;
           /*
           IF V_PRICE > 0 THEN
              bilOccurRec.Charge_Amount := ROUND(v_price) + ROUND(v_add_amt);
              v_add_amt := 0;
           ELSE
              bilOccurRec.Charge_Amount := ROUND(v_price);
           END IF ;

           bilOccurRec.Diet_Other_Price := ROUND(v_add_amt);
              */
           --debug
				actionflg                   := '10';
				biloccurrec.charge_amount   := v_price;
				IF biloccurrec.pf_key <> '        ' THEN
              --�Y�w�g�s�b�N���n�A�s�W�Fby kuo 1011204
					SELECT
						COUNT (*)
					INTO innhidiet
					FROM
						bil_occur
					WHERE
						caseno = pcaseno
						AND
						pf_key = v_dietb
						AND
						bil_date = pbildate;
					IF innhidiet = 0 THEN
						INSERT INTO bil_occur VALUES biloccurrec;
					END IF;
				END IF;

           --���\
				v_acnt_seq                  := v_acnt_seq + 1;
				biloccurrec.acnt_seq        := v_acnt_seq;
				biloccurrec.pf_key          := v_dietc;
           --����X�w��
				BEGIN
					SELECT
						dbpfile.pfprice1
					INTO v_price
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = biloccurrec.pf_key;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
						v_price        := 0;
				END;
           /*
           IF V_PRICE > 0 THEN
              bilOccurRec.Charge_Amount := ROUND(v_price) + ROUND(v_add_amt);
              v_add_amt := 0;
           ELSE
              bilOccurRec.Charge_Amount := ROUND(v_price);
           END IF ;
           */
           --bilOccurRec.Diet_Other_Price := ROUND(v_add_amt);
           --debug
				actionflg                   := '11';
				biloccurrec.charge_amount   := v_price;
				IF biloccurrec.pf_key <> '        ' THEN
              --�Y�w�g�s�b�N���n�A�s�W�Fby kuo 1011204
					SELECT
						COUNT (*)
					INTO innhidiet
					FROM
						bil_occur
					WHERE
						caseno = pcaseno
						AND
						pf_key = v_dietc
						AND
						bil_date = pbildate;
					IF innhidiet = 0 THEN
						INSERT INTO bil_occur VALUES biloccurrec;
					END IF;
				END IF;

           --���\
				v_acnt_seq                  := v_acnt_seq + 1;
				biloccurrec.acnt_seq        := v_acnt_seq;
				biloccurrec.pf_key          := v_dietd;
				v_price                     := 0;
           --����X�w��
				BEGIN
					SELECT
						dbpfile.pfprice1
					INTO v_price
					FROM
						cpoe.dbpfile
					WHERE
						dbpfile.pfkey = biloccurrec.pf_key;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
						v_price        := 0;
				END;
           /*
           IF V_PRICE > 0 THEN
              bilOccurRec.Charge_Amount := ROUND(v_price) + ROUND(v_add_amt);
              v_add_amt := 0;
           ELSE
              bilOccurRec.Charge_Amount := ROUND(v_price);
           END IF ;
           */
           --bilOccurRec.Diet_Other_Price := ROUND(v_add_amt);
           --debug
				actionflg                   := '12';
				biloccurrec.charge_amount   := v_price;
				IF biloccurrec.pf_key <> '        ' THEN
              --�Y�w�g�s�b�N���n�A�s�W�Fby kuo 1011204
					SELECT
						COUNT (*)
					INTO innhidiet
					FROM
						bil_occur
					WHERE
						caseno = pcaseno
						AND
						pf_key = v_dietd
						AND
						bil_date = pbildate;
					IF innhidiet = 0 THEN
						INSERT INTO bil_occur VALUES biloccurrec;
					END IF;
				END IF;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
       --select ERR_MSG into V_ERROR_MSG  FROM biling_spl_errlog
       -- WHERE SESSION_ID = V_SESSION_ID
       --   AND prog_name = v_program_name;
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			v_error_msg    := v_error_msg || ' ' || TO_CHAR (pbildate, 'YYYYMMDD') || ',' || actionflg;
       --DBMS_OUTPUT.PUT_LINE(v_program_name||','||v_error_code||','||V_ERROR_INFO||','||V_ERROR_MSG||':'||v_source_seq);
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

   --��|�b�Ȥ鵲?????�~
	PROCEDURE bilingdailybatch (
		pdate DATE
	) IS  
       --��Ѧ��b
		CURSOR cur_billtemp IS
		SELECT
			caseno
		FROM
			billtemp1
		WHERE
			trn_flag = 'N'
         --AND billtemp1.trn_date > (pdate - 1)
			AND
			upd_date > (pdate - 1)
		GROUP BY
			caseno;

       --�ثe�b�|�f�w,�̦�|����ϧǱƦC
		CURSOR cur_2 IS
		SELECT
			bil_root.*
		FROM
			bil_root,
			common.adm_bed
		WHERE
			bil_root.caseno = adm_bed.hcaseno
			AND
			bil_root.ward <> 'CPOE'--�W�[������ΥH�ư��u�W�����ո��
		ORDER BY
			admit_date DESC;

       --20160809 �[�J�Y�� PAT_ADM_DISCHARGE ���pi�� Bil_date ���R������ by kuo
		bilrootrec          bil_root%rowtype;
		v_messageout        VARCHAR2 (200);
		v_cnt               INTEGER;
		vv_cnt              INTEGER; -- ���|��J���,�b�歫�} by kuo 970723
		v_caseno            VARCHAR2 (10);

      --���~�T����
		v_program_name      VARCHAR2 (80);
		v_session_id        NUMBER (10);
		v_error_code        VARCHAR2 (20);
		v_error_msg         VARCHAR2 (400);
		v_error_info        VARCHAR2 (600);
      --v_source_seq     varchar2(20);
		e_user_exception EXCEPTION;
		bildailylogrec      bil_daliyjoblog%rowtype;
		bildailybasicrec    bil_daliyjobbasic%rowtype;
		bildailyerrlogrec   bil_daliyerrlog%rowtype;
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name           := 'biling_daily_pkg.bilingdailyBatch';
		v_session_id             := userenv ('SESSIONID');

        -- �f�z�����X�h�b (�|���i�ϥ�)
        /* BEGIN
            refund_virtual_pathology_item('PATH0000');
        END; */
		BEGIN
			biling_interface_pkg.importtointpatadmcase;
			SELECT
				bil_daliyjobbasic.*
			INTO bildailybasicrec
			FROM
				bil_daliyjobbasic
			WHERE
				bil_daliyjobbasic.job_code = 'BIL001';

            --���檬�A��'n'��ܤ��ΰ���F
			IF bildailybasicrec.prog_status = 'N' THEN
				return;
			ELSE
				bildailylogrec.job_kind           := bildailybasicrec.job_kind;
				bildailylogrec.job_date           := trunc (SYSDATE - 1);
				bildailylogrec.job_code           := 'BIL001';
				bildailylogrec.finished_flag      := 'N';
				bildailylogrec.created_by         := 'BilDaily';
				bildailylogrec.creation_date      := SYSDATE;
				bildailylogrec.last_updated_by    := 'BilDaily';
				bildailylogrec.last_update_date   := SYSDATE;
				BEGIN
					INSERT INTO bil_daliyjoblog VALUES bildailylogrec;
					COMMIT;
				EXCEPTION
					WHEN OTHERS THEN
						bildailyerrlogrec.post_date          := trunc (SYSDATE - 1);
						bildailyerrlogrec.job_code           := 'BIL001';
						bildailyerrlogrec.post_oper          := 'BilDaily';
						bildailyerrlogrec.sys_date           := SYSDATE;
						bildailyerrlogrec.err_code           := sqlcode;
						bildailyerrlogrec.err_msg            := sqlerrm;
						bildailyerrlogrec.err_info           := '�s�W�鵲�O���ɿ��~!!';
						bildailyerrlogrec.created_by         := 'BilDaily';
						bildailyerrlogrec.creation_date      := SYSDATE;
						bildailyerrlogrec.last_updated_by    := 'BilDaily';
						bildailyerrlogrec.last_update_date   := SYSDATE;
						INSERT INTO bil_daliyerrlog VALUES bildailyerrlogrec;
						COMMIT;
				END;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				bildailyerrlogrec.post_date          := trunc (SYSDATE - 1);
				bildailyerrlogrec.job_code           := 'BIL001';
				bildailyerrlogrec.post_oper          := 'BilDaily';
				bildailyerrlogrec.sys_date           := SYSDATE;
				bildailyerrlogrec.err_code           := sqlcode;
				bildailyerrlogrec.err_msg            := sqlerrm;
				bildailyerrlogrec.err_info           := '���o�鵲���ɸ�ƿ��~!!';
				bildailyerrlogrec.created_by         := 'BilDaily';
				bildailyerrlogrec.creation_date      := SYSDATE;
				bildailyerrlogrec.last_updated_by    := 'BilDaily';
				bildailyerrlogrec.last_update_date   := SYSDATE;
				INSERT INTO bil_daliyerrlog VALUES bildailyerrlogrec;
				COMMIT;
		END;

        --�ק�b�|���f�w���A
        --Bilingdailybatch(pDate => SYSDATE);
        --�R����ѵ��P��|���b�� by kuo
		DELETE FROM bil_occur
		WHERE
			caseno IN (
				SELECT
					caseno
				FROM
					bil_root
				WHERE
					pat_state = 'D'
					AND
					trunc (admit_date) = pdate
					AND
					dischg_date IS NULL
			);
		DELETE FROM bil_acnt_wk
		WHERE
			caseno IN (
				SELECT
					caseno
				FROM
					bil_root
				WHERE
					pat_state = 'D'
					AND
					trunc (admit_date) = pdate
					AND
					dischg_date IS NULL
			);
		COMMIT WORK;
		v_cnt                    := 0;
        --�ثe�b�|�f�w,�̦�|����ϧǱƦC�A�p��b��
		OPEN cur_2;
		LOOP
			FETCH cur_2 INTO bilrootrec;
			EXIT WHEN cur_2%notfound;
			v_cnt := v_cnt + 1;
             --�s����,�]�w�}�l��� by kuo 1001109, update release date to 1010623
			IF trunc (pdate) >= TO_DATE ('20120701', 'YYYYMMDD') THEN
                --P_DIET_INADM(BILROOTREC.CASENO, PDATE);
				p_diet_inadm_bycase (bilrootrec.caseno);
			END IF;
			biling_calculate_pkg.main_process (pcaseno => bilrootrec.caseno, poper => 'bildailyBatch', pmessageout => v_messageout);
		END LOOP;
		CLOSE cur_2;

        --��Ѧ��b
		OPEN cur_billtemp;
		LOOP
			FETCH cur_billtemp INTO v_caseno;
			EXIT WHEN cur_billtemp%notfound;
			v_cnt := v_cnt + 1;
			BEGIN
				SELECT
					*
				INTO bilrootrec
				FROM
					bil_root
				WHERE
					bil_root.caseno = v_caseno;

                 --add by Kuo 970723 for ���|��J�㭫�}�b�� start
				vv_cnt := 0;
				SELECT
					COUNT (*)
				INTO vv_cnt
				FROM
					billtemp1
				WHERE
					caseno = v_caseno
					AND
					bitmltfg = 'Y'
					AND
					trn_flag = 'N';
                 --add by Kuo 970723 for ���|��J�㭫�}�b�� end

                 --������|��,���s�p��
				IF trunc (bilrootrec.dischg_date) >= TO_DATE ('2008/04/01', 'yyyy/mm/dd') THEN
					biling_calculate_pkg.main_process (pcaseno => v_caseno, poper => 'bildailyBatch', pmessageout => v_messageout);
				ELSE
					p_billtempbycase (pcaseno => v_caseno);
				END IF;

                 --add by Kuo 970723 for ���|��J�㭫�}�b�� start
				IF vv_cnt > 0 THEN  --���}�b��
					INSERT INTO bil_incomsta_adjst VALUES (
						v_caseno,
						SYSDATE,
						'LEAVE',
						NULL,
						'N',
						''
					); -- add by eron 970811 �������|�Ըɱbcase �妬�ɻݽվ�
					biling_process_pkg.newbilingbil (v_caseno, '1', '', v_messageout);
					IF v_messageout = '0' THEN --�}�߱b����榨�\
                         -- p_debt_bycase(v_CaseNo, v_messageOut);
						cnvrt_owed_to_debt_prc (v_caseno, 'bilingdailyBatch', v_messageout);
					END IF;
				END IF;
				COMMIT;
                 --add by Kuo 970723 for ���|��J�㭫�}�b�� end
			EXCEPTION
				WHEN OTHERS THEN
					v_error_code   := sqlcode;
					v_error_info   := sqlerrm;
			END;
		END LOOP;
		CLOSE cur_billtemp;
		bildailylogrec.log_msg   := '�@' || TO_CHAR (v_cnt) || '��,�p�⧹��!!';

        --�ק�鵲���榨�\���O
		BEGIN
			UPDATE bil_daliyjoblog
			SET
				bil_daliyjoblog.finished_flag = 'Y',
				bil_daliyjoblog.last_update_date = SYSDATE,
				bil_daliyjoblog.log_msg = bildailylogrec.log_msg
			WHERE
				bil_daliyjoblog.job_kind = bildailylogrec.job_kind
				AND
				bil_daliyjoblog.job_date = bildailylogrec.job_date
				AND
				bil_daliyjoblog.job_code = bildailylogrec.job_code;
		EXCEPTION
			WHEN OTHERS THEN
				bildailyerrlogrec.post_date          := trunc (SYSDATE - 1);
				bildailyerrlogrec.job_code           := 'BIL001';
				bildailyerrlogrec.post_oper          := 'DailyJobForBilling';
				bildailyerrlogrec.sys_date           := SYSDATE;
				bildailyerrlogrec.err_code           := sqlcode;
				bildailyerrlogrec.err_msg            := sqlerrm;
				bildailyerrlogrec.err_info           := '�ק�鵲���榨�\���O����!!';
				bildailyerrlogrec.created_by         := 'DailyJobForBilling';
				bildailyerrlogrec.creation_date      := SYSDATE;
				bildailyerrlogrec.last_updated_by    := 'DailyJobForBilling';
				bildailyerrlogrec.last_update_date   := SYSDATE;
				INSERT INTO bil_daliyerrlog VALUES bildailyerrlogrec;
		END;
		COMMIT;
		bil_sendmail_dailylog ('cc3f@vghtc.gov.tw');
		bil_sendmail_dailylog ('chkuo@vghtc.gov.tw');
		bil_sendmail_dailylog ('kjlu@vghtc.gov.tw');
		eventlog.batchlog ('0', 'biling_daily_pkg.bilingdailyBatch', 'FINISH', '');
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

    --�g�J�C��T�w�O�ζibilOccur
	PROCEDURE adddailyservicefee1 (
		psysdate DATE
	) IS
        --���o���b�|���f�w
		CURSOR cur_bildate (
			pcaseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_date
		WHERE
			bil_date.caseno = pcaseno
			AND
			bil_date.bil_date = psysdate
			AND
			bil_date.daily_flag = 'N';
--          FOR UPDATE;

       --���X���b�|���f�w
		CURSOR cur_patadmcase IS
		SELECT
			*
		FROM
			bil_root
		WHERE
			bil_root.admit_date <= psysdate
			AND
			(bil_root.dischg_date IS NULL
			 OR
			 bil_root.dischg_date >= psysdate);
		bilrootrec   bil_root%rowtype;
		bildaterec   bil_date%rowtype;
		v_pfkey      VARCHAR2 (12);
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name   := 'biling_daily_pkg.AdddailyServiceFee1';
		v_session_id     := userenv ('SESSIONID');

        --���ثe�b�|�����f�w�M��
		OPEN cur_patadmcase;
		LOOP
			FETCH cur_patadmcase INTO bilrootrec;
			EXIT WHEN cur_patadmcase%notfound;

             --�i�}bildate
			expandbildate (bilrootrec.caseno, psysdate);
			OPEN cur_bildate (bilrootrec.caseno);
			FETCH cur_bildate INTO bildaterec;
			IF cur_bildate%found THEN
				UPDATE bil_date
				SET
					bil_date.daily_flag = 'Y'
				WHERE
					caseno = bildaterec.caseno
					AND
					bil_date = bildaterec.bil_date;  
--                  WHERE CURRENT OF CUR_bildate;
				IF bildaterec.beddge IS NULL THEN
					BEGIN
						SELECT
							hbeddge
						INTO
							bildaterec
						.beddge
						FROM
							common.adm_bed
						WHERE
							rtrim (hnurstat) = rtrim (bildaterec.wardno)
							AND
							rtrim (hbedno) = rtrim (bildaterec.bed_no);
					EXCEPTION
						WHEN OTHERS THEN
							bildaterec.beddge := '';
					END;
				END IF;

                 --�}�l�J�T�w�O��
                 --��BEDDGE���~�J(�]����Ƥ���)
				IF bildaterec.beddge IS NOT NULL THEN
                     --1.�f�жO
					v_pfkey   := 'WARD' || bildaterec.beddge;
					insertbiloccur (bilrootrec.caseno, ppatnum => bilrootrec.hpatnum, ppfkey => v_pfkey, pbildate => psysdate, pward => bildaterec
					.wardno, pbedno => bildaterec.bed_no);
                     --2.�@�z�O
					v_pfkey   := 'NURS' || bildaterec.beddge;
					insertbiloccur (bilrootrec.caseno, ppatnum => bilrootrec.hpatnum, ppfkey => v_pfkey, pbildate => psysdate, pward => bildaterec
					.wardno, pbedno => bildaterec.bed_no);
                     --3.��v�O
					v_pfkey   := 'DIAG' || bildaterec.beddge;
					insertbiloccur (bilrootrec.caseno, ppatnum => bilrootrec.hpatnum, ppfkey => v_pfkey, pbildate => psysdate, pward => bildaterec
					.wardno, pbedno => bildaterec.bed_no);
				END IF;
			END IF;
			CLOSE cur_bildate;
		END LOOP;
		CLOSE cur_patadmcase;
		COMMIT WORK;
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

/*�P�_���L�Ϊ��{���X mark by �q�� at 2010-05-17
  --��J��|�f�w�򥻸�� pat_adm_case into bil_root
  PROCEDURE ImportBilRootBatch(pDate date)
  IS
  BEGIN
       --�]�w�{���W�٤�session_id
        v_program_name := 'biling_daily_pkg.ImportBilRootBatch';
        v_session_id   := USERENV('SESSIONID');
  EXCEPTION
   WHEN OTHERS
   THEN
       v_error_code := SQLCODE;
       v_error_info := SQLERRM;
       ROLLBACK WORK;

       DELETE FROM biling_spl_errlog
        WHERE session_id = v_session_id
          AND prog_name = v_program_name;

       INSERT INTO biling_spl_errlog
           (session_id,sys_date,prog_name,err_code,err_msg,err_info,source_seq)
      VALUES (v_session_id,sysdate,v_program_name,v_error_code,v_error_msg,v_error_info,v_source_seq);
      commit work;
  END ;
*/
  --��s�b�|���f�w�򥻸��
	PROCEDURE updatebilroot IS
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name   := 'biling_daily_pkg.UpdateBilRoot';
		v_session_id     := userenv ('SESSIONID');
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
	PROCEDURE expandbildate (
		i_hcaseno    VARCHAR2,
		i_bil_date   DATE
	) IS
		r_pat_adm_case        common.pat_adm_case%rowtype;
		r_bil_root            bil_root%rowtype;
		r_bil_date            bil_date%rowtype;
		l_pre_max_days        bil_date.days%TYPE;
		r_pristine_bil_date   bil_date%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
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

 		-- �ˬd���ɬO�_�w����
		FOR r_exist_bil_date IN (
			SELECT
				*
			FROM
				bil_date
			WHERE
				caseno = r_pat_adm_case.hcaseno
				AND
				bil_date = i_bil_date
		) LOOP
			r_pristine_bil_date := r_exist_bil_date;

            -- �u���@��
			EXIT;
		END LOOP;

		-- �Y���ɥ����͡A��l�Ƥ���
		IF r_pristine_bil_date.caseno IS NULL THEN
			r_bil_date.caseno      := r_pat_adm_case.hcaseno;
			r_bil_date.hpatnum     := r_pat_adm_case.hhisnum;
			r_bil_date.bil_date    := i_bil_date;
			r_bil_date.pat_state   := r_pat_adm_case.hpatstat;
			r_bil_date.pay_code    := r_bil_root.pay_code;
			-- �s�W���ɡA�n��J�����O
			r_bil_date.diet_flag   := 'N';
		-- �Y���ɤw���͡A�H����ɬ��򩳧�s
		ELSE
			r_bil_date := r_pristine_bil_date;
		END IF;
		r_bil_date.daily_flag := 'N';

        -- �B�z�ɦ�
		FOR r_pat_adm_bed IN (
			SELECT
				*
			FROM
				common.pat_adm_bed
			WHERE
				hcaseno = r_bil_date.caseno
				AND
				hbeddt <= TO_CHAR (r_bil_date.bil_date, 'YYYYMMDD')
			ORDER BY
				hbeddt DESC,
				hbedtm DESC
		) LOOP
			r_bil_date.wardno   := r_pat_adm_bed.hnursta;
			r_bil_date.bed_no   := r_pat_adm_bed.hbed;

			-- �Y���ɥ����ͩΧɦ즳���ʤ~��s�ɦ쵥�š]�����L�����ɧɦ쵥�ŤS�Q�٭�^
			IF r_pristine_bil_date.caseno IS NULL OR r_bil_date.wardno != r_pristine_bil_date.wardno OR r_bil_date.bed_no != r_pristine_bil_date
			.bed_no THEN
				-- �B�z�ɦ쵥�šB��C���O
				SELECT
					hbeddge,
					CASE
						WHEN hbeddge LIKE '%CH%' THEN
							'C'
						ELSE
							'E'
					END
				INTO
						r_bil_date
					.beddge,
					r_bil_date.ec_flag
				FROM
					common.adm_bed
				WHERE
					hnurstat = r_bil_date.wardno
					AND
					hbedno = r_bil_date.bed_no;
			END IF;

            -- �u���̫�@����ɰO��
			EXIT;
		END LOOP;

        -- �B�z����
		FOR r_pat_adm_financial IN (
			SELECT
				*
			FROM
				common.pat_adm_financial
			WHERE
				hcaseno = r_bil_date.caseno
				AND
				hfindate <= TO_CHAR (r_bil_date.bil_date, 'YYYYMMDD')
			ORDER BY
				hfindate DESC,
				hfininf DESC
		) LOOP
			r_bil_date.hfinacl    := r_pat_adm_financial.hfinancl;
			r_bil_date.hfinacl2   := r_pat_adm_financial.hfincl2;
			r_bil_date.hnhi1typ   := r_pat_adm_financial.hnhi1typ;
			r_bil_date.htraffic   := r_pat_adm_financial.htraffic;
			r_bil_date.hpaytype   := r_pat_adm_financial.hpaytype;

			-- �Y���ɥ����ͩΨ��������ʡA�����O�n���u
			IF r_pristine_bil_date.caseno IS NULL OR r_bil_date.hfinacl != r_pristine_bil_date.hfinacl OR r_bil_date.hfinacl2 != r_pristine_bil_date
			.hfinacl2 THEN
				r_bil_date.diet_flag := 'N';
			END IF;

            -- �u���̷s�@��
			EXIT;
		END LOOP;

        -- 14 �Ѥ��A�J�|�����P����|�]�B�z�Ѽƶ��Ҽ{�֥[�^
		IF r_pat_adm_case.hreadmit = 'Y' THEN
			FOR r_pre_bil_root IN (
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
					MAX (days)
				INTO l_pre_max_days
				FROM
					bil_date
				WHERE
					caseno = r_pre_bil_root.caseno
					AND
					ec_flag = r_bil_date.ec_flag
					AND
					hfinacl = r_bil_date.hfinacl;

                -- �u���e�@����|�O��
				EXIT;
			END LOOP;
		END IF;

        -- �B�z�Ѽ�
		SELECT
			nvl (l_pre_max_days, 0) + COUNT (*) + 1
		INTO
			r_bil_date
		.days
		FROM
			bil_date
		WHERE
			caseno = r_bil_date.caseno
			AND
			hfinacl = r_bil_date.hfinacl
			AND
			ec_flag = r_bil_date.ec_flag
			AND
			bil_date < r_bil_date.bil_date;

        -- �Y���ɥ����͡A�s�W����
		IF r_pristine_bil_date.caseno IS NULL THEN
			r_bil_date.created_by         := 'biling';
			r_bil_date.creation_date      := SYSDATE;
			r_bil_date.last_updated_by    := r_bil_date.created_by;
			r_bil_date.last_update_date   := r_bil_date.creation_date;
			INSERT INTO bil_date VALUES r_bil_date;
		-- �Y���ɤw���͡A��s����
		ELSE
		    -- �Y�ɦ�Ψ������ܤ~��s����
			IF r_bil_date.wardno != r_pristine_bil_date.wardno OR r_bil_date.bed_no != r_pristine_bil_date.bed_no OR r_bil_date.hfinacl !=
			r_pristine_bil_date.hfinacl OR r_bil_date.hfinacl2 != r_pristine_bil_date.hfinacl2 THEN
				r_bil_date.last_updated_by    := 'biling';
				r_bil_date.last_update_date   := SYSDATE;
				UPDATE bil_date
				SET
					row = r_bil_date
				WHERE
					caseno = r_bil_date.caseno
					AND
					bil_date = r_bil_date.bil_date;
			END IF;
		END IF;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'expandbildate';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_hcaseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
	END;
	PROCEDURE adddailyservicefeeforcase (
		i_hcaseno    VARCHAR2,
		i_bil_date   DATE
	) IS
		r_pat_adm_case        common.pat_adm_case%rowtype;
		r_bil_root            bil_root%rowtype;
		r_biling_spl_errlog   biling_spl_errlog%rowtype;
		l_pf_key              bil_occur.pf_key%TYPE;
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

		-- ���o�b�Ȥ���
		FOR r_bil_date IN (
			SELECT
				*
			FROM
				bil_date
			WHERE
				caseno = r_pat_adm_case.hcaseno
				AND
				bil_date = i_bil_date
		) LOOP
			l_pf_key := NULL;

			/* �Y��X�|��S�����A�]�X�|��U��b�y�{�|�N���f�жO�B�@�z�O�R���A��������������u�~�|�A���͡C
			   �ҥH�C�����n�ˬd���f�жO�B��v�O�B�@�z�O�O�_���b�A�Y�L�b�h�n���u�C
			   �̫�ѥ~�h�� BILING_CALCULATE_PKG.checkbildate �R���������ͪ��T�w�O�ΡC */
			FOR r_bil_occur_cnt IN (
				SELECT
					t1.fee_kind,
					nvl (t2.cnt, 0) AS cnt
				FROM
					((
						SELECT
							fee_kind
						FROM
							bil_feekindbas
						WHERE
							fee_kind IN (
								'01',
								'03',
								'05'
							)
					) t1
					LEFT JOIN (
						SELECT
							fee_kind,
							COUNT (*) AS cnt
						FROM
							bil_occur
						WHERE
							caseno = r_bil_date.caseno
							AND
							bil_date = r_bil_date.bil_date
							AND
							fee_kind IN (
								'01',
								'03',
								'05'
							)
							AND
							operator_name = 'dailyBatch'
						GROUP BY
							fee_kind
					) t2 ON t1.fee_kind = t2.fee_kind)
				ORDER BY
					t1.fee_kind
			) LOOP
				-- �b�|���B�D�X�|��B���J�X�|�����f�жO�B�@�z�O�]��i����X�^
				IF r_bil_root.dischg_date IS NULL OR r_bil_date.bil_date < trunc (r_bil_root.dischg_date) OR r_bil_date.bil_date = trunc (r_bil_root
				.admit_date) THEN
					IF r_bil_occur_cnt.fee_kind IN (
						'01',
						'05'
					) AND r_bil_occur_cnt.cnt = 0 THEN
						r_bil_date.daily_flag := 'N';
					END IF;
				END IF;
				-- ������v�O�]��i��X�^
				IF r_bil_occur_cnt.fee_kind = '03' AND r_bil_occur_cnt.cnt = 0 THEN
					r_bil_date.daily_flag := 'N';
				END IF;
			END LOOP;

			-- �Y�n���J�T�w�O��
			IF r_bil_date.daily_flag = 'N' THEN
				-- �R�����f�жO�B��v�O�B�@�z�O
				DELETE FROM bil_occur
				WHERE
					bil_occur.caseno = r_bil_date.caseno
					AND
					bil_date = r_bil_date.bil_date
					AND
					fee_kind IN (
						'01',
						'03',
						'05'
					)
					AND
					operator_name = 'dailyBatch';

				-- �J�f�жO
				l_pf_key := 'WARD' || r_bil_date.beddge;
				insertbiloccur (r_bil_date.caseno, r_bil_date.hpatnum, l_pf_key, r_bil_date.bil_date, r_bil_date.wardno, r_bil_date.bed_no);                                

				-- �J��v�O
				IF r_bil_date.beddge IN (
					'12AA',
					'12BB'
				) THEN
					l_pf_key := 'DIAG1';
				ELSE
					l_pf_key := 'DIAG' || r_bil_date.beddge;
				END IF;
				insertbiloccur (r_bil_date.caseno, r_bil_date.hpatnum, l_pf_key, r_bil_date.bil_date, r_bil_date.wardno, r_bil_date.bed_no);  

				-- �J�@�z�O
				IF r_bil_date.beddge IN (
					'12AA',
					'12BB'
				) THEN
					l_pf_key := 'NURS1';
				ELSE
					l_pf_key := 'NURS' || r_bil_date.beddge;
				END IF;
				insertbiloccur (r_bil_date.caseno, r_bil_date.hpatnum, l_pf_key, r_bil_date.bil_date, r_bil_date.wardno, r_bil_date.bed_no);

				-- ��s���O
				UPDATE bil_date
				SET
					daily_flag = 'Y'
				WHERE
					caseno = r_bil_date.caseno
					AND
					bil_date = r_bil_date.bil_date;
			END IF;

			-- �Y�n���J�����O
			IF r_bil_date.diet_flag = 'N' THEN
				-- �R�������O
				DELETE FROM bil_occur
				WHERE
					caseno = r_bil_date.caseno
					AND
					bil_date = r_bil_date.bil_date
					AND
					fee_kind = '02'
					AND
					pf_key LIKE 'DIET%'
					AND
					length (pf_key) <= 6;
				DELETE FROM bil_occur
				WHERE
					caseno = r_bil_date.caseno
					AND
					bil_date = r_bil_date.bil_date
					AND
					fee_kind = '02'
					AND
					operator_name = 'DDAILY';

				-- �J�����O
				insertbiloccurfordiet (r_bil_date.caseno, r_bil_date.bil_date);

				-- ��s���O
				UPDATE bil_date
				SET
					diet_flag = 'Y'
				WHERE
					caseno = r_bil_date.caseno
					AND
					bil_date = r_bil_date.bil_date;
			END IF;

			-- �u���@��
			EXIT;
		END LOOP;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'adddailyservicefeeforcase';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_hcaseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
	END;

  --��Jbiltemp_leave��Ʀ�biloccur
	PROCEDURE importbiltempleave (
		pcaseno VARCHAR2
	) IS
       --�ܼƫŧi��
		billtemprec        billtemp_leave%rowtype;
		biloccurrec        bil_occur%rowtype;
		bilrootrec         bil_root%rowtype;
		CURSOR cur_billtemp (
			pcaseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			billtemp_leave
		WHERE
			caseno = pcaseno
			AND
			trn_flag = 'N'
		FOR UPDATE;
		CURSOR cur_spct (
			ppfkey VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_spct_dtl
		WHERE
			bil_spct_dtl.pf_key = ppfkey;
		v_caseno           VARCHAR2 (20);
		v_patnum           VARCHAR2 (10);
		v_seqno            INTEGER;
		v_onedaydiettype   VARCHAR2 (01);
		v_additionalqty    VARCHAR2 (03);
		v_segregateflag    VARCHAR2 (02);
		v_diet1            VARCHAR2 (02);
		v_diet2            VARCHAR2 (02);
		v_diet3            VARCHAR2 (02);
		v_price            NUMBER (10, 2);
		v_add_amt          NUMBER (10, 2);
		v_fee_type         VARCHAR2 (02);
		bilspctdtlrec      bil_spct_dtl%rowtype;
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name   := 'biling_daily_pkg.importbilTempLeave';
		v_session_id     := userenv ('SESSIONID');

         -- CHECK �ӯf�w��ƬO�_�w�s�b�bBILROOT
         --�S���N�qPAT_ADM_CASE INSERT �i��
		BEGIN
			SELECT
				*
			INTO bilrootrec
			FROM
				bil_root
			WHERE
				bil_root.caseno = v_caseno;
		EXCEPTION
			WHEN no_data_found THEN
				biling_interface_pkg.importtointpatadmcase;
				BEGIN
					SELECT
						bil_root.hpatnum
					INTO v_patnum
					FROM
						bil_root
					WHERE
						bil_root.caseno = pcaseno;
				EXCEPTION
					WHEN OTHERS THEN
						v_error_code   := sqlcode;
						v_error_info   := sqlerrm;
				END;
				v_seqno := 0;
		END;
		SELECT
			MAX (bil_occur.acnt_seq)
		INTO v_seqno
		FROM
			bil_occur
		WHERE
			bil_occur.caseno = pcaseno;
		IF v_seqno IS NULL THEN
			v_seqno := 0;
		END IF;
		OPEN cur_billtemp (v_caseno);
		LOOP
			FETCH cur_billtemp INTO billtemprec;
			EXIT WHEN cur_billtemp%notfound;
			v_seqno                := v_seqno + 1;
			billtemprec.bltmcode   := rtrim (billtemprec.bltmcode);

                --�B�z�뭹����
			IF billtemprec.bltmcode LIKE 'DIET%' AND length (trim (billtemprec.bltmcode)) = 5 THEN
                  /*A.�榡
                      COL. 1 - 8    HCASENO
                      COL. 9 - 14   DATE
                      COL. 28-35   �p���X (DIET + ONE DAY DIET TYPE)
                      COL. 117     �O�_�j���\( Y/N)
                      COL. 118     ���[��i�~�\��
                      COL. 124-129  BREAKFAST,LUNCH,DINNER DIET TYPE

                    B. �p��W�h
                       1. IF (ONE DAY DIET TYPE) >='P & (ONE DAY DIET TYPE) <='V'  THEN
                         �ݩ����p���Ҧ�,�B��i����X
                       2. IF SUBSTR(�p���X,1,7) ='DIETTCM' THEN �`���`���u�Ҧ�
                       3. IF (COL. 118) >='1'  & (COL. 118) <='3' THEN�����O+ [ NT$50 * (COL.
                         118)]
                       4. IF (COL. 117) = 'Y' THEN �����O+ NT$10 */
				v_onedaydiettype               := substr (billtemprec.bltmcode, 5, 1);
				v_segregateflag                := substr (billtemprec.bltmfill, 1, 1);
				v_additionalqty                := to_number (substr (billtemprec.bltmfill, 2, 1));
				v_diet1                        := substr (billtemprec.bltmrscd, 1, 2);
				v_diet2                        := substr (billtemprec.bltmrscd, 3, 2);
				v_diet3                        := substr (billtemprec.bltmrscd, 5, 2);
				biloccurrec.caseno             := pcaseno;
				biloccurrec.patient_id         := v_patnum;
				biloccurrec.acnt_seq           := v_seqno;
				biloccurrec.bil_date           := biling_common_pkg.f_get_chdate (billtemprec.bltmdate);
				IF biloccurrec.bil_date > nvl (bilrootrec.dischg_date, SYSDATE) THEN
					biloccurrec.bil_date := trunc (nvl (bilrootrec.dischg_date, SYSDATE));
				END IF;
				biloccurrec.order_seqno        := billtemprec.bltmseq;
				biloccurrec.credit_debit       := '+';
				biloccurrec.create_dt          := biling_common_pkg.f_get_chdate (billtemprec.bltmbldt);
				biloccurrec.fee_kind           := '02';
				biloccurrec.qty                := 1;
				biloccurrec.emergency          := billtemprec.bltmemg;

                    --�ݭץ�,���ӬOself_flag
				IF billtemprec.bltmanes = 'PR' THEN
					biloccurrec.elf_flag := 'Y';
				ELSE
					biloccurrec.elf_flag := 'N';
				END IF;
				biloccurrec.anesthesia         := billtemprec.bltmanes;
				biloccurrec.income_dept        := billtemprec.bltmidep;
				biloccurrec.log_location       := billtemprec.bltmstat;
				biloccurrec.operator_name      := billtemprec.bluserid;
				biloccurrec.or_order_catalog   := billtemprec.bltmcat;
				biloccurrec.complication       := billtemprec.bltmcomp;
				biloccurrec.or_order_item_no   := billtemprec.bltmorno;
				biloccurrec.combination_item   := billtemprec.bltmcomb;
				biloccurrec.patient_section    := billtemprec.bltmsect;
				biloccurrec.ward               := billtemprec.bltmsect;
				biloccurrec.created_by         := 'billing';
				biloccurrec.creation_date      := SYSDATE;
				biloccurrec.last_updated_by    := 'billing';
				biloccurrec.last_update_date   := SYSDATE;
				v_add_amt                      := 0;

                   --����p���Ҧ�
				IF v_onedaydiettype >= 'P' AND v_onedaydiettype <= 'V' THEN
					biloccurrec.pf_key := billtemprec.bltmcode;
                      --�j���\+10��
					IF v_segregateflag = 'Y' THEN
						v_add_amt := v_add_amt + 10;
					END IF;
                      --���[��i�\ >='1'  &  <='3' �����O+ [ NT$50 * v_additionalQty
					IF v_additionalqty >= 1 AND v_additionalqty <= 3 THEN
						v_add_amt := v_add_amt + (v_additionalqty * 50);
					END IF;
				ELSE
					biloccurrec.pf_key          := 'DIET' || rtrim (v_diet1);
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
							dbpfile.pfkey = biloccurrec.pf_key;
					EXCEPTION
						WHEN OTHERS THEN
							v_error_code   := sqlcode;
							v_error_info   := sqlerrm;
					END;
					biloccurrec.charge_amount   := v_price + v_add_amt;
					INSERT INTO bil_occur VALUES biloccurrec;
					v_seqno                     := v_seqno + 1;
					biloccurrec.acnt_seq        := v_seqno;
					biloccurrec.pf_key          := 'DIET' || rtrim (v_diet2);
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
							dbpfile.pfkey = biloccurrec.pf_key;
					EXCEPTION
						WHEN OTHERS THEN
							v_error_code   := sqlcode;
							v_error_info   := sqlerrm;
					END;
					biloccurrec.charge_amount   := v_price + v_add_amt;
					INSERT INTO bil_occur VALUES biloccurrec;
					v_seqno                     := v_seqno + 1;
					biloccurrec.acnt_seq        := v_seqno;
					biloccurrec.pf_key          := 'DIET' || rtrim (v_diet3);
					biloccurrec.charge_amount   := v_price;
					INSERT INTO bil_occur VALUES biloccurrec;
				END IF;
			ELSE
				IF billtemprec.bltmcomp = 'Y' THEN
					OPEN cur_spct (billtemprec.bltmcode);
					LOOP
						FETCH cur_spct INTO bilspctdtlrec;
						EXIT WHEN cur_spct%notfound;
						biloccurrec.caseno             := pcaseno;
						biloccurrec.patient_id         := v_patnum;
						biloccurrec.acnt_seq           := v_seqno;
						biloccurrec.bil_date           := biling_common_pkg.f_get_chdate (billtemprec.bltmdate);
						biloccurrec.order_seqno        := rtrim (billtemprec.bltmseq);
						biloccurrec.pf_key             := rtrim (bilspctdtlrec.child_code);

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
								dbpfile.pfkey = biloccurrec.pf_key;
						EXCEPTION
							WHEN OTHERS THEN
								v_error_code   := sqlcode;
								v_error_info   := sqlerrm;
						END;
						IF rtrim (v_fee_type) <> '' AND v_fee_type IS NOT NULL AND length (rtrim (v_fee_type)) = 2 THEN
							biloccurrec.fee_kind := v_fee_type;
						ELSE
							biloccurrec.fee_kind := rtrim (billtemprec.bltmtp);
						END IF;
						biloccurrec.credit_debit       := rtrim (billtemprec.bltmcrdb);
						biloccurrec.create_dt          := biling_common_pkg.f_get_chdate (billtemprec.bltmbldt);
						biloccurrec.qty                := bilspctdtlrec.qty;
						biloccurrec.charge_amount      := v_price;
						biloccurrec.emergency          := billtemprec.bltmemg;
                                --�ݭץ�,���ӬOself_flag
						IF billtemprec.bltmanes = 'PR' THEN
							biloccurrec.elf_flag := 'Y';
						ELSE
							biloccurrec.elf_flag := 'N';
						END IF;
						biloccurrec.anesthesia         := rtrim (billtemprec.bltmanes);
						biloccurrec.income_dept        := rtrim (billtemprec.bltmidep);
						biloccurrec.log_location       := rtrim (billtemprec.bltmstat);
						biloccurrec.operator_name      := rtrim (billtemprec.bluserid);
						biloccurrec.or_order_catalog   := rtrim (billtemprec.bltmcat);
						biloccurrec.complication       := rtrim (billtemprec.bltmcomp);
						biloccurrec.or_order_item_no   := rtrim (billtemprec.bltmorno);
						biloccurrec.combination_item   := rtrim (billtemprec.bltmcomb);
						biloccurrec.patient_section    := rtrim (billtemprec.bltmsect);
						biloccurrec.ward               := rtrim (billtemprec.bltmsect);
						biloccurrec.created_by         := 'billing';
						biloccurrec.creation_date      := SYSDATE;
						biloccurrec.last_updated_by    := 'billing';
						biloccurrec.last_update_date   := SYSDATE;
						INSERT INTO bil_occur VALUES biloccurrec;
					END LOOP;
					CLOSE cur_spct;
				ELSE
					biloccurrec.caseno             := pcaseno;
					biloccurrec.patient_id         := v_patnum;
					biloccurrec.acnt_seq           := v_seqno;
					biloccurrec.bil_date           := biling_common_pkg.f_get_chdate (billtemprec.bltmdate);
					biloccurrec.order_seqno        := rtrim (billtemprec.bltmseq);
					biloccurrec.pf_key             := rtrim (billtemprec.bltmcode);
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
							dbpfile.pfkey = biloccurrec.pf_key;
					EXCEPTION
						WHEN OTHERS THEN
							v_error_code   := sqlcode;
							v_error_info   := sqlerrm;
					END;
					IF rtrim (v_fee_type) <> '' AND v_fee_type IS NOT NULL AND length (rtrim (v_fee_type)) = 2 THEN
						biloccurrec.fee_kind := v_fee_type;
					ELSE
						biloccurrec.fee_kind := rtrim (billtemprec.bltmtp);
					END IF;
					biloccurrec.credit_debit       := rtrim (billtemprec.bltmcrdb);
					biloccurrec.create_dt          := biling_common_pkg.f_get_chdate (billtemprec.bltmbldt);
					biloccurrec.qty                := billtemprec.bltmqty;
					biloccurrec.charge_amount      := billtemprec.bltmamt / 10;
					biloccurrec.emergency          := billtemprec.bltmemg;

                        --�ݭץ�,���ӬOself_flag
					IF billtemprec.bltmanes = 'PR' THEN
						biloccurrec.elf_flag := 'Y';
					ELSE
						biloccurrec.elf_flag := 'N';
					END IF;
					biloccurrec.anesthesia         := rtrim (billtemprec.bltmanes);
					biloccurrec.income_dept        := rtrim (billtemprec.bltmidep);
					biloccurrec.log_location       := rtrim (billtemprec.bltmstat);
					biloccurrec.operator_name      := rtrim (billtemprec.bluserid);
					biloccurrec.or_order_catalog   := rtrim (billtemprec.bltmcat);
					biloccurrec.complication       := rtrim (billtemprec.bltmcomp);
					biloccurrec.or_order_item_no   := rtrim (billtemprec.bltmorno);
					biloccurrec.combination_item   := rtrim (billtemprec.bltmcomb);
					biloccurrec.patient_section    := rtrim (billtemprec.bltmsect);
					biloccurrec.ward               := rtrim (billtemprec.bltmsect);
					biloccurrec.created_by         := 'billing';
					biloccurrec.creation_date      := SYSDATE;
					biloccurrec.last_updated_by    := 'billing';
					biloccurrec.last_update_date   := SYSDATE;
					INSERT INTO bil_occur VALUES biloccurrec;
				END IF;
			END IF;
			UPDATE billtemp1
			SET
				trn_flag = 'Y',
				trn_date = SYSDATE
			WHERE
				CURRENT OF cur_billtemp;
		END LOOP;
		CLOSE cur_billtemp;
		COMMIT WORK;
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

  --�զX���S��W�hcehck
	FUNCTION special_code_check (
		ppfkey VARCHAR2
	) RETURN VARCHAR2 IS
		t_fg VARCHAR2 (01) := '0';
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name   := 'biling_daily_pkg.special_code_check';
		v_session_id     := userenv ('SESSIONID');

       --IF PPFKEY IN ('30010000','30020000','25001000','25001001','25001002','25001003','25001004','25110000') THEN
       --����25001000 by kuo ,requested by ���A�� 20180807
		IF ppfkey IN (
			'30010000',
			'30020000',
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

/*=======================================================================================
  SYSTEM  : �x���a���`��|-��|�b�Ȩt��
  Created : 2007.09.03
  Author  : Eron Yang
  Purpose : �ΨӰ���妸����C�L
  Remark  : �ǤJ�Ѽ� pUser = �����
=======================================================================================*/
	PROCEDURE print_daily_report (
		puser VARCHAR2
	) IS
		pcaseno        VARCHAR2 (80) := puser;
		v_error_info   VARCHAR2 (1000);
	BEGIN
		v_error_info   := '�C�L��|�{�����J�έp�����';
		bil_call_report (pcaseno => 'Daily', phttpstring => 'http://oracleas.vghtc.gov.tw:7780/reports/rwservlet?' || 'userid=billing/billing@hissp1'
		|| '&destype=file' || '&desformat=wide' || '&desname=d:\BatchPrint\CLASS_G\Noform_BIL5030_txt_L6_C10_F16.ftp' || '&report=BIL5030_txt.rdf&PAYDATE='
		|| TO_CHAR (SYSDATE - 1, 'yyyy-mm-dd'), preport => '��|�{�����J�έp�����');
		bil_report_log_test (v_error_info, '�C��');
		v_error_info   := '�C�L��|���O�����Ӫ�';
		bil_call_report (pcaseno => 'Daily', phttpstring => 'http://oracleas.vghtc.gov.tw:7780/reports/rwservlet?' || 'userid=billing/billing@hissp1'
		|| '&destype=file' || '&desformat=wide' || '&desname=d:\BatchPrint\CLASS_G\Noform_BIL5010_txt_L6_C10_F16.ftp' || '&report=BIL5010_txt.rdf&PAYDATE='
		|| TO_CHAR (SYSDATE - 1, 'yyyy-mm-dd'), preport => '��|���O�����Ӫ�');
		bil_report_log_test (v_error_info, '�C��');
		v_error_info   := '�C�L�����b�ڲέp�����';
		bil_call_report (pcaseno => 'Daily', phttpstring => 'http://oracleas.vghtc.gov.tw:7780/reports/rwservlet?' || 'userid=billing/billing@hissp1'
		|| '&destype=file' || '&desformat=wide' || '&desname=d:\BatchPrint\CLASS_G\Noform_BIL5020_txt_L6_C10_F16(1).ftp' || '&report=BIL5020_txt.rdf&p_startdate='
		|| TO_CHAR (SYSDATE - 1, 'yyyy-mm-dd') || '&p_endDate=' || TO_CHAR (SYSDATE - 1, 'yyyy-mm-dd'), preport => '�����b�ڲέp�����');
		bil_call_report (pcaseno => 'Daily', phttpstring => 'http://oracleas.vghtc.gov.tw:7780/reports/rwservlet?' || 'userid=billing/billing@hissp1'
		|| '&destype=file' || '&desformat=wide' || '&desname=d:\BatchPrint\CLASS_G\Noform_BIL5020_txt_L6_C10_F16(2).ftp' || '&report=BIL5020_txt.rdf&p_startdate='
		|| TO_CHAR (SYSDATE - 1, 'yyyy-mm-dd') || '&p_endDate=' || TO_CHAR (SYSDATE - 1, 'yyyy-mm-dd'), preport => '�����b�ڲέp�����');
		bil_report_log_test (v_error_info, '�C��');
	END;

  --��ڤ뵲�@�~_�妸_�X�|��϶�
	PROCEDURE p_debt_batch (
		pstartdate   DATE,
		penddate     DATE
	) IS
     --��X�X�|����b���϶�����|��
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			bil_root
		WHERE
			trunc (bil_root.dischg_date) BETWEEN trunc (pstartdate) AND trunc (penddate);
		bilrootrec     bil_root%rowtype;
		v_messageout   VARCHAR2 (100);
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name   := 'biling_daily_pkg.p_debt_batch';
		v_session_id     := userenv ('SESSIONID');
		dbms_output.put_line ('����妸��ڸ��:' || pstartdate || '~' || penddate || '�}�l------------');
		OPEN cur_1;
		LOOP
			FETCH cur_1 INTO bilrootrec;
			EXIT WHEN cur_1%notfound;
			dbms_output.put_line ('��|��:' || bilrootrec.caseno);

           --���歫�� 
			biling_calculate_pkg.main_process (pcaseno => bilrootrec.caseno, poper => 'debt', pmessageout => v_messageout);
			IF v_messageout = '0' THEN --������榨�\        
              --���ͤ�ڰO���e�A������}�߱b��(��ڱb��:���O3 2010/1/11���ᦳ��) 2009/12/25 by Wang,shiou-ya
				biling_process_pkg.newbilingbil (bilrootrec.caseno, '3', ' ', v_messageout);
			END IF;
			IF v_messageout = '0' THEN --�}�߱b����榨�\
               -- p_debt_bycase(Bilrootrec.caseno, v_messageOut);
				cnvrt_owed_to_debt_prc (bilrootrec.caseno, 'p_debt_batch', v_messageout);
			END IF;
		END LOOP;
		CLOSE cur_1;
		COMMIT WORK;
		dbms_output.put_line ('����妸��ڸ��:' || pstartdate || '~' || penddate || '����------------');
		v_error_info     := 'biling_daily_pkg.p_debt_batch';
		bil_report_log_test (v_error_info, '�C��');
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
	END;

--��ڤ뵲�@�~_��|��
	PROCEDURE p_debt_bycase (
		vcaseno     VARCHAR2,
		p_out_msg   OUT VARCHAR2
	) IS
		CURSOR cur_1 IS
		SELECT
			*
		FROM
			bil_root
		WHERE
			caseno = vcaseno;
		CURSOR cur_2 (
			pcaseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_billmst
		WHERE
			bil_billmst.caseno = pcaseno
			AND
			rec_status = 'Y'
		ORDER BY
			bil_billmst.paid_date DESC;
		CURSOR cur_3 (
			pcaseno VARCHAR2
		) IS
		SELECT
			*
		FROM
			bil_billmst
		WHERE
			bil_billmst.caseno = pcaseno
			AND
			rec_status = 'N'
		ORDER BY
			bil_billmst.last_update_date DESC;
		v_pat_paid_amt       NUMBER (10, 0);
		v_up_pat_paid_amt    NUMBER (10, 0);
		bilrootrec           bil_root%rowtype;
		bilfeemstrec         bil_feemst%rowtype;
		bilbillmstrec        bil_billmst%rowtype;
		bildebtrec           bil_debt_rec%rowtype;
		v_check_no           VARCHAR2 (10);
		v_change_flag        VARCHAR2 (1);
		v_overdue_date       DATE;
		v_baddebt_date       DATE;
		v_baddebt_document   VARCHAR2 (30);
		v_debt_accyymm       VARCHAR2 (7);
		v_debt_amt           NUMBER (10, 0);
	BEGIN
       --�]�w�{���W�٤�session_id
		v_program_name   := 'biling_daily_pkg.p_debt_bycase';
		v_session_id     := userenv ('SESSIONID');
		OPEN cur_1;
		LOOP
			FETCH cur_1 INTO bilrootrec;
			EXIT WHEN cur_1%notfound;
			v_check_no   := '';
            --2009/03/06 09:40 BY ChengHangLin
            --�bBIL_DEBT_REC���O���Q�R���ɡA�|���ƥ��@����BIL_DEBT_REC_LOG
            --INSERT INTO BIL_DEBT_REC_LOG(CASENO,HPATNUM,DISCHG_DATE,TOTAL_SELF_AMT,TOTAL_PAID_AMT,TOTAL_DISC_AMT,DEBT_AMT,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,CHECK_NO,CHANGE_FLAG)(SELECT * FROM BIL_DEBT_REC  WHERE CASENO=bilRootRec.caseno);

            --keep old change_flag
			BEGIN
				SELECT
					change_flag,
					overdue_date,
					baddebt_date,
					baddebt_document,
					debt_accyymm
				INTO
					v_change_flag,
					v_overdue_date,
					v_baddebt_date,
					v_baddebt_document,
					v_debt_accyymm
				FROM
					bil_debt_rec
				WHERE
					caseno = bilrootrec.caseno;
			EXCEPTION
				WHEN OTHERS THEN
					v_change_flag := '*';
			END;
			DELETE FROM bil_debt_rec
			WHERE
				caseno = bilrootrec.caseno;
			SELECT
				SUM (bil_billmst.pat_paid_amt)
			INTO v_pat_paid_amt
			FROM
				bil_billmst
			WHERE
				bil_billmst.caseno = bilrootrec.caseno
				AND
				rec_status = 'Y';
			IF v_pat_paid_amt IS NULL THEN
				v_pat_paid_amt := '0';
			END IF;
			BEGIN
				SELECT
					*
				INTO bilfeemstrec
				FROM
					bil_feemst
				WHERE
					caseno = bilrootrec.caseno;
			EXCEPTION
				WHEN OTHERS THEN
					OPEN cur_2 (bilrootrec.caseno);
					FETCH cur_2 INTO bilbillmstrec;
					CLOSE cur_2;
					IF bilbillmstrec.caseno IS NULL THEN
						OPEN cur_3 (bilrootrec.caseno);
						FETCH cur_3 INTO bilbillmstrec;
						CLOSE cur_3;
					END IF;
					IF bilbillmstrec.tot_self_amt IS NULL THEN
						bilbillmstrec.tot_self_amt := '0';
					END IF;
					IF bilbillmstrec.tot_gl_amt IS NULL THEN
						bilbillmstrec.tot_gl_amt := '0';
					END IF;
					bilfeemstrec.tot_self_amt   := bilbillmstrec.tot_self_amt;
					bilfeemstrec.tot_gl_amt     := bilbillmstrec.tot_gl_amt;
			END;
			BEGIN
				SELECT
					MAX (bil_check_bill.check_no)
				INTO v_check_no
				FROM
					bil_check_bill
				WHERE
					bil_check_bill.caseno = bilrootrec.caseno
					AND
					bil_check_bill.status = 'N';
			EXCEPTION
				WHEN OTHERS THEN
					v_check_no := '';
			END;
			v_debt_amt   := nvl (bilfeemstrec.tot_self_amt, 0) + nvl (bilfeemstrec.tot_gl_amt, 0) - nvl (v_pat_paid_amt, 0);
--    IF nvl(v_pat_paid_amt,0) <> 0 THEN  -- �wú�L��

        --IF nvl(bilFeemstRec.Tot_Self_Amt,0) + nvl(bilFeemstRec.Tot_Gl_Amt,0) - nvl(v_pat_paid_amt,0) > 310 THEN
			IF (v_debt_amt < -310 OR v_debt_amt > 310 OR (v_debt_amt <> 0 AND bilrootrec.dischg_date > TO_DATE ('20121026', 'yyyymmdd'))) THEN
				bildebtrec.caseno             := bilrootrec.caseno;
				bildebtrec.hpatnum            := bilrootrec.hpatnum;
				bildebtrec.dischg_date        := bilrootrec.dischg_date;
				bildebtrec.total_self_amt     := nvl (bilfeemstrec.tot_self_amt, 0) + nvl (bilfeemstrec.tot_gl_amt, 0);
				bildebtrec.total_paid_amt     := nvl (v_pat_paid_amt, 0);
				bildebtrec.total_disc_amt     := 0;
				bildebtrec.debt_amt           := nvl (bilfeemstrec.tot_self_amt, 0) + nvl (bilfeemstrec.tot_gl_amt, 0) - nvl (v_pat_paid_amt, 0);
				bildebtrec.creation_date      := SYSDATE;
				bildebtrec.created_by         := 'billing';
				bildebtrec.last_update_date   := SYSDATE;
				bildebtrec.last_updated_by    := 'billing';
				bildebtrec.check_no           := v_check_no;
				IF v_change_flag IN (
					'I',
					'B',
					'L',
					'O'
				) THEN --keep old change_flag
					bildebtrec.change_flag := v_change_flag;
				ELSE
					bildebtrec.change_flag := 'N';
				END IF;
				bildebtrec.overdue_date       := v_overdue_date;
				bildebtrec.baddebt_date       := v_baddebt_date;
				bildebtrec.baddebt_document   := v_baddebt_document;
				bildebtrec.debt_accyymm       := v_debt_accyymm;
				INSERT INTO bil_debt_rec VALUES bildebtrec;
              --�ƥ��@����BIL_DEBT_REC_LOG --BY amber 20110316
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
				) VALUES (
					bildebtrec.caseno,
					bildebtrec.hpatnum,
					bildebtrec.dischg_date,
					bildebtrec.total_self_amt,
					bildebtrec.total_paid_amt,
					bildebtrec.total_disc_amt,
					bildebtrec.debt_amt,
					bildebtrec.creation_date,
					bildebtrec.created_by,
					bildebtrec.last_update_date,
					bildebtrec.last_updated_by,
					bildebtrec.check_no,
					bildebtrec.change_flag,
					SYSDATE
				);
				dbms_output.put_line ('��|��:' || bilrootrec.caseno || '���ͤ�ڸ��');
			END IF;

--            ELSE  -- ����ú�L��

/*            IF nvl(bilFeemstRec.Tot_Self_Amt,0) + nvl(bilFeemstRec.Tot_Gl_Amt,0) - nvl(v_pat_paid_amt,0) > 0 THEN
               bilDebtRec.Caseno           := bilRootRec.Caseno;
               bilDebtRec.Hpatnum          := bilRootRec.Hpatnum;
               bilDebtRec.Dischg_Date      := bilRootRec.Dischg_Date;
               bilDebtRec.Total_Self_Amt   := nvl(bilFeemstRec.Tot_Self_Amt,0) + nvl(bilFeemstRec.Tot_Gl_Amt,0);
               bilDebtRec.Total_Paid_Amt   := nvl(v_pat_paid_amt,0);
               bilDebtRec.Total_Disc_Amt   := 0;
               bilDebtRec.Debt_Amt         := nvl(bilFeemstRec.Tot_Self_Amt,0) + nvl(bilFeemstRec.Tot_Gl_Amt,0) - nvl(v_pat_paid_amt,0);
               bilDebtRec.Creation_Date    := SYSDATE;
               bilDebtRec.Created_By       := 'billing';
               bilDebtRec.Last_Update_Date := SYSDATE;
               bilDebtRec.Last_Updated_By  := 'billing';
               bilDebtRec.Check_No         := v_check_no;

               IF v_change_flag IN ('I','B','L','O') THEN --keep old change_flag
                   bilDebtRec.Change_Flag      := v_change_flag;
               ELSE
                   bilDebtRec.Change_Flag      := 'N';
               END IF;

               bilDebtRec.Overdue_Date      := v_overdue_date;
               bilDebtRec.Baddebt_Date      := v_baddebt_date;
               bilDebtRec.Baddebt_Document  := v_baddebt_document;
               bilDebtRec.Debt_Accyymm      := v_debt_accyymm;

              INSERT INTO bil_debt_rec VALUES bilDebtRec;
              --�ƥ��@����BIL_DEBT_REC_LOG --BY amber 20110316
              INSERT INTO bil_debt_rec_log 
               (CASENO, HPATNUM, DISCHG_DATE, TOTAL_SELF_AMT, TOTAL_PAID_AMT, 
                TOTAL_DISC_AMT, DEBT_AMT, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, 
                LAST_UPDATED_BY, CHECK_NO, CHANGE_FLAG, BACKUP_DATE)                
              VALUES  
              (bilDebtRec.Caseno,
              bilDebtRec.Hpatnum,
              bilDebtRec.Dischg_Date,
              bilDebtRec.Total_Self_Amt,
              bilDebtRec.Total_Paid_Amt,
              bilDebtRec.Total_Disc_Amt,
              bilDebtRec.Debt_Amt,
              bilDebtRec.Creation_Date,
              bilDebtRec.Created_By,
              bilDebtRec.Last_Update_Date,
              bilDebtRec.Last_Updated_By,
              bilDebtRec.Check_No,
              bilDebtRec.Change_Flag,
              sysdate);

               dbms_output.put_line('��|��:'||bilRootRec.caseno||'���ͤ�ڸ��');

            END IF ;*/
--           END IF;
			SELECT
				SUM (bil_billmst.pat_paid_amt)
			INTO v_up_pat_paid_amt
			FROM
				bil_billmst
			WHERE
				bil_billmst.caseno = bilrootrec.caseno
				AND
				rec_status = 'Y';
			UPDATE bil_debt_rec
			SET
				total_paid_amt = v_up_pat_paid_amt
			WHERE
				caseno = bilrootrec.caseno;
		END LOOP;
		CLOSE cur_1;
		p_out_msg        := '0';
		COMMIT WORK;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			p_out_msg      := '1';
	END;
	PROCEDURE p_diet_inadm (
		i_hcaseno     VARCHAR2,
		i_bill_date   DATE
	) IS
		r_pat_adm_case               common.pat_adm_case%rowtype;
		r_bil_root                   bil_root%rowtype;
		r_biling_spl_errlog          biling_spl_errlog%rowtype;
		r_consult_diet_charge_info   cpoe.consult_diet_charge_info%rowtype;
		TYPE t_diets IS
			VARRAY (4) OF cpoe.consult_diet_charge_info.charge_id%TYPE;
		l_diets                      t_diets;
		l_diets_ordseq               cpoe.consult_diet_charge_info.ordseq%TYPE;
		l_fst4_chars                 VARCHAR2 (4);
		l_5th_char                   VARCHAR2 (1);
		l_6th_char                   VARCHAR2 (1);
		l_msg                        VARCHAR2 (32767);
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

		-- �������p������
		l_diets := t_diets (NULL, 'DITCAN00', 'DITCAN00', 'DITCAN00');
		FOR r_consult_diet_charge_info IN (
			SELECT
				*
			FROM
				cpoe.consult_diet_charge_info
			WHERE
				caseno = r_pat_adm_case.hcaseno
				AND
				bill_date = trunc (i_bill_date)
				AND
				trans_yn = 'N'
			ORDER BY
				bill_date,
				charge_id
		) LOOP
			l_fst4_chars                           := substr (r_consult_diet_charge_info.charge_id, 1, 4);
			l_5th_char                             := substr (r_consult_diet_charge_info.charge_id, 5, 1);
			l_6th_char                             := substr (r_consult_diet_charge_info.charge_id, 6, 1);
			IF 
			-- ���q�\�B�����\
			 l_fst4_chars IN (
				'DITP',
				'DITI'
			) AND l_5th_char IN (
				'A',
				'B',
				'C',
				'D'
			) AND l_6th_char BETWEEN '0' AND '9' 
			-- �]�`�|�^�鶡�믫�f�ЯS����\
			 OR r_consult_diet_charge_info.charge_id = 'DITPE001' THEN
        		-- ���\�O
				IF l_5th_char = 'A' THEN
					l_diets (1)      := r_consult_diet_charge_info.charge_id;
					l_diets_ordseq   := r_consult_diet_charge_info.ordseq;
        		-- ���\�O
				ELSIF l_5th_char = 'B' THEN
					l_diets (2) := r_consult_diet_charge_info.charge_id;
        		-- ���\�O
				ELSIF l_5th_char = 'C' THEN
					l_diets (3) := r_consult_diet_charge_info.charge_id;
        		-- ���\�O
				ELSIF l_5th_char = 'D' THEN
					l_diets (4) := r_consult_diet_charge_info.charge_id;
        		-- �]�`�|�^�鶡�믫�f�ЯS����\
				ELSIF r_consult_diet_charge_info.charge_id = 'DITPE001' THEN
					l_diets (4) := r_consult_diet_charge_info.charge_id;
				END IF;
			ELSE
				-- �D�i��|��|��|�ߡj�\�O�A�����J�b
				FOR r_dbpfile IN (
					SELECT
						*
					FROM
						cpoe.dbpfile
					WHERE
						pfkey = r_consult_diet_charge_info.charge_id
				) LOOP
					order_bill ('A', -- �N�E�O (A/E) 
					 r_consult_diet_charge_info.caseno, -- �N�E��
					 r_consult_diet_charge_info.bill_date, -- �p����
					 r_consult_diet_charge_info.ordseq, -- ����Ǹ�
						CASE
							WHEN SYSDATE > r_bil_root.dischg_date THEN
								'Y'
							ELSE 'N'
						END, -- ���|�ɱb���O
						 r_consult_diet_charge_info.charge_id, -- �p���X 
						 r_consult_diet_charge_info.db_cd, -- ���t�� (+/-)
						 '02', -- �O�����O 
						 lpad (TO_CHAR (r_consult_diet_charge_info.qty), 4, '0'), -- �ƶq
						 r_dbpfile.pfprice1 * r_consult_diet_charge_info.qty, -- �`��
						 '', -- ��@���D��@���O (E/R)
						 '', -- �۶O���u�ӳ����p�����O (PR/DR)
						 '', -- IV PUMP (Y/N)
						 'DIET', -- �j��J�k�ݬ�
						 '', -- �h�b�z�ѡ]�����T�\�^
						 r_pat_adm_case.hnursta, -- ���Ӧa�I
						 'DIET', -- �J�b�̥d��
						 '', -- OR. ORDER CATALOG (1/2/3/4/5)
						 '', -- �O�_�]�ֵo�g�Ҳ��ͪ��b (Y/N)
						 '', -- ��N�ĴX�M
						 '', -- DISCHARGE BRING BACK (Y/NULL)
						 '', -- �զX�����O (Y/N)
						 '', -- ��b���
						 r_pat_adm_case.hcursvcl, -- �p����O
						 r_pat_adm_case.hnursta, -- �f��
						 '', -- �}�߬�O
						 l_msg, -- RETURN MESSAGE
						 'N' -- �۰� commit (Y/N)
						);

					-- �u���@��
					EXIT;
				END LOOP;
			END IF;

			-- ��s�L�b���O�M�ɶ�
			r_consult_diet_charge_info.trans_yn    := 'Y';
			r_consult_diet_charge_info.trans_dtm   := SYSDATE;
			UPDATE cpoe.consult_diet_charge_info
			SET
				row = r_consult_diet_charge_info
			WHERE
				bill_date = r_consult_diet_charge_info.bill_date
				AND
				ordseq = r_consult_diet_charge_info.ordseq
				AND
				charge_id = r_consult_diet_charge_info.charge_id
				AND
				freq = r_consult_diet_charge_info.freq
				AND
				db_cd = r_consult_diet_charge_info.db_cd;
		END LOOP;

		-- �J�T�\
		IF l_diets (1) IS NOT NULL THEN
			order_bill ('A', -- �N�E�O (A/E) 
			 r_pat_adm_case.hcaseno,  -- �N�E��
			 i_bill_date, -- �p���� 
			 l_diets_ordseq, -- ����Ǹ�
				CASE
					WHEN SYSDATE > r_bil_root.dischg_date THEN
						'Y'
					ELSE 'N'
				END, -- ���|�ɱb���O
				 l_diets (1), -- �p���X
				 '+', -- ���t�� (+/-) 
				 '', -- �O�����O
				 '0000', -- �ƶq
				 0, -- �`���B
				 '', -- ��@���D��@���O (E/R)
				 '', -- �۶O���u�ӳ����p�����O (PR/DR)
				 '', -- IV PUMP (Y/N)
				 '', -- �j��J�k�ݬ�
				 l_diets (2) || l_diets (3) || l_diets (4), -- �h�b�z�ѡ]�����T�\�^
				 '', -- ���Ӧa�I
				 'DDAILY', -- �J�b�̥d��
				 '', -- OR. ORDER CATALOG (1/2/3/4/5)
				 '', -- �O�_�]�ֵo�g�Ҳ��ͪ��b (Y/N)
				 '', -- ��N�ĴX�M
				 '', -- DISCHARGE BRING BACK (Y/NULL)
				 '', -- �զX�����O (Y/N)
				 '', -- ��b���
				 '', -- �p����O
				 '', -- �f��
				 '', -- �}�߬�O
				 l_msg, -- RETURN MESSAGE
				 'N' -- �۰� commit (Y/N)
				);
		END IF;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			r_biling_spl_errlog.session_id   := userenv ('SESSIONID');
			r_biling_spl_errlog.prog_name    := $$plsql_unit || '.' || 'p_diet_inadm';
			r_biling_spl_errlog.sys_date     := SYSDATE;
			r_biling_spl_errlog.err_code     := sqlcode;
			r_biling_spl_errlog.err_msg      := sqlerrm;
			r_biling_spl_errlog.err_info     := dbms_utility.format_error_backtrace || dbms_utility.format_error_stack;
			r_biling_spl_errlog.source_seq   := i_hcaseno;
			INSERT INTO biling_spl_errlog VALUES r_biling_spl_errlog;
			COMMIT;
	END;

  --�s,�����JBILLTEMP1 BY KUO 1001215,���ޤѼƥ����J�b
	PROCEDURE p_diet_inadm_bycase (
		pcaseno VARCHAR2
	) IS
		CURSOR get_consult_diet_charge_info IS
		SELECT DISTINCT
			bill_date
		FROM
			cpoe.consult_diet_charge_info
		WHERE
			caseno = pcaseno
			AND
			trans_yn = 'N'
		ORDER BY
			bill_date;
		vbildate DATE;
	BEGIN
		OPEN get_consult_diet_charge_info;
		LOOP
			FETCH get_consult_diet_charge_info INTO vbildate;
			EXIT WHEN get_consult_diet_charge_info%notfound;
			IF vbildate >= TO_DATE ('20120701', 'YYYYMMDD') THEN
				p_diet_inadm (pcaseno, vbildate);
			END IF;
		END LOOP;
		CLOSE get_consult_diet_charge_info;
	EXCEPTION
		WHEN OTHERS THEN
			v_error_code   := sqlcode;
			v_error_info   := sqlerrm;
			dbms_output.put_line ('P_DIET_INADM_BY_CASE ERROR:' || v_error_code || ',' || v_error_info || ',' || pcaseno);
	END p_diet_inadm_bycase;
END;

/
