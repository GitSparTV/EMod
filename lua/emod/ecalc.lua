ecalc = ecalc or {}
ecalc.inf = "∞"

-- Current (I) [A]
-- Power / Resistance
function ecalc.IPR(P, R)
	return P / R
end

-- Power / Voltage
function ecalc.IPV(P, V)
	return P / V
end

-- Voltage / Resistance
function ecalc.IVR(V, R)
	return V / R
end

-- Voltage (V) [V]
-- Power * Resistance
function ecalc.VPR(P, R)
	return P * R
end

-- Power / Current
function ecalc.VPI(P, I)
	return P / I
end

-- Current * Resistance
function ecalc.VIR(I, R)
	return I * R
end

-- Resistance (R) [Ω]
-- Voltage / Current
function ecalc.RVI(V, I)
	return V / I
end

-- Voltage ^ 2 / Power
function ecalc.RVP(V, P)
	return V ^ 2 / P
end

-- Power / Current ^ 2
function ecalc.RPI(P, I)
	return P / I ^ 2
end

-- Power (P) [W]
-- Current * Voltage
function ecalc.PIV(I, V)
	return I * V
end

-- Current ^ 2 * Resistance
function ecalc.PIR(I, R)
	return I ^ 2 * R
end

-- Voltage ^ 2 * Resistance
function ecalc.PVR(V, R)
	return V ^ 2 / R
end

-- Formatting
-- I think nested table are better then non-array table
local SIPrefixes = {{10 ^ 6, "M"}, {10 ^ 3, "k"}, {1, ""}, {10 ^ -3, "m"}, {10 ^ -6, "μ"}}

function ecalc.SI(value, space)
	if value == math.huge then
		return ecalc.inf .. (space and " " or "") .. v[2]
	elseif value == -math.huge then
		return "-" .. ecalc.inf .. (space and " " or "") .. v[2]
	end

	for k, v in ipairs(SIPrefixes) do
		if value >= v[1] then return string.format("%.2f", value / v[1]):gsub("%.0+$", "") .. (space and " " or "") .. v[2] end
	end

	return value
end