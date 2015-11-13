SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SaveQualificationTestResult] @id nvarchar(50), @hrm_qual_test_spec_pk int, @hrm_pers_prpty_pk int, @result nvarchar(25), @expiration_date datetime, @test_date datetime
as
begin tran here
update SitMesDb..hrm_pers_qual_test_result set valid=0 where hrm_qual_test_spec_pk=@hrm_qual_test_spec_pk and hrm_pers_prpty_pk=@hrm_pers_prpty_pk and valid=1
insert into SitMesDb..hrm_pers_qual_test_result(id,result,test_date,expiration_date,hrm_qual_test_spec_pk,last_prog,hrm_pers_prpty_pk,valid)
values( @id, @result, @test_date,  @expiration_date, @hrm_qual_test_spec_pk,'ssb', @hrm_pers_prpty_pk, 1 )
return scope_identity()
commit tran here
GO
