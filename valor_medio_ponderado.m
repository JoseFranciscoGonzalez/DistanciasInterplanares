function u = valor_medio_ponderado(data,pesos)
	u = sum(data .* pesos) ./ sum(pesos);
endfunction	
