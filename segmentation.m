
function seg = segmentation(I,inMask,max_its,inDeb)
  
  alpha = .2; 

  I = toGrayandDoub(I);    
  
  phi = mtop(inMask);
  
  for its = 1:max_its   

    idx = find(phi <= 1.2 & phi >= -1.2);  
   
    upPoints = find(phi<=0);                 
    vPoints = find(phi>0);                  
    u = sum(I(upPoints))/(length(upPoints)+eps); 
    v = sum(I(vPoints))/(length(vPoints)+eps); 
    
    F = (I(idx)-u).^2-(I(idx)-v).^2;         
    curvature = curve(phi,idx);  
    
    dphi = F./max(abs(F)) + alpha*curvature;  
    

    dt = .45/(max(dphi)+eps);

    phi(idx) = phi(idx) + dt.*dphi;

    phi = sFunc(phi, .5);

    if((inDeb>0)&&(mod(its,20) == 0)) 
      displayThings(I,phi,its);  
    end
  end
  
  if(inDeb)
    displayThings(I,phi,its);
  end
  
  seg = phi<=0;


function displayThings(I, phi, i)
  imshow(I,'initialmagnification',200,'inDebrange',[0 255]); hold on;
  contour(phi, [0 0], 'g','LineWidth',4);
  contour(phi, [0 0], 'k','LineWidth',2);
  hold off; title([num2str(i) ' Iterations']); drawnow;
  

function phi = mtop(init_a)
  phi=bwdist(init_a)-bwdist(1-init_a)+im2double(init_a)-.5;
  

function curvature = curve(phi,idx)
    [dimy, dimx] = size(phi);        
    [y x] = ind2sub([dimy,dimx],idx);

    ym1 = y-1; xm1 = x-1; yp1 = y+1; xp1 = x+1;

    ym1(ym1<1) = 1; xm1(xm1<1) = 1;              
    yp1(yp1>dimy)=dimy; xp1(xp1>dimx) = dimx;    

    idup = sub2ind(size(phi),yp1,x);    
    iddn = sub2ind(size(phi),ym1,x);
    idlt = sub2ind(size(phi),y,xm1);
    idrt = sub2ind(size(phi),y,xp1);
    idul = sub2ind(size(phi),yp1,xm1);
    idur = sub2ind(size(phi),yp1,xp1);
    iddl = sub2ind(size(phi),ym1,xm1);
    iddr = sub2ind(size(phi),ym1,xp1);

    phi_x  = -phi(idlt)+phi(idrt);
    phi_y  = -phi(iddn)+phi(idup);
    phi_xx = phi(idlt)-2*phi(idx)+phi(idrt);
    phi_yy = phi(iddn)-2*phi(idx)+phi(idup);
    phi_xy = -0.25*phi(iddl)-0.25*phi(idur)...
             +0.25*phi(iddr)+0.25*phi(idul);
    phi_x2 = phi_x.^2;
    phi_y2 = phi_y.^2;

    curvature = ((phi_x2.*phi_yy + phi_y2.*phi_xx - 2*phi_x.*phi_y.*phi_xy)./...
              (phi_x2 + phi_y2 +eps).^(3/2)).*(phi_x2 + phi_y2).^(1/2);        
  

function img = toGrayandDoub(img)    
  [dimy, dimx, c] = size(img);
  if(isfloat(img)) 
    if(c==3) 
      img = rgb2gray(uint8(img)); 
    end
  else           
    if(c==3) 
      img = rgb2gray(img); 
    end
    img = double(img);
  end


function D = sFunc(D, dt)

  a = D - shiftR(D);
  b = shiftL(D) - D; 
  c = D - shiftD(D);
  d = shiftU(D) - D;
  
  a_p = a;  a_n = a;
  b_p = b;  b_n = b;
  c_p = c;  c_n = c;
  d_p = d;  d_n = d;
  
  a_p(a < 0) = 0;
  a_n(a > 0) = 0;
  b_p(b < 0) = 0;
  b_n(b > 0) = 0;
  c_p(c < 0) = 0;
  c_n(c > 0) = 0;
  d_p(d < 0) = 0;
  d_n(d > 0) = 0;
  
  dD = zeros(size(D));
  D_neg_ind = find(D < 0);
  D_pos_ind = find(D > 0);
  dD(D_pos_ind) = sqrt(max(a_p(D_pos_ind).^2, b_n(D_pos_ind).^2) ...
                       + max(c_p(D_pos_ind).^2, d_n(D_pos_ind).^2)) - 1;
  dD(D_neg_ind) = sqrt(max(a_n(D_neg_ind).^2, b_p(D_neg_ind).^2) ...
                       + max(c_n(D_neg_ind).^2, d_p(D_neg_ind).^2)) - 1;
  
  D = D - dt .* sFunc_sign(D) .* dD;
  

function shift = shiftD(M)
  shift = shiftR(M')';

function shift = shiftL(M)
  shift = [ M(:,2:size(M,2)) M(:,size(M,2)) ];

function shift = shiftR(M)
  shift = [ M(:,1) M(:,1:size(M,2)-1) ];

function shift = shiftU(M)
  shift = shiftL(M')';
  
function S = sFunc_sign(D)
  S = D ./ sqrt(D.^2 + 1);    

  




