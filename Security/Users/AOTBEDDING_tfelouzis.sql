IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'AOTBEDDING\tfelouzis')
CREATE LOGIN [AOTBEDDING\tfelouzis] FROM WINDOWS
GO
CREATE USER [AOTBEDDING\tfelouzis] FOR LOGIN [AOTBEDDING\tfelouzis]
GO
