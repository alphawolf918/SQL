if @record_type = 'orderEntryPhone'
begin
	select
		@status = 10,
		@field01_value_out = 
			case
				when @field01_value = '' then '478-788-2448'
				when @field01_value = '.' then '478-788-2448'
			end
end