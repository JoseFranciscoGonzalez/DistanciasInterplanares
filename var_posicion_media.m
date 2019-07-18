function [var_x,var_y] = var_posicion_media(imagen, XL, XH, YL, YH, ux, uy)
	
	aux= imagen( YL:YH , XL:XH );
	
	B = sum( aux( : ) );
	
	
	
	var_x = 0;
	
	for i=XL:XH
		var_x += (i-ux)^2 * sum( imagen(YL:YH,i) );
	endfor

	var_x /= B;
	
	
	
	var_y = 0;
	for i=YL:YH
		var_y += (i-uy)^2 * sum( imagen(i,XL:XH) );
	endfor

	var_y /= B;

endfunction
