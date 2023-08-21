SELECT
    base_query.*,
    CASE
        WHEN nhif_data."CustomerID" IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS "NHIF(Y/N)"
FROM (
    SELECT
        c."OutPatientNo" AS "PatientNo",
        CONCAT(c."OtherNames", ' ', c."Surname") AS "Name",
        EXTRACT(YEAR FROM AGE(c."DateOfBirth")) AS "AgeYears",
        CASE
            WHEN c."Sex" = 1 THEN 'Male'
            WHEN c."Sex" = 2 THEN 'Female'
            ELSE 'Unknown'
        END AS "Sex",
        CASE
            WHEN v."IsRevisit" = 1 THEN 'R'
            ELSE 'F'
        END AS "F-first visit/R-revisit",
        obs."Weight" AS "WeightKgs",
        obs."Height" AS "HeightCm",
        CASE
            WHEN obs."Height" <> 0 THEN ROUND(obs."Weight" / ((obs."Height" / 100) * (obs."Height" / 100)), 4)
            ELSE NULL
        END AS "BMI",
        CONCAT(obs."BloodPressureSystolic", '/', obs."BloodPressureDiastolic") AS "BloodPressure",
        CASE
            WHEN obs."BloodPressureSystolic" >= 140 OR obs."BloodPressureDiastolic" >= 90 THEN 'Yes'
            ELSE 'No'
        END AS "HTN",
        MAX(CASE WHEN scd."ColumnName" = 'bloodsugar_fasting' THEN scd_opt."Name" END) AS "BloodSugarFasting",
        MAX(CASE WHEN scd."ColumnName" = 'bloodsugar_random' THEN scd_opt."Name" END) AS "BloodSugarRandom",
        MAX(CASE WHEN scd."ColumnName" = 'HBA1C' THEN scd_opt."Name" END) AS "HBA1C",
        c."CustomerID"  
    FROM
        hanmakdemo.tblcustomers c
    JOIN
        hanmakdemo.tblgeneralobservations obs ON c."CustomerID" = obs."CapturedBySysUID"
    JOIN
        hanmakdemo.tblvisits v ON c."CustomerID" = v."CustomerID"
    LEFT JOIN
        hanmakdemo.tbldepartments dep ON v."CompanyBranchID" = dep."CompanyBranchID"
    LEFT JOIN
        hanmakdemo.tblmedicalclinics mc ON dep."DepartmentID" = mc."DepartmentID"
    LEFT JOIN
        hanmakdemo.tblcompanybranchs cb ON dep."CompanyBranchID" = cb."CompanyBranchID"
    LEFT JOIN
        hanmakdemo.tblspecialclinicdatas scd ON mc."MedicalClinicID" = scd."MedicalClinicID"
    LEFT JOIN
        hanmakdemo.tblspecialclinicdataoptions scd_opt ON scd."SpecialClinicDataID" = scd_opt."SpecialClinicDataID"
    GROUP BY
        c."OutPatientNo",
        c."OtherNames",
        c."Surname",
        c."DateOfBirth",
        c."Sex",
        v."IsRevisit",
        obs."Weight",
        obs."Height",
        obs."BloodPressureSystolic",
        obs."BloodPressureDiastolic",
        obs."BloodPressureSystolic",
        obs."BloodPressureDiastolic",
        scd_opt."Name",
        c."CustomerID" 
) AS base_query
LEFT JOIN (
    SELECT
        cs."CustomerID"
    FROM
        hanmakdemo.tblcustomerschemes cs
    JOIN
        hanmakdemo.tblschemes sch ON cs."SchemeID" = sch."SchemeID"
    WHERE
        sch."Name" ILIKE '%NHIF%'
) AS nhif_data ON base_query."CustomerID" = nhif_data."CustomerID";
