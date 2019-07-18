#Grafico de contornos y corte de un pixel, de patron de difracción de electrones
# https://octave.sourceforge.io/image/
# pkg install image-2.10.0.tar.gz    tarda un tiempo en instalar
clear all;
close all;
pkg load image 
graphics_toolkit gnuplot

dirs_difraccion_X_kV = ["/3.04kV/"; "/3.5kV/"; "/4kV/"; "/4.5kV/"; "/5kV/"];
str_volts = ["3.04kV";"3.5kV";"4kV";"4.5kV";"5kV"];

#Rangos de pixeles elegidos para procesar de la foto por cada potencial aplicado
rangos_pixeles_X_kV = [330 722 171 611;
					   332 734 200 586;
					   345 720 204 574;
					   357 702 207 559;
					   370 696 219 552];
					   
rangos_ajuste = [420 450 623 640 348 377 689 716 273 296 484 497 205 242 545 584;
				 433 457 616 637 358 393 679 708 295 310 472 497 220 251 529 566;
				 443 452 609 621 363 401 663 693 293 312 459 487 225 252 519 552;
				 446 462 608 618 382 403 655 683 299 317 457 479 231 268 517 540;
				 448 465 600 617 390 413 653 670 303 322 459 475 245 269 515 534 
				];
# 1 ~ 2 rango del radio interior izquierdo en altura media
# 3 ~ 4 rango del radio interior derecho en altura media
# 5 ~ 6 rango del radio exterior izquierdo en altura media
# 7 ~ 8 rango del radio exterior derecho en altura media

# 9 ~ 10 rango del radio interior izquierdo en largo medio
# 11 ~ 12 rango del radio interior derecho en largo medio
# 13 ~ 14 rango del radio interior izquierdo en largo medio
# 15 ~ 16 rango del radio interior derecho en largo medio				
				
								
				

rangos_ajuste_recta = [50 460 580 700 50 460 580 700 250 350 425 550 150 300 475 600];
# 1 ~ 2 rango  recta cerca del radio interior izquierdo en altura media
# 3 ~ 4 rango recta cerca del radio interior derecho en altura media
# 5 ~ 6 rango  recta cerca del radio exterior izquierdo en altura media
# 7 ~ 8 rango recta cerca del radio exterior derecho en altura media

# 9 ~ 10 rango  recta cerca del radio interior izquierdo en largo medio
# 11 ~ 12 rango recta cerca del radio interior derecho en largo medio
# 13 ~ 14 rango  recta cerca del radio interior izquierdo en largo medio
# 15 ~ 16 rango recta cerca del radio interior derecho en largo medio


				
##########################################									   
k=4; # modificar este valor para ver los diametros de tal difraccion de X_kV
# Por ejemplo k=5 es para 5kV
# y se asigna [1 2 3 4 5] para ["/3.04kV/"; "3.5kV"; "/4kV/"; "/4.5kV/"; "/5kV/"]
# respectivamente
#####################################################
dir_WEBCAM_X_kV = strcat(pwd,"/Webcam/", dirs_difraccion_X_kV(k,:) );
dir_jpgs = fullfile(dir_WEBCAM_X_kV,"*.jpg");
dir_imagenes = dir(dir_jpgs);
cantidad_imagenes = length(dir_imagenes);

H = 720;
L = 960;

imgs_gris = zeros(H, L, cantidad_imagenes);
imgs_gris = uint8(imgs_gris);

for i = 1:cantidad_imagenes
	nombre_imagen = dir_imagenes(i).name;
	dir_imagen = fullfile(dir_WEBCAM_X_kV, nombre_imagen);
	imagen_color = imread(dir_imagen);
	
	if( isgray(imagen_color) )
		imagen_gris = imagen_color;		
	else		
		imagen_gris = rgb2gray(imagen_color);
	endif
	
	imgs_gris(:, :, i) = imagen_gris;
	 		
endfor
#{
b = sum(double(imgs_gris),3);
a = b./ cantidad_imagenes;
a = uint8(a);
imagen_gris = a;


XL = rangos_pixeles_X_kV(k,1);
XH = rangos_pixeles_X_kV(k,2);
YL = rangos_pixeles_X_kV(k,3);
YH = rangos_pixeles_X_kV(k,4);

[x_medio,y_medio] = posicion_media(a,XL,XH,YL,YH)

figure(1)
plot( XL:XH, b(round(y_medio),XL:XH) )
figure(2)
imagesc(a);
colormap hot
hf3=figure(3)
set(hf3,'PaperUnits','inches','PaperPosition',[0 0 7 4.5]);

Ha = axes;
# Aqui agarro de la imagen el barrido de pixeles entre XL y XH en la altura y_medio
# Este pedazo de imagen pongo en el fondo del grafico y esta escalado entre
# XL y XH y las intensidades 0 a 255
imagesc(Ha,[XL XH],[0 255],imagen_gris(round(y_medio),XL:XH));
colormap hot;
hold on;

set(Ha,'Box','on','FontSize',9,'GridLineStyle','--','LineWidth',1,'TickDir','in');
set(Ha,"xgrid","off","ygrid","off","xminorgrid","off","yminorgrid","off");
set(Ha,"ydir","normal");

altura_media = round(y_medio);
# Elijo la montania de intensidad asociada a la altura media de la imagen barriendo desde el pixel XL hasta XH
montania = imagen_gris(altura_media, XL:XH); 
plot(Ha,XL:XH,montania,'b-','Linewidth',8);
#plot(Ha,XL:XH,polyval(p,XL:XH,s,mu),'g-','Linewidth',8);
axis(Ha,[XL XH 0 255 ]);

#print(hf1,'Intensidad_en_altura_media.pdf','-dpdf','-r1000');

#system("pdfcrop Intensidad_en_altura_media.pdf");
#system("evince Intensidad_en_altura_media-crop.pdf &");
#system("rm Intensidad_en_altura_media.pdf");

return
#}


diametros_interior_pixel = zeros(cantidad_imagenes,2); 
ddiametros_interior_pixel = zeros(cantidad_imagenes,2);

diametros_exterior_pixel = zeros(cantidad_imagenes,2); 
ddiametros_exterior_pixel = zeros(cantidad_imagenes,2);

###############################################################################
# Este indice representa que numero de foto se va a procesar en la carpeta X_kV
# elegida
# Estos son los mas intensos
# i = 15    k=1 3.04kV
# i = 2     k=2 3.5kV
# i = 3     k=3 4kV
# i = 1     k=4 4.5kV 
# i = 1 	k=5 5kV
i=5
###############################################################################
#### Nombre de la imagen elgida asociado al indice i ####
%for i=1:cantidad_imagenes

dir_imagenes(i).name

####### Selecciono la imagen a procesar y graficar  #####
imagen_gris = imgs_gris(:,:,i);




[H,L] = size(imagen_gris);

#Rangos de pixeles de la imagen que interesan saber
XL = rangos_pixeles_X_kV(k,1);
XH = rangos_pixeles_X_kV(k,2);
YL = rangos_pixeles_X_kV(k,3);
YH = rangos_pixeles_X_kV(k,4);

#Hallo las coordenadas del pixel mas iluminado
[x_medio,y_medio] = posicion_media(imagen_gris,XL,XH,YL,YH);


#Rango de pixeles donde se encuentra el radio interior y exterior de difraccion para ajustar su entorno de intensidad como una parabola

rango_ri_izq_uy = [rangos_ajuste(k,1) rangos_ajuste(k,2)];
rango_ri_der_uy = [rangos_ajuste(k,3) rangos_ajuste(k,4)];
rango_re_izq_uy = [rangos_ajuste(k,5) rangos_ajuste(k,6)];
rango_re_der_uy = [rangos_ajuste(k,7) rangos_ajuste(k,8)];

rango_ri_izq_ux = [rangos_ajuste(k,9) rangos_ajuste(k,10)];
rango_ri_der_ux = [rangos_ajuste(k,11) rangos_ajuste(k,12)];
rango_re_izq_ux = [rangos_ajuste(k,13) rangos_ajuste(k,14)];
rango_re_der_ux = [rangos_ajuste(k,15) rangos_ajuste(k,16)];


rango_recta_ri_izq_uy = [rangos_ajuste_recta(1,1) rangos_ajuste_recta(1,2)];
rango_recta_ri_der_uy = [rangos_ajuste_recta(1,3) rangos_ajuste_recta(1,4)];
rango_recta_re_izq_uy = [rangos_ajuste_recta(1,5) rangos_ajuste_recta(1,6)];
rango_recta_re_der_uy = [rangos_ajuste_recta(1,7) rangos_ajuste_recta(1,8)];

rango_recta_ri_izq_ux = [rangos_ajuste_recta(1,9) rangos_ajuste_recta(1,10)];
rango_recta_ri_der_ux = [rangos_ajuste_recta(1,11) rangos_ajuste_recta(1,12)];
rango_recta_re_izq_ux = [rangos_ajuste_recta(1,13) rangos_ajuste_recta(1,14)];
rango_recta_re_der_ux = [rangos_ajuste_recta(1,15) rangos_ajuste_recta(1,16)];



x = double(rango_ri_izq_uy(1):rango_ri_izq_uy(2));
y = double(imagen_gris(round(y_medio),x));
[px_izq_int, sx_izq_int, mux_izq_int] = polyfit(x,y,2);
ux_izq_int = valor_medio_ponderado(x,polyval(px_izq_int,x,sx_izq_int,mux_izq_int));
dx_izq_int = sqrt(var_ponderada(x,polyval(px_izq_int,x,sx_izq_int,mux_izq_int)));


x = double(rango_recta_ri_izq_uy(1):rango_recta_ri_izq_uy(2));
y = double(imagen_gris(round(y_medio),x));
[px_recta_izq_int, sx_recta_izq_int, mux_recta_izq_int] = polyfit(x,y,1);
#ux_izq_int = valor_medio_ponderado(x,polyval(px_izq_int,x,sx_izq_int,mux_izq_int));
#dx_izq_int = sqrt(var_ponderada(x,polyval(px_izq_int,x,sx_izq_int,mux_izq_int)));




x = double(rango_ri_der_uy(1):rango_ri_der_uy(2));
y = double(imagen_gris(round(y_medio),x));

[px_der_int, sx_der_int, mux_der_int] = polyfit(x,y,2);
ux_der_int = valor_medio_ponderado(x,polyval(px_der_int,x,sx_der_int,mux_der_int));
dx_der_int = sqrt(var_ponderada(x,polyval(px_der_int,x,sx_der_int,mux_der_int)));



x = double(rango_recta_ri_der_uy(1):rango_recta_ri_der_uy(2));
y = double(imagen_gris(round(y_medio),x));
[px_recta_der_int, sx_recta_der_int, mux_recta_der_int] = polyfit(x,y,1);
#ux_der_int = valor_medio_ponderado(x,polyval(px_der_int,x,sx_der_int,mux_der_int));
#dx_der_int = sqrt(var_ponderada(x,polyval(px_der_int,x,sx_der_int,mux_der_int)));
%maximo_real = ux_der_int-ux_izq_int + (px_recta_der_int(1)/(2*px_der_int(1)))

diametros_interior_pixel(i,1) = ux_der_int-ux_izq_int; 
ddiametros_interior_pixel(i,1) = sqrt( dx_der_int^2 + dx_izq_int^2 );

maximo_real_interior(i,1) = ux_der_int-ux_izq_int + (px_recta_der_int(1)/(2*px_der_int(1)));



x = double(rango_ri_izq_ux(1):rango_ri_izq_ux(2));
y = double(imagen_gris(x, round(x_medio))');
[py_izq_int, sy_izq_int, muy_izq_int] = polyfit(x,y,2);
uy_izq_int = valor_medio_ponderado(x,polyval(py_izq_int,x,sy_izq_int,muy_izq_int));
dy_izq_int = sqrt(var_ponderada(x,polyval(py_izq_int,x,sy_izq_int,muy_izq_int)));


x = double(rango_recta_ri_izq_ux(1):rango_recta_ri_izq_ux(2));
y = double(imagen_gris(x, round(x_medio))');
[py_recta_izq_int, sy_recta_izq_int, muy_recta_izq_int] = polyfit(x,y,1);
#uy_izq_int = valor_medio_ponderado(x,polyval(py_izq_int,x,sy_izq_int,muy_izq_int));
#dy_izq_int = sqrt(var_ponderada(x,polyval(py_izq_int,x,sy_izq_int,muy_izq_int)));


x = double(rango_ri_der_ux(1):rango_ri_der_ux(2));
y = double(imagen_gris(x, round(x_medio))');
[py_der_int, sy_der_int, muy_der_int] = polyfit(x,y,2);
uy_der_int = valor_medio_ponderado(x,polyval(py_der_int,x,sy_der_int,muy_der_int));
dy_der_int = sqrt(var_ponderada(x,polyval(py_der_int,x,sy_der_int,muy_der_int)));


x = double(rango_recta_ri_der_ux(1):rango_recta_ri_der_ux(2));
y = double(imagen_gris(x, round(x_medio))');
[py_recta_der_int, sy_recta_der_int, muy_recta_der_int] = polyfit(x,y,1);
#uy_der_int = valor_medio_ponderado(x,polyval(py_der_int,x,sy_der_int,muy_der_int));
#dy_der_int = sqrt(var_ponderada(x,polyval(py_der_int,x,sy_der_int,muy_der_int)));

diametros_interior_pixel(i,2) = uy_der_int-uy_izq_int; 
ddiametros_interior_pixel(i,2) = sqrt( dy_der_int^2 + dy_izq_int^2 );


%maximo_real(i,2) = uy_der_int-uy_izq_int + (py_recta_der_int(1)/(2*py_der_int(1)))




x = double(rango_re_izq_uy(1):rango_re_izq_uy(2));
y = double(imagen_gris(round(y_medio),x));
[px_izq_ext, sx_izq_ext, mux_izq_ext] = polyfit(x,y,2);
ux_izq_ext = valor_medio_ponderado(x,polyval(px_izq_ext,x,sx_izq_ext,mux_izq_ext));
dx_izq_ext = sqrt(var_ponderada(x,polyval(px_izq_ext,x,sx_izq_ext,mux_izq_ext)));


x = double(rango_recta_re_izq_uy(1):rango_recta_re_izq_uy(2));
y = double(imagen_gris(round(y_medio),x));
[px_recta_izq_ext, sx_recta_izq_ext, mux_recta_izq_ext] = polyfit(x,y,1);
#ux_izq_ext = valor_medio_ponderado(x,polyval(px_izq_ext,x,sx_izq_ext,mux_izq_ext));
#dx_izq_ext = sqrt(var_ponderada(x,polyval(px_izq_ext,x,sx_izq_ext,mux_izq_ext)));


x = double(rango_re_der_uy(1):rango_re_der_uy(2));
y = double(imagen_gris(round(y_medio),x));

[px_der_ext, sx_der_ext, mux_der_ext] = polyfit(x,y,2);
ux_der_ext = valor_medio_ponderado(x,polyval(px_der_ext,x,sx_der_ext,mux_der_ext));
dx_der_ext = sqrt(var_ponderada(x,polyval(px_der_ext,x,sx_der_ext,mux_der_ext)));

x = double(rango_recta_re_der_uy(1):rango_recta_re_der_uy(2));
y = double(imagen_gris(round(y_medio),x));
[px_recta_der_ext, sx_recta_der_ext, mux_recta_der_ext] = polyfit(x,y,1);
#ux_der_ext = valor_medio_ponderado(x,polyval(px_der_ext,x,sx_der_ext,mux_der_ext));
#dx_der_ext = sqrt(var_ponderada(x,polyval(px_der_ext,x,sx_der_ext,mux_der_ext)));


diametros_exterior_pixel(i,1) = ux_der_ext-ux_izq_ext; 
ddiametros_exterior_pixel(i,1) = sqrt( dx_der_ext^2 + dx_izq_ext^2 );

%maximo_real_exterior(i,1) = ux_der_ext-ux_izq_ext + (px_recta_der_int(1)/(2*py_der_int(1)))


x = double(rango_re_izq_ux(1):rango_re_izq_ux(2));
y = double(imagen_gris(x, round(x_medio))');
[py_izq_ext, sy_izq_ext, muy_izq_ext] = polyfit(x,y,2);
uy_izq_ext = valor_medio_ponderado(x,polyval(py_izq_ext,x,sy_izq_ext,muy_izq_ext));
dy_izq_ext = sqrt(var_ponderada(x,polyval(py_izq_ext,x,sy_izq_ext,muy_izq_ext)));


x = double(rango_recta_re_izq_ux(1):rango_recta_re_izq_ux(2));
y = double(imagen_gris(x, round(x_medio))');
[py_recta_izq_ext, sy_recta_izq_ext, muy_recta_izq_ext] = polyfit(x,y,1);
#uy_izq_ext = valor_medio_ponderado(x,polyval(py_izq_ext,x,sy_izq_ext,muy_izq_ext));
#dy_izq_ext = sqrt(var_ponderada(x,polyval(py_izq_ext,x,sy_izq_ext,muy_izq_ext)));


x = double(rango_re_der_ux(1):rango_re_der_ux(2));
y = double(imagen_gris(x, round(x_medio))');
[py_der_ext, sy_der_ext, muy_der_ext] = polyfit(x,y,2);
uy_der_ext = valor_medio_ponderado(x,polyval(py_der_ext,x,sy_der_ext,muy_der_ext));
dy_der_ext = sqrt(var_ponderada(x,polyval(py_der_ext,x,sy_der_ext,muy_der_ext)));


x = double(rango_recta_re_der_ux(1):rango_recta_re_der_ux(2));
y = double(imagen_gris(x, round(x_medio))');
[py_recta_der_ext, sy_recta_der_ext, muy_recta_der_ext] = polyfit(x,y,1);
#uy_der_ext = valor_medio_ponderado(x,polyval(py_der_ext,x,sy_der_ext,muy_der_ext));
#dy_der_ext = sqrt(var_ponderada(x,polyval(py_der_ext,x,sy_der_ext,muy_der_ext)));

diametros_exterior_pixel(i,2) = uy_der_ext-uy_izq_ext; 
ddiametros_exterior_pixel(i,2) = sqrt( dy_der_ext^2 + dy_izq_ext^2 );




%endfor

diametros_interior_pixel./76
ddiametros_interior_pixel./76
maximo_real_interior./76


diametros_exterior_pixel./76
ddiametros_exterior_pixel./76

%return



#[ri_izq_uy dri_izq_uy] = polyval(p,x_v,S)

hf1=figure(1);
#imrotate(imagen_gris,180);

set(hf1,'PaperUnits','inches','PaperPosition',[0 0 7 4.5]);

Ha = axes;
# Aqui agarro de la imagen el barrido de pixeles entre XL y XH en la altura y_medio
# Este pedazo de imagen pongo en el fondo del grafico y esta escalado entre
# XL y XH y las intensidades 0 a 255
#imagesc(Ha,[XL XH],[0 255],imagen_gris(round(y_medio),XL:XH));
#colormap hot;
#c=colorbar(Ha);
#ylabel(c,"Intensidad");
hold on;

set(Ha,'Box','on','FontSize',9,'GridLineStyle','--','LineWidth',1,'TickDir','in');
set(Ha,"xgrid","off","ygrid","off","xminorgrid","off","yminorgrid","off");
set(Ha,"ydir","normal");

altura_media = round(y_medio);
# Elijo la montania de intensidad asociada a la altura media de la imagen barriendo desde el pixel XL hasta XH
montania = imagen_gris(altura_media, XL:XH); 
plot(Ha,XL:XH,montania,'b-','Linewidth',8);
plot(Ha,XL:XH,polyval(px_izq_int,XL:XH,sx_izq_int,mux_izq_int),'g-','Linewidth',8);
plot(Ha,rango_recta_ri_izq_uy(1):rango_recta_ri_izq_uy(2),polyval(px_recta_izq_int,rango_recta_ri_izq_uy(1):rango_recta_ri_izq_uy(2),sx_recta_izq_int,mux_recta_izq_int),'y-','Linewidth',8);
plot(Ha,XL:XH,polyval(px_izq_int,XL:XH,sx_izq_int,mux_izq_int) .- polyval(px_recta_izq_int,XL:XH,sx_recta_izq_int,mux_recta_izq_int) .+ 10,'c-','Linewidth',8);
plot(Ha,XL:XH,polyval(px_izq_ext,XL:XH,sx_izq_ext,mux_izq_ext),'k-','Linewidth',8);
plot(Ha,rango_recta_re_izq_uy(1):rango_recta_re_izq_uy(2),polyval(px_recta_izq_ext,rango_recta_re_izq_uy(1):rango_recta_re_izq_uy(2),sx_recta_izq_ext,mux_recta_izq_ext),'r-','Linewidth',8);
plot(Ha,XL:XH,polyval(px_izq_ext,XL:XH,sx_izq_ext,mux_izq_ext) .- polyval(px_recta_izq_ext,XL:XH,sx_recta_izq_ext,mux_recta_izq_ext) .+ 10,'m-','Linewidth',8);
plot(Ha,XL:XH,polyval(px_der_int,XL:XH,sx_der_int,mux_der_int),'g-','Linewidth',8);
plot(Ha,rango_recta_ri_der_uy(1):rango_recta_ri_der_uy(2),polyval(px_recta_der_int,rango_recta_ri_der_uy(1):rango_recta_ri_der_uy(2),sx_recta_der_int,mux_recta_der_int),'y-','Linewidth',8);
plot(Ha,XL:XH,polyval(px_der_int,XL:XH,sx_der_int,mux_der_int) .- polyval(px_recta_der_int,XL:XH,sx_recta_der_int,mux_recta_der_int) .+ 10,'c-','Linewidth',8);
plot(Ha,XL:XH,polyval(px_der_ext,XL:XH,sx_der_ext,mux_der_ext),'k-','Linewidth',8);
plot(Ha,rango_recta_re_der_uy(1):rango_recta_re_der_uy(2),polyval(px_recta_der_ext,rango_recta_re_der_uy(1):rango_recta_re_der_uy(2),sx_recta_der_ext,mux_recta_der_ext),'r-','Linewidth',8);
plot(Ha,XL:XH,polyval(px_der_ext,XL:XH,sx_der_ext,mux_der_ext) .- polyval(px_recta_der_ext,XL:XH,sx_recta_der_ext,mux_recta_der_ext) .+ 10,'m-','Linewidth',8);
axis(Ha,[XL XH 0 255 ]);

ylabel(Ha,"Intensidad","fontsize",12);
xlabel(Ha,"Largo de la imagen [pixel]","fontsize",12);

LEYENDA1 = sprintf("Intensidad en la altura <y> a lo largo de la imagen.");
LEYENDA2 = sprintf("Ajuste de parabola para los radios de difraccion interiores");
LEYENDA3 = sprintf("Ajuste de recta para los radios de difraccion interiores");
LEYENDA4 = sprintf("Resta de parabola y recta para los radios de difraccion interiores");
LEYENDA5 = sprintf("Ajuste de parabola para los radios de difraccion exteriores");
LEYENDA6 = sprintf("Ajuste de recta para los radios de difraccion exteriores");
LEYENDA7 = sprintf("Resta de parabola y recta para los radios de difraccion exteriores");
Hleg = legend(Ha,LEYENDA1,LEYENDA2,LEYENDA3,LEYENDA4,LEYENDA5,LEYENDA6,LEYENDA7,"location",'northoutside');
legend(Ha,"boxon");
set(Hleg,'FontSize',5);


NOMBRE_GRAFICO = sprintf("Intensidad_altura_media");
EXTENSION_ARCHIVO = sprintf(".pdf");

NOMBRE_ARCHIVO = sprintf("%s_%s_%s%s",
						 NOMBRE_GRAFICO,str_volts(k,:),
						 dir_imagenes(i).name,EXTENSION_ARCHIVO
                        );
NOMBRE_ARCHIVO_CROP = sprintf("%s_%s_%s-crop%s",
						 NOMBRE_GRAFICO,str_volts(k,:),
						 dir_imagenes(i).name,EXTENSION_ARCHIVO
                        );                        
                        

print(hf1,NOMBRE_ARCHIVO,'-dpdf','-r1000');

COMANDO = sprintf("pdfcrop \"%s\"",NOMBRE_ARCHIVO);
system(COMANDO);
COMANDO = sprintf("evince \"%s\" &",NOMBRE_ARCHIVO_CROP); 
system(COMANDO);
COMANDO = sprintf("rm \"%s\"",NOMBRE_ARCHIVO);
system(COMANDO);


hf2=figure(2);

set(hf2,'PaperUnits','inches','PaperPosition',[0 0 7 4.5]);

Ha = axes;
# Aqui agarro de la imagen el barrido de pixeles entre XL y XH en la altura y_medio
# Este pedazo de imagen pongo en el fondo del grafico y esta escalado entre
# XL y XH y las intensidades 0 a 255
#imagesc(Ha,[YL YH],[0 255],imagen_gris(YL:YH,round(x_medio))' );
#colormap hot;
#c=colorbar(Ha);
#ylabel(c,"Intensidad");
hold on;

set(Ha,'Box','on','FontSize',9,'GridLineStyle','--','LineWidth',1,'TickDir','in');
set(Ha,"xgrid","off","ygrid","off","xminorgrid","off","yminorgrid","off");
set(Ha,"ydir","normal");

largo_medio = round(x_medio);
# Elijo la montania de intensidad asociada a la altura media de la imagen barriendo desde el pixel XL hasta XH
montania = imagen_gris(YL:YH,largo_medio); 
plot(Ha,YL:YH,montania,'b-','Linewidth',8);
plot(Ha,YL:YH,polyval(py_izq_int,YL:YH,sy_izq_int,muy_izq_int),'g-','Linewidth',8);
plot(Ha,rango_recta_ri_izq_ux(1):rango_recta_ri_izq_ux(2),polyval(py_recta_izq_int,rango_recta_ri_izq_ux(1):rango_recta_ri_izq_ux(2),sy_recta_izq_int,muy_recta_izq_int),'y-','Linewidth',8);
plot(Ha,YL:YH,polyval(py_izq_int,YL:YH,sy_izq_int,muy_izq_int) .- polyval(py_recta_izq_int,YL:YH,sy_recta_izq_int,muy_recta_izq_int .+ 10),'c-','Linewidth',8);
plot(Ha,YL:YH,polyval(py_izq_ext,YL:YH,sy_izq_ext,muy_izq_ext),'k-','Linewidth',8);
plot(Ha,rango_recta_re_izq_ux(1):rango_recta_re_izq_ux(2),polyval(py_recta_izq_ext,rango_recta_re_izq_ux(1):rango_recta_re_izq_ux(2),sy_recta_izq_ext,muy_recta_izq_ext),'r-','Linewidth',8);
plot(Ha,YL:YH,polyval(py_izq_ext,YL:YH,sy_izq_ext,muy_izq_ext) .- polyval(py_recta_izq_ext,YL:YH,sy_recta_izq_ext,muy_recta_izq_ext) .+ 10,'m-','Linewidth',8);
plot(Ha,YL:YH,polyval(py_der_int,YL:YH,sy_der_int,muy_der_int),'g-','Linewidth',8);
plot(Ha,rango_recta_ri_der_ux(1):rango_recta_ri_der_ux(2),polyval(py_recta_der_int,rango_recta_ri_der_ux(1):rango_recta_ri_der_ux(2),sy_recta_der_int,muy_recta_der_int),'y-','Linewidth',8);
plot(Ha,YL:YH,polyval(py_der_int,YL:YH,sy_der_int,muy_der_int) .- polyval(py_recta_der_int,YL:YH,sy_recta_der_int,muy_recta_der_int) .+ 10,'c-','Linewidth',8);
plot(Ha,YL:YH,polyval(py_der_ext,YL:YH,sy_der_ext,muy_der_ext),'k-','Linewidth',8);
plot(Ha,rango_recta_re_der_ux(1):rango_recta_re_der_ux(2),polyval(py_recta_der_ext,rango_recta_re_der_ux(1):rango_recta_re_der_ux(2),sy_recta_der_ext,muy_recta_der_ext),'r-','Linewidth',8);
plot(Ha,YL:YH,polyval(py_der_ext,YL:YH,sy_der_ext,muy_der_ext) .- polyval(py_recta_der_ext,YL:YH,sy_recta_der_ext,muy_recta_der_ext) .+ 10,'m-','Linewidth',8);


axis(Ha,[YL YH 0 255]);

ylabel(Ha,"Intensidad","fontsize",12);
xlabel(Ha,"Altura de la imagen [pixel]","fontsize",12);

LEYENDA1 = sprintf("Intensidad en la altura <y> a lo largo de la imagen.");
LEYENDA2 = sprintf("Ajuste de parabola para los radios de difraccion interiores");
LEYENDA3 = sprintf("Ajuste de recta para los radios de difraccion interiores");
LEYENDA4 = sprintf("Resta de parabola y recta para los radios de difraccion interiores");
LEYENDA5 = sprintf("Ajuste de parabola para los radios de difraccion exteriores");
LEYENDA6 = sprintf("Ajuste de recta para los radios de difraccion exteriores");
LEYENDA7 = sprintf("Resta de parabola y recta para los radios de difraccion exteriores");
Hleg = legend(Ha,LEYENDA1,LEYENDA2,LEYENDA3,LEYENDA4,LEYENDA5,LEYENDA6,LEYENDA7,"location",'northoutside');
legend(Ha,"boxon");
set(Hleg,'FontSize',5);


NOMBRE_GRAFICO = sprintf("Intensidad_largo_medio");
EXTENSION_ARCHIVO = sprintf(".pdf");

NOMBRE_ARCHIVO = sprintf("%s_%s_%s%s",
						 NOMBRE_GRAFICO,str_volts(k,:),
						 dir_imagenes(i).name,EXTENSION_ARCHIVO
                        );
NOMBRE_ARCHIVO_CROP = sprintf("%s_%s_%s-crop%s",
						 NOMBRE_GRAFICO,str_volts(k,:),
						 dir_imagenes(i).name,EXTENSION_ARCHIVO
                        );                        



print(hf2,NOMBRE_ARCHIVO,'-dpdf','-r1000');

COMANDO = sprintf("pdfcrop \"%s\"",NOMBRE_ARCHIVO);
system(COMANDO);
COMANDO = sprintf("evince \"%s\" &",NOMBRE_ARCHIVO_CROP); 
system(COMANDO);
COMANDO = sprintf("rm \"%s\"",NOMBRE_ARCHIVO);
system(COMANDO);

hf3=figure(3);


imagesc( imagen_gris );
colormap hot;

hf4 = figure(4);
Ha=axes;
imagesc( Ha,[XL XH],[YL YH],imagen_gris(YL:YH,XL:XH) );
colormap hot;
#c=colorbar(Ha);
#ylabel(c,"Intensidad");


ylabel("Altura de la imagen [pixel]","fontsize",12);
xlabel("Largo de la imagen [pixel]","fontsize",12);


NOMBRE_GRAFICO = sprintf("Intensidad_difraccion");
EXTENSION_ARCHIVO = sprintf(".pdf");

NOMBRE_ARCHIVO = sprintf("%s_%s_%s%s",
						 NOMBRE_GRAFICO,str_volts(k,:),
						 dir_imagenes(i).name,EXTENSION_ARCHIVO
                        );
NOMBRE_ARCHIVO_CROP = sprintf("%s_%s_%s-crop%s",
						 NOMBRE_GRAFICO,str_volts(k,:),
						 dir_imagenes(i).name,EXTENSION_ARCHIVO
                        );                        



print(hf4,NOMBRE_ARCHIVO,'-dpdf','-r1000');

COMANDO = sprintf("pdfcrop \"%s\"",NOMBRE_ARCHIVO);
system(COMANDO);
COMANDO = sprintf("evince \"%s\" &",NOMBRE_ARCHIVO_CROP); 
system(COMANDO);
COMANDO = sprintf("rm \"%s\"",NOMBRE_ARCHIVO);
system(COMANDO);


