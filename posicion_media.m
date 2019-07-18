# Calcula la posicion del pixel mas iluminado de una imagen
# en un rango de pixeles de la imagen (debe ser una matriz de escala de grises)
# en X en el intervalo [XL XH] y en Y en el intervalo [YL YH]

function [x_medio,y_medio] = posicion_media(imagen, XL, XH, YL, YH)
	
	aux= imagen( YL:YH , XL:XH );
	
	B = sum( aux( : ) );
	
	
	
	x_medio=0;
	
	for i=XL:XH
		x_medio += i * sum( imagen(YL:YH,i) );
	endfor

	x_medio /= B;
	
	
	
	y_medio=0;
	for i=YL:YH
		y_medio += i * sum( imagen(i,XL:XH) );
	endfor

	y_medio /= B;

endfunction
