function C = make_spd_block_proto(thetaDeg, lambda1, lambda2)
theta = deg2rad(thetaDeg);
Q = [cos(theta), -sin(theta); sin(theta), cos(theta)];
C = Q * diag([lambda1, lambda2]) * Q.';
C = (C + C.') / 2;
end
