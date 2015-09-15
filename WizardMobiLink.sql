/*************
OBJET : generation de la table et des PS de la synchro MBL a partir d'une db de ref
DATE : 150210
AUTEUR : PEH (SAP) - PL

HISTORIQUE :	version 1.01 - correction pour bug de script sur construction ordre update de SAP_UPDATE_SAP_TBL 
		version 1.02 - introduction tables reflangue, translat_result (proxy) et syslangtraduction (proxy) 
		version 1.03 - modification regle download pour cluelevageresultat (clause sur annee)
		150504 - PL - ajout tables anajrnlmensueldept & messags + modif clause where sur loc_syslangtraduction 
		150505 - PL - ajout table pour efficiency

--trucs
	si besoin clause sur chaîne de caractères dans script insert ci-dessous =>  AND LOC_SysLangTraduction.Ind_Traduction = ''''P''''

**************/

IF EXISTS (
	SELECT 1
	FROM SYS.SYSTABLE
	INNER JOIN SYS.SYSUSER ON user_id = creator
	WHERE table_name = 'SAP_TBL'
	AND user_name = user_name()
) THEN
	DROP TABLE "DBA"."SAP_TBL"
END IF
GO

create table "SAP_TBL" ( 
tname             varchar(128) 
,upl_ins char(1) default 'N'
,upl_upd char(1) default 'N'
,upl_del char(1) default 'N'
,dwl char(1)     default 'N'
,dwl_meta_filtre_synchro char(1) default 'N' -- 'N' synchro par défaut ; 'Y' tenir compte de ind_synchro, tout_envoyer, tout_supprimer_en_remote dans MBL_UserElevage
,dwl_del char(1) default 'N'
,dwl_from         varchar(1000) default '' -- commence par ,
,dwl_where        varchar(1000) default '' -- commence par AND
,dwl_del_from     varchar(1000) default '' -- commence par ,
,dwl_del_where    varchar(1000) default ''  -- commence par AND
,pk_list          varchar(4000) -- Colonne ci dessous alimenter via la proc SAP_UPDATE_SAP_TBL
,pk_list_type     varchar(4000)
,pk_join_inserted varchar(4000)
,col_list         varchar(4000)
,pk_join_ml       varchar(4000)
,col_list_ml      varchar(4000)
,col_upd_ml       varchar(4000)
--,pk_list_prefix_table     varchar(4000)
,col_list_prefix_table     varchar(4000)
,col_list_prefix_table_del varchar(4000)
,pk_existe  char(1) default 'Y'
)
go

insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('AnaJrnlMensuelDept' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage , SystPreference' , 'AND AnaJrnlMensuelDept.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND AnaJrnlMensuelDept.mois_creation_importation > SystPreference.anneemois_last_import-300 ' , ' , MBL_UserElevage ' , 'AND AnaJrnlMensuelDept_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('AnaJrnlMensuelDQS' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage , SystPreference' , 'AND AnaJrnlMensuelDQS.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND AnaJrnlMensuelDQS.mois_creation_importation > SystPreference.anneemois_last_import-300 ' , ' , MBL_UserElevage ' , 'AND AnaJrnlMensuelDQS_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('AppCritereReference' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('CluElevageResultat' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND CluElevageResultat.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND CluElevageResultat.annee = (select max(annee) from CluElevageResultat) ' , ' , MBL_UserElevage ' , 'AND CluElevageResultat_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username}' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('EffElevageResultat' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND EffElevageResultat.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND EffElevageResultat.annee = (select max(annee) from EffElevageResultat) ' , ' , MBL_UserElevage ' , 'AND EffElevageResultat_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username}' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('IntervJrnlCaractStruct' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage , SystPreference' , 'AND IntervJrnlCaractStruct.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND IntervJrnlCaractStruct.mois_creation_importation > SystPreference.anneemois_last_import-300' , ' , MBL_UserElevage ' , 'AND IntervJrnlCaractStruct_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('IntervJrnlInterv' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND IntervJrnlInterv.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND IntervJrnlInterv.date_intervention >= dateadd(day , -365*2 , now(*))' , ' , MBL_UserElevage ' , 'AND IntervJrnlInterv_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('IntervResultatCategQuest' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND IntervResultatCategQuest.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND IntervResultatCategQuest.date_intervention >= dateadd(day , -365*2 , now(*))' , ' , MBL_UserElevage ' , 'AND IntervResultatCategQuest_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('IntervResultatCritereDescr' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND IntervResultatCritereDescr.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND IntervResultatCritereDescr.date_intervention >= dateadd(day , -365*2 , now(*))' , ' , MBL_UserElevage ' , 'AND IntervResultatCritereDescr_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('IntervResultatCritereEvalDept' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND IntervResultatCritereEvaldept.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND IntervResultatCritereEvalDept.date_intervention >= dateadd(day , -365*2 , now(*))' , ' , MBL_UserElevage ' , 'AND IntervResultatCritereEvalDept_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('IntervResultatCritereEvalEurop' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND IntervResultatCritereEvalEurop.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND IntervResultatCritereEvalEurop.date_intervention >= dateadd(day , -365*2 , now(*))' , ' , MBL_UserElevage ' , 'AND IntervResultatCritereEvalEurop_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('IntervResultatCritereEvalSocial' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND IntervResultatCritereEvalSocial.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND IntervResultatCritereEvalSocial.date_intervention >= dateadd(day , -365*2 , now(*))' , ' , MBL_UserElevage ' , 'AND IntervResultatCritereEvalSocial_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('IntervResultatCritereQuest' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND IntervResultatCritereQuest.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND IntervResultatCritereQuest.date_intervention >= dateadd(day , -365*2 , now(*))' , ' , MBL_UserElevage ' , 'AND IntervResultatCritereQuest_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('IntervResultatExigenceQuest' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND IntervResultatExigenceQuest.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} AND IntervResultatExigenceQuest.date_intervention >= dateadd(day , -365*2 , now(*))' , ' , MBL_UserElevage ' , 'AND IntervResultatExigenceQuest_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('LangMessage' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('LOC_SysLangTraduction' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '  , RefDepartement' , 'AND (LOC_SysLangTraduction.cod_langue=RefDepartement.cod_langue OR LOC_SysLangTraduction.cod_langue=RefDepartement.cod_langue_eleveur)' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('LOC_Translat_Result' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '  , RefDepartement' , 'AND LOC_Translat_Result.code_langue=RefDepartement.cod_langue AND LOC_Translat_Result.Object_Type = CommandButton' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('MBL_UserElevage' ,'N' , 'Y' , 'N' , 'Y' , 'Y' , 'N' , '' , 'AND MBL_UserElevage.cod_mobilink={ml s.username} ' , '' , 'AND MBL_UserElevage_del.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('Messages' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('QUEElevageResultat' ,'Y' , 'Y' , 'Y' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND QUEElevageResultat.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username}' , ' , MBL_UserElevage ' , 'AND QUEElevageResultat_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username} ' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefCaracteristiqueStructurelle' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefCategorieQuest' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefCritereDescription' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefCritereEfficiency' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefCritereEvaluationDept' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefCritereEvaluationEuropeen' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefCritereEvaluationSocial' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefCritereQuest' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('refDepartement' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefDomaineCritere' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefDonneeMensuelleDepartement' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('refElevage' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , ' , MBL_UserElevage' , 'AND refElevage.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username}' , ' , MBL_UserElevage ' , 'AND refElevage_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username}' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefExigenceQuest' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefFamilleCritere' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('refhistocodeelevage' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'Y' , ' , MBL_UserElevage' , 'AND refhistocodeelevage.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username}' , ' , MBL_UserElevage ' , 'AND refhistocodeelevage_del.cod_elevage=MBL_UserElevage.cod_elevage AND MBL_UserElevage.cod_mobilink={ml s.username}' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefLangue' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefQuestionnaire' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('REFREFERENTIELEXTERNE' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('REFREFEXTCRITEREEVAL' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefSousTypeIntervention' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('refTechnicien' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefThemeintervention' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefTypeCaracteristique' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefTypeCritereDescription' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefTypeCritereEvaluation' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefTypeCritereQuest' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefTypeIntervention' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefValeurCaracteristique' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefValeurCritereDescription' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefValeurCritereEvaluation' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefValeurCritereQuest' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('RefZoneCollecte' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('SecUtilisateur' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , ' ' , 'AND SecUtilisateur.cod_Mobilink={ml s.username}' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('SystPreference' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('SystTraduction' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('w_gph_pad' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('w_gph_pad_testphy' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('w_interv_user' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('w_tab_pad_hn_testphy' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
insert SAP_TBL (tname,upl_ins,upl_upd,upl_del,dwl,dwl_del,dwl_meta_filtre_synchro,dwl_from,dwl_where,dwl_del_from,dwl_del_where) values ('w_tab_pad_testphy' ,'N' , 'N' , 'N' , 'Y' , 'Y' , 'N' , '' , '' , '' , '' )
go
commit;

update SAP_TBL set pk_existe='N' 
from   ( 
select SAP.tname 'tname'
from SAP_TBL SAP
where not exists ( 
select 1 from SYS.SYSCOLUMNS COL 
where SAP.tname = COL.tname
and COL.cname!='last_modified'
and in_primary_key='Y') ) TABLE_SANS_PK
where SAP_TBL.tname = TABLE_SANS_PK.tname ;

delete from SAP_TBL from  ( 
select SAP.tname 'tname'
from SAP_TBL SAP
where not exists ( 
select 1 from SYS.SYSCOLUMNS COL 
where SAP.tname = COL.tname
and COL.cname!='last_modified'
and in_primary_key='Y') ) TABLE_SANS_PK
where SAP_TBL.tname = TABLE_SANS_PK.tname ;


commit;


CREATE OR REPLACE PROCEDURE SAP_UPDATE_SAP_TBL ( @TBL varchar(128) default '%', @DEBUG varchar(50) default null )
BEGIN

  DECLARE cur_table_col_pk INSENSITIVE CURSOR FOR
    select SAP.tname, COL.cname , COL.coltype , COL.length  , COL.in_primary_key
    from SAP_TBL SAP join SYS.SYSCOLUMNS COL on SAP.tname = COL.tname
    where COL.cname!='last_modified'
    and  SAP.tname like @TBL and pk_existe='Y'
    order by SAP.tname , COL.colno ;   -- ORDRE TRES IMPORTANT !!!

  DECLARE @tname_old varchar(128);
  DECLARE @tname_new varchar(128);
  DECLARE @cname varchar(128);
  DECLARE @coltype varchar(128);
  DECLARE @collength int;
  DECLARE @in_primary_key char(1);

  DECLARE @coma char(1);
  DECLARE @clause_AND char(3);
  DECLARE @pk_coma char(1);
  DECLARE @nopk_coma char(1);
  DECLARE @pk_clause_AND char(3);  
  DECLARE @SQLCODE_CURSOR int ;

  DECLARE @pk_list varchar(4000);
  DECLARE @pk_list_type varchar(4000);
  DECLARE @pk_join_inserted varchar(4000);
  DECLARE @col_list varchar(4000);
  DECLARE @pk_join_ml varchar(4000);
  DECLARE @col_list_ml varchar(4000);
  DECLARE @col_upd_ml varchar(4000);
  DECLARE @pk_list_prefix_table varchar(4000);
  DECLARE @col_list_prefix_table varchar(4000);
  DECLARE @col_list_prefix_table_del varchar(4000);

  -- Controle que les tables ont toutes un PK
  if exists ( select 1
    from SAP_TBL SAP 
    where not exists ( 
      select 1 from SYS.SYSCOLUMNS COL 
      where SAP.tname = COL.tname
      and COL.cname!='last_modified'
      and in_primary_key='Y')
    and  SAP.tname like @TBL )
  then
    print 'ERROR : Table sans PK' ;
    select SAP.tname 'TABLE_SANS_PK'
    from SAP_TBL SAP
    where not exists ( 
      select 1 from SYS.SYSCOLUMNS COL 
      where SAP.tname = COL.tname
      and COL.cname!='last_modified'
      and in_primary_key='Y')
    and  SAP.tname like @TBL ;
    -- ByPass .... return ;
  end if;  

 
  SET @tname_old='xxx';

  OPEN cur_table_col_pk;

  FETCH NEXT cur_table_col_pk INTO @tname_new , @cname , @coltype , @collength, @in_primary_key ;
  set @SQLCODE_CURSOR=SQLCODE;
  if @DEBUG is null then 
    message 'Fetch : @SQLCODE_CURSOR='||@SQLCODE_CURSOR to client;
  end if;
  
  while @SQLCODE_CURSOR=0 LOOP
    
    if @DEBUG is null then
      message '--- nouvelle boucle' to client ;
      message 'OLD table='||@tname_old||' - NEW table='||@tname_new||' - Col='||@cname to client ;
    end if;
    
    IF @tname_old != @tname_new THEN
      -- Nouvelle Table 
        IF  @tname_old!='xxx' THEN 
            update SAP_TBL
            set pk_list=@pk_list , pk_list_type=@pk_list_type, pk_join_inserted=@pk_join_inserted, col_list=@col_list
                ,pk_join_ml=@pk_join_ml,col_list_ml=@col_list_ml,col_upd_ml=@col_upd_ml
                ,col_list_prefix_table_del=@col_list_prefix_table_del,col_list_prefix_table=@col_list_prefix_table
                -- ,pk_list_prefix_table=@pk_list_prefix_table
            where tname=@tname_old;
            if @DEBUG is null then 
              message '--- Upd : rowcount = '||cast(@@rowcount as varchar(10)) to client ;
              message '--- Upd : @tname_old = '||@tname_old to client ;
              message '--- Upd : @pk_list = '||@pk_list to client ;
              message '--- Upd : @pk_list_type = '||@pk_list_type to client ;
              message '--- Upd : @col_list = '||@col_list to client ; 
             end if ;           
        END IF;
        SET @tname_old=@tname_new;
        SET @pk_list='';
        SET @pk_list_type='';
        SET @pk_join_inserted='';
        SET @col_list='';
        SET @pk_join_ml='';
        SET @col_list_ml='';
        SET @col_upd_ml=''; 
        -- SET @pk_list_prefix_table='';
        SET @col_list_prefix_table='';
        SET @col_list_prefix_table_del='';
        SET @coma='';
        SET @clause_AND='';
        SET @pk_coma='';
        SET @nopk_coma='';
        SET @pk_clause_AND='';
    END IF;

    -- Gestion des PK
    IF @in_primary_key='Y' THEN
      IF @coltype='varchar' OR @coltype='char' THEN 
        SET @pk_list_type=@pk_list_type||' '||@pk_coma||' '||@cname||' '||@coltype||'('||cast(@collength as varchar(10))||') not null' ;
      ELSE
        SET @pk_list_type= @pk_list_type||' '||@pk_coma||' '||@cname||' '||@coltype||'  not null'   ;
      END IF;
      SET @pk_list=@pk_list||' '||@pk_coma||' '||@cname ;
      SET @pk_join_inserted=@pk_join_inserted||' '||@pk_clause_AND||' '||@tname_old||'_del.'||@cname||'=inserted.'||@cname ;
      SET @pk_join_ml=@pk_join_ml||' '||@pk_clause_AND||' '||@tname_old||'.'||@cname||'={ml r.'||@cname||'}';
      -- HPE : modif char(10)
      SET @col_list_prefix_table_del=@col_list_prefix_table_del||char(10)||@pk_coma||' '||@tname_new||'_del.'||@cname;
      SET @pk_coma=',';
      SET @pk_clause_AND='AND';
    ELSE
    -- Gestion des Non PK
      SET @col_upd_ml=@col_upd_ml||'
'||@nopk_coma||' '||@cname||'={ml r.'||@cname||'}'; --PL 1.01 150210 @pk_coma => @nopak_coma
      SET @nopk_coma=',';        
    END IF ;
    
    -- Toutes les colonnes
    SET @col_list=@col_list||'
'||@coma||' '||@cname;
    SET @col_list_ml=@col_list_ml||'
'||@coma||' {ml r.'||@cname||'}';    
    SET @col_list_prefix_table=@col_list_prefix_table||'
'||@coma||' '||@tname_new||'.'||@cname;

    SET @coma=',' ;
    SET @clause_AND='AND';
    
    FETCH NEXT cur_table_col_pk INTO @tname_new , @cname , @coltype , @collength, @in_primary_key ;
    set @SQLCODE_CURSOR=SQLCODE;
    if @DEBUG is null then
      message 'Fetch : @SQLCODE_CURSOR='||@SQLCODE_CURSOR to client;
    end if;

  END LOOP ;

  update SAP_TBL
  set pk_list=@pk_list , pk_list_type=@pk_list_type, pk_join_inserted=@pk_join_inserted, col_list=@col_list
     ,pk_join_ml=@pk_join_ml,col_list_ml=@col_list_ml,col_upd_ml=@col_upd_ml
     ,col_list_prefix_table_del=@col_list_prefix_table_del,col_list_prefix_table=@col_list_prefix_table
  where tname=@tname_old;
  if @DEBUG is null then 
    message '--- LastUpd : rowcount = '||cast(@@rowcount as varchar(10)) to client ;
    message '--- LastUpd : @tname_old = '||@tname_old to client ;
    message '--- LastUpd : @pk_list = '||@pk_list to client ;
    message '--- LastUpd : @pk_list_type = '||@pk_list_type to client ;
    message '--- LastUpd : @col_list = '||@col_list to client ;
  end if;
  CLOSE cur_table_col_pk;
  
END;





CREATE OR REPLACE PROCEDURE SAP_GEN_LAST_MODIFIED ( @TBL varchar(128) default '%' )
BEGIN
call SAP_UPDATE_SAP_TBL();
select rtrim(
'
/* Crée la table de suppression fictive ''DBA.'||tname||'_del''. */
IF NOT EXISTS (
	SELECT 1
	FROM SYS.SYSTABLE
	INNER JOIN SYS.SYSUSER ON user_id = creator
	WHERE table_name = '''||tname||'_del''
	AND user_name = ''DBA''
) THEN
	CREATE TABLE DBA.'||tname||'_del (
	'||pk_list_type||'
	,last_modified TIMESTAMP DEFAULT CURRENT TIMESTAMP,
	PRIMARY KEY ('||pk_list||')
)
END IF
GO


/* Crée la colonne timestamp ''last_modified''. */
IF NOT EXISTS (
	SELECT 1
	FROM SYS.SYSCOLUMNS
	WHERE tname = '''||tname||''' AND cname = ''last_modified''
	AND creator = ''DBA''
) THEN
	ALTER TABLE DBA.'||tname||' ADD last_modified TIMESTAMP NOT NULL DEFAULT TIMESTAMP
END IF
GO


/* Crée le trigger de suppression fictif '''||tname||'_ins''. */
IF EXISTS (
	SELECT 1
	FROM SYS.SYSTRIGGERS
	WHERE trigname = '''||tname||'_ins'' AND tname = '''||tname||'''
) THEN
	DROP TRIGGER '||tname||'_ins
END IF
GO
CREATE TRIGGER '||tname||'_ins AFTER INSERT
ORDER 5 ON DBA.'||tname||'
REFERENCING NEW AS inserted FOR EACH STATEMENT
BEGIN
	/*
	* Supprime la ligne de la table de suppression fictive. (Ce trigger est nécessaire
	* uniquement si les clés primaires supprimées peuvent être réinsérées.)
	*/
	DELETE FROM DBA.'||tname||'_del
	WHERE EXISTS (  SELECT 1
                  FROM inserted
                  WHERE '||pk_join_inserted||'	);
END
GO


/* Crée le trigger de suppression fictif '''||tname||'_dlt''. */
IF EXISTS (
	SELECT 1
	FROM SYS.SYSTRIGGERS
	WHERE trigname = '''||tname||'_dlt'' AND tname = '''||tname||'''
) THEN
	DROP TRIGGER "'||tname||'_dlt"
END IF
GO
CREATE TRIGGER "'||tname||'_dlt" AFTER DELETE
ORDER 5 ON DBA.'||tname||'
REFERENCING OLD AS deleted FOR EACH STATEMENT
BEGIN
	/* Insère la ligne dans la table de suppression fictive. */
	INSERT INTO DBA.'||tname||'_del ( '||pk_list||', last_modified )
	SELECT '||pk_list||' , CURRENT TIMESTAMP FROM deleted;
END
GO


/* Crée un index pour le script ''download_cursor''. */
IF NOT EXISTS (
	SELECT iname FROM SYS.SYSINDEXES
	WHERE iname = '''||tname||'_ml'' AND tname = '''||tname||'''
	AND icreator = ''DBA''
) THEN
	CREATE INDEX '||tname||'_ml ON DBA.'||tname||' ( "last_modified" )
END IF
GO


/* Crée un index pour le script ''download_delete_cursor''. */
IF NOT EXISTS (
	SELECT iname FROM SYS.SYSINDEXES
	WHERE iname = '''||tname||'_mld'' AND tname = '''||tname||'_del''
	AND icreator = ''DBA''
) THEN
	CREATE INDEX '||tname||'_mld ON DBA.'||tname||'_del ( "last_modified" )
END IF
GO

COMMIT
GO

' )  CmdSQL
from SAP_TBL 
where tname like @TBL  
END;




CREATE OR REPLACE PROCEDURE SAP_GEN_PUB_ULINIT ( @PUB varchar(128) default 'pub_xxx' )
BEGIN
call SAP_UPDATE_SAP_TBL();
set @PUB='pub_ulinit';

SELECT
rtrim ( 
  case 
    when RowNum=1 then 'CREATE PUBLICATION '||@PUB||' (
'
    else ', '  
  end case 
  ||  DESCRIBE_TBL_COL  || 
  case 
    when RowNum=(select count(*) from SAP_TBL) then '
)'  
    else '' 
  end case 
) CODE_SQL
FROM ( 
  select  ROW_NUMBER() OVER ( ORDER BY tname ) AS RowNum , 'TABLE '||tname||' ( '||col_list||' )' DESCRIBE_TBL_COL
  from SAP_TBL ) TMP 
ORDER BY RowNum   
END;



CREATE OR REPLACE PROCEDURE SAP_GEN_PUB_FARMS ( @PUB varchar(128) default 'pub_xxx' )
BEGIN
call SAP_UPDATE_SAP_TBL();
set @PUB='pub_farms';

SELECT
rtrim ( 
  case 
    when RowNum=1 then 'CREATE PUBLICATION '||@PUB||' (
' 
    else ', '  
  end case 
  ||  DESCRIBE_TBL  || 
  case 
    when RowNum=(select count(*) from SAP_TBL) then '
)' 
    else '' 
  end case 
) CODE_SQL
FROM ( 
  select  ROW_NUMBER() OVER ( ORDER BY tname ) AS RowNum , 'TABLE '||tname DESCRIBE_TBL
  from SAP_TBL ) TMP 
ORDER BY RowNum   
END;
 



CREATE OR REPLACE PROCEDURE SAP_GEN_MBL_SCRIPT ( @TBL varchar(128) default '%' )
BEGIN
call SAP_UPDATE_SAP_TBL();
select rtrim (CmdSQL)
from (

select rtrim(
'
----------------------------------
-- '||tname||'
----------------------------------
CALL ml_add_table_script( ''scriptV1'', '''||tname||''', ''upload_delete'', ''
'|| 
case 
  when upl_del='Y' then 
'DELETE FROM '||tname||'
WHERE '||pk_join_ml||'' 
  else 
'--{ml_ignore}' 
end case||'
'' );
' )  CmdSQL , 1 TRI , tname TBL
from SAP_TBL 
where tname like @TBL  

UNION ALL

select rtrim(
'
CALL ml_add_table_script( ''scriptV1'', '''||tname||''', ''upload_insert'', ''
'||
case 
  when upl_ins='Y' then 
'INSERT INTO '||tname||' ( '||col_list||' )
VALUES ( '||col_list_ml||' )' 
  else 
'--{ml_ignore}' 
end case||'
'' );
' )  CmdSQL , 2 TRI , tname TBL
from SAP_TBL 
where tname like @TBL  

UNION ALL

select rtrim(
'
CALL ml_add_table_script( ''scriptV1'', '''||tname||''', ''upload_update'', ''
'||
case 
  when upl_upd='Y' then 
'UPDATE '||tname||'
SET '||col_upd_ml||'
WHERE '||pk_join_ml||'' 
  else 
'--{ml_ignore}' 
end case||'
'' );
' )  CmdSQL , 3 TRI , tname TBL
from SAP_TBL 
where tname like @TBL  

UNION ALL

select rtrim(
'
CALL ml_add_table_script( ''scriptV1'', '''||tname||''', ''download_cursor'', ''
'||
case 
  when dwl='Y' and dwl_meta_filtre_synchro='N' then 
'SELECT '||col_list_prefix_table||'
FROM '||tname||dwl_from||'
WHERE '||tname||'.last_modified >= {ml s.last_table_download}
'||dwl_where
  when dwl='Y' and dwl_meta_filtre_synchro='Y' then 
'SELECT '||col_list_prefix_table||'
FROM '||tname||dwl_from||'
WHERE ( '||tname||'.last_modified >= {ml s.last_table_download}  or MBL_UserElevage.tout_envoyer=1 )
AND MBL_UserElevage.ind_synchro=1
'||dwl_where
  else 
'--{ml_ignore}' 
end case||'
'' );
' )  CmdSQL , 4 TRI , tname TBL
from SAP_TBL 
where tname like @TBL  

UNION ALL

select rtrim(
'
CALL ml_add_table_script( ''scriptV1'', '''||tname||''', ''download_delete_cursor'', ''
'||
case 
  when dwl_del='Y' and dwl_meta_filtre_synchro='N' then 
'SELECT '||col_list_prefix_table_del||'
FROM '||tname||'_del '||dwl_del_from||'
WHERE '||tname||'_del.last_modified >= {ml s.last_table_download}
'||dwl_del_where
  when dwl_del='Y' and dwl_meta_filtre_synchro='Y' then -- astuce  FROM '||tname||'_del '||dwl_del_from||' pour pouvoir utiliser col_list_prefix_table_del
'SELECT '||col_list_prefix_table_del||'
FROM '||tname||'_del '||dwl_del_from||'
WHERE '||tname||'_del.last_modified >= {ml s.last_table_download}
'||dwl_del_where||'
UNION ALL
SELECT '||col_list_prefix_table_del||'
FROM '||tname||' '||tname||'_del '||' , MBL_UserElevage  
WHERE  '||tname||'_del.cod_elevage=MBL_UserElevage.cod_elevage 
AND MBL_UserElevage.cod_mobilink={ml s.username}
AND MBL_UserElevage.tout_virer = 1' 
  else 
'--{ml_ignore}' 
end case||'
'' );


' )  CmdSQL , 5 TRI , tname TBL
from SAP_TBL 
where tname like @TBL  


UNION ALL

Select rtrim('
----------------------------------
-- Script CONNECTION : end_download
----------------------------------
CALL ml_add_connection_script( ''scriptV1'', ''end_download'', ''update MBL_UserElevage set tout_envoyer=0 , tout_virer=0 where cod_mobilink={ml s.username}'');
') CmdSQL  , 99 'TRI' , 'ZZZZZZZ' TBL


) TBL_DERIVED
order by TBL , TRI
END ;



/*
CALL SAP_UPDATE_SAP_TBL( );commit;  

CALL SAP_GEN_LAST_MODIFIED();
OUTPUT TO 'F:\CLIENT\PHYLUM\DEV\ADD_LAST_MODIFIED.sql' QUOTE '' HEXADECIMAL ASIS ;

call SAP_GEN_PUB_FARMS() ;
OUTPUT TO 'F:\CLIENT\PHYLUM\DEV\pub_farms.sql' QUOTE '' HEXADECIMAL ASIS ;

call SAP_GEN_PUB_ULINIT();
OUTPUT TO 'F:\CLIENT\PHYLUM\DEV\pub_ulinit.sql' QUOTE '' HEXADECIMAL ASIS ;

OUTPUT TO 'F:\CLIENT\PHYLUM\DEV\config_MBL.sql' QUOTE '' HEXADECIMAL ASIS ;
CALL SAP_GEN_MBL_SCRIPT();
commit;

select * from SAP_TBL where pk_existe='N'
 
*/


commit;


