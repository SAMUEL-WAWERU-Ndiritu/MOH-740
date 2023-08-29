SELECT
    DATE(hanmakdemo.tblsystemusers."LastLoginDate") AS "Date",
    hanmakdemo.tblcustomers."CustomerID" AS "Patient No",
    CONCAT(hanmakdemo.tblcustomers."Surname", ' ', hanmakdemo.tblcustomers."OtherNames") AS "Name",
    DATE_PART('year', AGE(hanmakdemo.tblcustomers."DateOfBirth")) AS "Age(Years)",
    CASE
        WHEN hanmakdemo.tblcustomers."Sex" = 1 THEN 'Male'
        WHEN hanmakdemo.tblcustomers."Sex" = 2 THEN 'Female'
        ELSE 'Other'
    END AS "Sex",
    CASE
        WHEN hanmakdemo.tblvisits."IsRevisit" = 1 THEN 'R'
        ELSE 'F'
    END AS "Is Revisit",
    hanmakdemo.tblgeneralobservations."Weight" AS "Weight(Kgs)",
    hanmakdemo.tblgeneralobservations."Height" * 100 AS "Height (cm)",
    CASE
        WHEN hanmakdemo.tblgeneralobservations."Height" <> 0 THEN
            (hanmakdemo.tblgeneralobservations."Weight" / POWER(hanmakdemo.tblgeneralobservations."Height", 2))
        ELSE NULL
    END AS "BMI",
    CASE
        WHEN (hanmakdemo.tblgeneralobservations."BloodPressureSystolic" >= 140 OR hanmakdemo.tblgeneralobservations."BloodPressureDiastolic" >= 90) THEN 'Hypertension'
        ELSE 'No Hypertension'
    END AS "Hypertension",
    CASE
        WHEN (hanmakdemo.tblgeneralobservations."BloodPressureSystolic" >= 130 AND hanmakdemo.tblgeneralobservations."BloodPressureSystolic" < 140)
             OR (hanmakdemo.tblgeneralobservations."BloodPressureDiastolic" >= 80 AND hanmakdemo.tblgeneralobservations."BloodPressureDiastolic" < 90) THEN 'New'
        WHEN hanmakdemo.tblgeneralobservations."BloodPressureSystolic" >= 140 OR hanmakdemo.tblgeneralobservations."BloodPressureDiastolic" >= 90 THEN 'Known'
        ELSE NULL
    END AS "Hypertension Stage",
    CASE
        WHEN EXISTS (
            SELECT 1 FROM hanmakdemo.tbltests
            WHERE hanmakdemo.tbltests."Name" = 'Fasting Blood Sugar'
              AND hanmakdemo.tbltests."TestID" = hanmakdemo.tblvisitrequestedtestitems."TestID"
        ) THEN
            CASE
                WHEN LOWER(hanmakdemo.tblvisitrequestedtestitems."Conclusion") = 'bs-no mps seen' THEN 'No'
                ELSE 'Yes'
            END
        ELSE 'No'
    END AS "BloodSugarFasting",
    CASE
        WHEN EXISTS (
            SELECT 1 FROM hanmakdemo.tbltests
            WHERE hanmakdemo.tbltests."Name" = 'Random Blood Sugar'
              AND hanmakdemo.tbltests."TestID" = hanmakdemo.tblvisitrequestedtestitems."TestID"
        ) THEN
            CASE
                WHEN LOWER(hanmakdemo.tblvisitrequestedtestitems."Conclusion") = 'bs-no mps seen' THEN 'No'
                ELSE 'Yes'
            END
        ELSE 'No'
    END AS "BloodSugarRandom",
    CASE
        WHEN EXISTS (
            SELECT 1 FROM hanmakdemo.tbltests
            WHERE hanmakdemo.tbltests."Name" = 'HB1C'
              AND hanmakdemo.tbltests."TestID" = hanmakdemo.tblvisitrequestedtestitems."TestID"
        ) THEN
            CASE
                WHEN hanmakdemo.tblvisitrequestedtestitems."Conclusion" SIMILAR TO '^[0-9]+MPS/[0-9]+WBS$' THEN 'Yes'
                ELSE 'No'
            END
        ELSE 'No'
    END AS "HB1C",
    hanmakdemo.tbldiagnosiss."Name" AS "DiagnosisName",
        CONCAT_WS(' ', hanmakdemo.tblprescriptions."Description", hanmakdemo.tblprescriptions."SpecialInstructions", hanmakdemo.tblprescriptionitems."Transcription") AS "Treatment",
        CASE
        WHEN LOWER(hanmakdemo.tbldiagnosiss."Name") = 'diabetic foot' THEN 'Yes'
        ELSE 'No'
    END AS "Diabetic Foot(Y/N)",
     CASE
        WHEN EXISTS (
            SELECT 1 FROM hanmakdemo.tbltests
            WHERE LOWER(hanmakdemo.tbltests."Name") = 't.b microscopy'
              AND hanmakdemo.tbltests."TestID" = hanmakdemo.tblvisitrequestedtestitems."TestID"
        ) THEN
            'Yes'
        ELSE
            'No'
    END AS "Screened for TB (Y/N)",
    CASE
        WHEN EXISTS (
            SELECT 1 FROM hanmakdemo.tbltests
            WHERE LOWER(hanmakdemo.tbltests."Name") = 't.b microscopy'
              AND hanmakdemo.tbltests."TestID" = hanmakdemo.tblvisitrequestedtestitems."TestID"
        ) THEN
            CASE
                WHEN LOWER(hanmakdemo.tblvisitrequestedtestitems."Conclusion") LIKE '%positive%' OR
                     LOWER(hanmakdemo.tblvisitrequestedtestitems."Conclusion") LIKE '%detected%' THEN 'Yes'
                ELSE 'No'
            END
        ELSE
            'No'
    END AS "TB Status",
     CASE
        WHEN hanmakdemo.tblschemes."Name" ILIKE '%NHIF%' THEN 'Yes'
        ELSE 'No'
    END AS "NHIF(Y/N)"
FROM
    hanmakdemo.tblgeneralobservations
INNER JOIN
    hanmakdemo.tbladmissions ON hanmakdemo.tblgeneralobservations."AdmissionID" = hanmakdemo.tbladmissions."AdmissionID"
INNER JOIN
    hanmakdemo.tblmedicalclinicvisits ON hanmakdemo.tbladmissions."MedicalClinicVisitID" = hanmakdemo.tblmedicalclinicvisits."MedicalClinicVisitID"
INNER JOIN
    hanmakdemo.tblvisits ON hanmakdemo.tblmedicalclinicvisits."VisitID" = hanmakdemo.tblvisits."VisitID"
INNER JOIN
    hanmakdemo.tblcustomers ON hanmakdemo.tblvisits."CustomerID" = hanmakdemo.tblcustomers."CustomerID"
INNER JOIN
    hanmakdemo.tblcustomerschemes ON hanmakdemo.tblcustomerschemes."CustomerID" = hanmakdemo.tblcustomers."CustomerID"
INNER JOIN
    hanmakdemo.tblschemes ON hanmakdemo.tblcustomerschemes."SchemeID" = hanmakdemo.tblschemes."SchemeID"
INNER JOIN
    hanmakdemo.tblmedicalclinicvisitdiagnosiss ON hanmakdemo.tblmedicalclinicvisitdiagnosiss."MedicalClinicVisitID" = hanmakdemo.tblmedicalclinicvisits."MedicalClinicVisitID"
INNER JOIN
    hanmakdemo.tbldiagnosiss ON hanmakdemo.tblmedicalclinicvisitdiagnosiss."DiagnosisID" = hanmakdemo.tbldiagnosiss."DiagnosisID"
INNER JOIN
    hanmakdemo.tblmedicalclinicvisitprescriptions ON hanmakdemo.tblmedicalclinicvisitprescriptions."MedicalClinicVisitID" = hanmakdemo.tblmedicalclinicvisits."MedicalClinicVisitID"
INNER JOIN
    hanmakdemo.tblprescriptions ON hanmakdemo.tblmedicalclinicvisitprescriptions."PrescriptionID" = hanmakdemo.tblprescriptions."PrescriptionID"
INNER JOIN
    hanmakdemo.tblprescriptionitems ON hanmakdemo.tblprescriptionitems."PrescriptionID" = hanmakdemo.tblprescriptions."PrescriptionID"
INNER JOIN
    hanmakdemo.tblsystemusers ON hanmakdemo.tblcustomers."RegisteredBySysUID" = hanmakdemo.tblsystemusers."SystemUserID"
INNER JOIN
    hanmakdemo.tblvisitrequestedtests ON hanmakdemo.tblvisitrequestedtests."VisitID" = hanmakdemo.tblvisits."VisitID"
INNER JOIN
    hanmakdemo.tblvisitrequestedtestitems ON hanmakdemo.tblvisitrequestedtestitems."VisitRequestedTestID" = hanmakdemo.tblvisitrequestedtests."VisitRequestedTestID"
INNER JOIN
    hanmakdemo.tbltests ON hanmakdemo.tblvisitrequestedtestitems."TestID" = hanmakdemo.tbltests."TestID";
