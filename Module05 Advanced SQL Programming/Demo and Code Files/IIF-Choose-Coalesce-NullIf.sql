/*Desc: This Demo outlines some comon fuctions used for processing data
*/

Declare @SomeInt int  = 1
Select IIF(@SomeInt = 1, 't', 'f')
Select Choose(@SomeInt, 'a', 'b', 'c')
Select Coalesce(@SomeInt, 0)

Declare @SomeString int = '1'
Select IIF(@SomeString = '1', 't', 'f')
Select Choose(@SomeString, 'a', 'b', 'c') 
Select Coalesce(@SomeString, '0')
Select NullIf(@SomeString, 0) -- Will be null if Zero