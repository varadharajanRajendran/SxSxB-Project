SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AddNewExceptionDomain] 
	-- Add the parameters for the stored procedure here
	@ExceptionDomain VARCHAR(50),
	@Descption VARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.ExceptionDomains(ExceptionDomain, [Description])
	VALUES(@ExceptionDomain, @Descption)
END

GO
