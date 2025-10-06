-- Categorize students by EL status and calculate years in district
WITH EL_Status AS (
    SELECT 
        STD_NUMBER,
        SYE,
        GRADE_LVL_NUMBER,
        ELL_FLAG,
        ELL_LVL,
        CASE 
            WHEN ETH_RACE = 'African American/Black' THEN 'Black'
            WHEN ETH_RACE = 'Native American/Alaskan Native' THEN 'Indigenous People'
            WHEN ETH_RACE = 'Hawaiian/Pacific Islander' THEN 'Pacific Islander'
            ELSE ETH_RACE 
        END AS ETH_RACE,
        FIRST_ENROLLED_US,
        -- Calculate years in US schools
        DATEDIFF(year, FIRST_ENROLLED_US, GETDATE()) AS Years_in_District
    FROM DWH.ASM.STUDENT_DEMOGRAPHICS_CSY
    WHERE CURRENT_ENROLLED_FLAG = 'Yes'
)
SELECT 
    COUNT(DISTINCT STD_NUMBER) as Student_Count,
    CASE 
        WHEN ELL_FLAG = 0 THEN 'Never EL'
        WHEN ELL_FLAG = 1 AND Years_in_District < 5 THEN 'Current EL (<5 years)'
        WHEN ELL_FLAG = 1 AND Years_in_District >= 5 THEN 'Current EL (5+ years)'
        ELSE 'Former EL'
    END AS EL_Category
FROM EL_Status
GROUP BY 
    CASE 
        WHEN ELL_FLAG = 0 THEN 'Never EL'
        WHEN ELL_FLAG = 1 AND Years_in_District < 5 THEN 'Current EL (<5 years)'
        WHEN ELL_FLAG = 1 AND Years_in_District >= 5 THEN 'Current EL (5+ years)'
        ELSE 'Former EL'
    END
ORDER BY Student_Count DESC;
--Add EL categorization SQL query
