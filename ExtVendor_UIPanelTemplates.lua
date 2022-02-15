function ExtVendor_ScrollFrameTemplate_OnMouseWheel(self, value, scrollBar)
	scrollBar = scrollBar or _G[self:GetName() .. "ScrollBar"];
	local scrollStep = scrollBar.scrollStep or scrollBar:GetHeight() / 2
	if ( value > 0 ) then
		scrollBar:SetValue(scrollBar:GetValue() - scrollStep);
	else
		scrollBar:SetValue(scrollBar:GetValue() + scrollStep);
	end
end

--[[ function CloseSpecialWindows()
	local found;
	for index, value in pairs(UISpecialFrames) do
		local frame = _G[value];
		if ( frame and frame:IsShown() ) then
			frame:Hide();
			found = 1;
		end
	end
	return found;
end
 ]]