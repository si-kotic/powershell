/****** Object:  Login [pdm]    Script Date: 10/25/2012 12:57:54 ******/
CREATE LOGIN [pdm] WITH PASSWORD=N'pdm', DEFAULT_DATABASE=[AFPDM], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [AFPDM]
GO
/****** Object:  User [pdm]    Script Date: 10/25/2012 12:57:14 ******/
CREATE USER [pdm] FOR LOGIN [pdm] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [AFPDM]
GO
EXEC sp_addrolemember N'db_datareader', N'pdm'
GO
USE [AFPDM]
GO
EXEC sp_addrolemember N'db_datawriter', N'pdm'
GO
USE [AFPDM]
GO
EXEC sp_addrolemember N'db_owner', N'pdm'
GO
