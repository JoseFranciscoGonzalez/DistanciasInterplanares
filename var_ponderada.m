function v = var_ponderada(data,pesos)
	u = valor_medio_ponderado(data,pesos);
	v = sum( (data .- u).^2 .* pesos ) ./ sum(pesos);
endfunction		
