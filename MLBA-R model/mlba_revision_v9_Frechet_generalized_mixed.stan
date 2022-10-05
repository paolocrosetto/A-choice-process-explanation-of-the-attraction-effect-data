functions{

    real lba_pdf(real t, real b, real v, real alpha){

        real pdf;

        if(t<=0){pdf=1e-5;}else{
        if(v<=0){pdf=1e-5;}else{
        //pdf = (v/b)*exp(-v*t/b);
        pdf = exp(weibull_lpdf(t|alpha, b/v));
      }}

        return pdf;
   }

     real lba_cdf(real t, real b, real v, real alpha){

          real cdf;

          if(t<=0){cdf=1e-5;}else{
          //cdf = 1-exp(-v*t/b);
          if(v<=0){cdf=1e-5;}else{
          cdf = weibull_cdf(t,alpha, b/v);
        }}

          return cdf;

     }

   vector CurveFun(row_vector option, real m) {

          vector[2] u;
          
          // Mapping objective to subjective values (Appendix C)

          // x and y intercepts of the line of indifference, which is in the direction of the unit-length vector 1/sqrt(2)*[-1,1]
          // subjective values for the option on the curve (x/a)^m + (y/b)^m
          u[1] = (option[1] + option[2])/((option[2]/option[1])^m+1)^(1/m) ;
          u[2] = (option[1] + option[2])/((option[1]/option[2])^m+1)^(1/m);
          return u;
        }

  real Weight1(real A, real B, real lambda) {
  // Attention weights (equation 4)

     real wt;

     wt = exp(-lambda*fabs(A-B));

     return wt;
    }


 real Valuation(vector option1, vector option2, real lambda, real beta) {
// Valuation function (equation 3)
  real v;
  real beta2;
  beta2 = lambda*beta;


  v = Weight1(option1[1], option2[1], lambda)*(option1[1] - option2[1]) + Weight1(option1[2], option2[2], beta2)*(option1[2] - option2[2]);
  return v;
}


 row_vector getDrifts(row_vector stimuli, real I_0, real m, real lambda, real gamma, real beta) {

    // Calculates the mean drift rates for MLBA
    // stimuli is a 3x2 matrix with the attributes of each option

    // Beta seems to be a multiplier that is applied to the second attribute to allow it to differ from the first
    // Gamma seems to be a multiplier to transform things to "drift scale"
            row_vector[3] d;
            vector[2] u1;
            vector[2] u2;
            vector[2] u3;

            u1[1:2] = CurveFun(stimuli[1:2], m);
            u2[1:2] = CurveFun(stimuli[3:4], m);
            u3[1:2] = CurveFun(stimuli[5:6], m);

            d[1] = gamma*Valuation(u1, u2, lambda, beta) + gamma*Valuation(u1, u3, lambda, beta) + I_0;
            if (d[1] <= 0) {d[1]=1e-5;}
            d[2] = gamma*Valuation(u2, u1, lambda, beta) + gamma*Valuation(u2, u3, lambda, beta) + I_0;
            if (d[2] <= 0) {d[2]=1e-5;}
            d[3] = gamma*Valuation(u3, u1, lambda, beta) + gamma*Valuation(u3, u2, lambda, beta) + I_0;
            if (d[3] <= 0) {d[3]=1e-5;}

            return d;
          }

// getting drifts if only two options, for revision part

 row_vector getDrifts2(row_vector stimuli, real I_0, real m, real lambda, real gamma , real beta) {

    // Calculates the mean drift rates for MLBA
    // stimuli is a 2x2 matrix with the attributes of each option

    // Beta seems to be a multiplier that is applied to the second attribute to allow it to differ from the first
    // Gamma seems to be a multiplier to transform things to "drift scale"
    // we multiply valuation by two to put on same scale as sum of valuation over two options in Drift1
            row_vector[2] d;
            vector[2] u1;
            vector[2] u2;
            
            u1[1:2] = CurveFun(stimuli[1:2], m);
            u2[1:2] = CurveFun(stimuli[3:4], m);
            
            d[1] = gamma*2*Valuation(u1, u2, lambda, beta) + I_0;
            if (d[1] <= 0) {d[1]=1e-5;}
            d[2] = gamma*2*Valuation(u2, u1, lambda, beta) + I_0;
            if (d[2] <= 0) {d[2]=1e-5;}
            
            return d;
          }



// // total pdf function
//
    real lmba_pdf(row_vector stimulus, real t1, int c1, real t2, int c2, int type, real k, real I, real m, real lam, real gamma, real beta, real stay, real tau, real alpha, data real[] x_r){

          real b;
          real t3;
          real t4;
          real t5;
          real cdf;
          real pdf;
          real pdf1;
          real pdf2;
          real prob_neg;
          real prob_neg1;
          real prob_neg2;
          real p23;
          real p32;
          real prob;
          real out;
          row_vector[3] v;
          row_vector[4] stimulusl;
          row_vector[4] stimulusn;
          row_vector[2] vl;
          row_vector[2] vn;
		      int l;
		      int n;
		      real infty;
		      //real x_r[0];
          //int x_i[0];
          //real tol[0];

         // tol = 1e-8 ;
            infty = 100; //warning, do not set too high as else, order2 messes up
            b = k;
            t3 = t1;
            t4 = t2 - t1; //time taken to make second decision, if no change in decision, then RT[i,3] is coded as upper time limit, 20 seconds
            t5 = 1 - t1; //maximum time to make second decision, note that max time is normalized to 1


		// here, need to replace tar,com,dec,nor with the drift of the options
		
		// stimulus is ordered as p1,q1,p2,q2,p3,q3 whereby 1 is target, 2 is competitor and 3 is decoy.
		
            v = getDrifts(stimulus,I,m,lam,gamma,beta);
            
            l = (c1)%3+1; // this is sth else than c1
            n = (c1+1)%3+1; // this is sth else than c1 and the above
               
               
            stimulusl=[stimulus[c1*2-1],stimulus[c1*2],stimulus[l*2-1],stimulus[l*2]];
            stimulusn=[stimulus[c1*2-1],stimulus[c1*2],stimulus[n*2-1],stimulus[n*2]];
		  
        // here, I include an advantage to the first choice by adding param "stay" to the drift of first option when comparing to second comer,
        // which will be either l or n.		  
		  
		        vl = getDrifts2(stimulusl,I,m,lam,gamma,beta);
		        vl = [vl[1]*stay,vl[2]];
		        if (vl[1] <= 0) {vl[1]=1e-5;}
		        
		        vn = getDrifts2(stimulusn,I,m,lam,gamma,beta);
		        vn = [vn[1]*stay,vn[2]];
		        if (vn[1] <= 0) {vn[1]=1e-5;}
		  
            //proba l before n at time c1 was chosen, that is, neither of them reached b at t but l is before n
            //p23=order_ode(1e-10, b, {t3, v[l], v[n]}, x_r);
              p23=v[l]^alpha/(v[l]^alpha+v[n]^alpha)*(1-lba_cdf(t3, b, v[l], alpha))*(1-lba_cdf(t3, b, v[n], alpha))*lba_pdf(t3, b, v[c1], alpha);
              
            //proba n before l at time c1 was chosen, that is, neither of them reached b at t but n is before l
            //p32=lbaX_cdf(b, t3, v[l])*lbaX_cdf(b, t3, v[n])-p23;
              p32=v[n]^alpha/(v[l]^alpha+v[n]^alpha)*(1-lba_cdf(t3, b, v[l], alpha))*(1-lba_cdf(t3, b, v[n], alpha))*lba_pdf(t3, b, v[c1], alpha);

            if (c2 == c1){
            
            // if l before n -> full integral of c1 winning vs l + partial integral of l winning after time limit t5, with truncation
                       
						// we denote v2 the drifts from comparison of c1 with l and v3 the drifts from comparison of c1 with n.
						
                         //pdf1=order2(1e-10, infty, {b, vl[1], vl[2]}, x_r)+order2(t5, infty, {b, vl[2], vl[1]}, x_r);
                         pdf1=vl[1]^alpha/(vl[1]^alpha+vl[2]^alpha)+vl[2]^alpha/(vl[1]^alpha+vl[2]^alpha)*(1-lba_cdf(t5, b, vl[1], alpha))*(1-lba_cdf(t5, b, vl[2], alpha));

                         // if n before l -> full integral of c1 winning vs n + partial integral of n winning after time limit t5, with truncation
                         //pdf2=order2(1e-10, infty, {b, vn[1], vn[2]}, x_r)+order2(t5, infty, {b, vn[2], vn[1]}, x_r);
                         pdf2=vn[1]^alpha/(vn[1]^alpha+vn[2]^alpha)+vn[2]^alpha/(vn[1]^alpha+vn[2]^alpha)*(1-lba_cdf(t5, b, vn[1], alpha))*(1-lba_cdf(t5, b, vn[2], alpha));

                         pdf=p23*pdf1+p32*pdf2;

                        }else{
                        if (c2 == l) {
                            // l2 before l3 and l2 wins at time t2 vs. j
                            // change this to v2 with corresponding drifts
                            pdf = p23*lba_pdf(t4, b, vl[2], alpha)*(1-lba_cdf(t4, b, vl[1], alpha));
                        }else{
                            // change this to v2 with corresponding drifts
                          pdf = p32*lba_pdf(t4, b, vn[2], alpha)*(1-lba_cdf(t4, b, vn[1], alpha));
                            }
                            }
                          //pdf = pdf*lba_pdf(t3, b, v[c1]);



            if(pdf < 1e-5){
               pdf = 1e-5;
              }

          //out[1] = prob;
          // out[2] = p23;
          // out[3] = p32;
          // out[4] = pdf1;
          // out[5] = pdf2;

          return pdf;
     }



// log likelihood

    real lba_log(matrix RT, real k, row_vector I, row_vector m, row_vector lam, row_vector gamma, row_vector beta, row_vector stay, real tau, real alpha, int N, data real[] x_r){


          vector[rows(RT)] prob;
          real t1;
          real t2;
          int c1;
          int c2;
          int type;
          real out;
          int n[rows(RT)];
          
          for (i in 1:rows(RT)){
            for (l in 1:N){
              if (RT[i,15]==l){n[i] = l;}}
          }

          for (i in 1:rows(RT)){
                    if(RT[i,2]==1){c1=1;}else{if(RT[i,2]==2){c1=2;}else{c1=3;}};
                    if(RT[i,4]==1){c2=1;}else{if(RT[i,4]==2){c2=2;}else{c2=3;}};
                    if(RT[i,5]==0){type=0;}else{type=1;};

                    prob[i] = lmba_pdf(RT[i,9:14], RT[i,1], c1, RT[i,3], c2, type, k, I[n[i]], m[n[i]], lam[n[i]], gamma[n[i]], beta[n[i]], stay[n[i]], tau, alpha, x_r);
                    
                     if(prob[i] < 1e-10){
                          prob[i] = 1e-10;
                     }
          }

          out = sum(log(prob));
          return out;
     }

// function to simulate data; good practice to generate and estimate simulated data to test accuracy

     vector lba_rng(row_vector stimulus, real k, real I, real m, real lam, real gamma, real beta, real stay, real tau, real alpha){

           int get_pos_drift;
           int no_pos_drift;
           int get_first_pos;
           row_vector[3] v;
           row_vector[2] v2;
           vector[3] drift;
		       vector[2] drift2;
           int max_iter;
           int iter;
           real tau_r;
           real ttf[3];
           int resp[3];
           row_vector[4] stimulus2;
           real ttf2[2];
           real ttf3;
           int resp2[2];
           int resp3[2];
           real rt;
           vector[4] pred;
           real b;

           //decoy vector
           // change this to go over each row of actual choices and simulate choices

            v[1:3] = getDrifts(stimulus,I,m,lam,gamma,beta);

            for(j in 1:3){
                drift[j] = v[j]*frechet_rng(alpha,1);
                //drift[j] = v[j];
                              }

            b = k;
            for(i in 1:num_elements(v)){
                     //finish times
                     ttf[i] = b/drift[i]+tau;
                }
                //rt is the fastest accumulator finish time
                //if one is negative get the positive drift
          
          // introduce random choices
          
          tau_r=uniform_rng(0,1);
          if(tau_r<tau){
            resp[1] = categorical_rng(rep_vector(inv(3), 3));
            resp[2] = (resp[1])%3+1;
            resp[3] = (resp[1]+1)%3+1;
            ttf[1] = tau_r;
            ttf[2] = tau_r;
            ttf[3] = tau_r;
            }else{
            resp = sort_indices_asc(ttf);
            ttf = sort_asc(ttf);
            }
		// now do second choice, which is a race between two first
		// note that here unlike in normal case, there is no difference between level of accumulator and time decision reached, i.e. the second time is also with the second highest level of accumulator.
			// this may not always be the case in the normal case
		// get relevant stimuli
		
		// compute drifts for those stimuli
		  stimulus2=[stimulus[resp[1]*2-1],stimulus[resp[1]*2],stimulus[resp[2]*2-1],stimulus[resp[2]*2]];
		  
		  v2[1:2] = getDrifts2(stimulus2,I,m,lam,gamma,beta);
		  v2 = [v2[1]*stay,v2[2]];
		  if (v2[1] < 0) {v2[1]=0;}
		
		// then draw who wins in this second race
		
            for(j in 1:2){
                 drift2[j] = v2[j]*frechet_rng(alpha,1);
                 //drift2[j] = v2[j];
                              }

            for(i in 1:num_elements(v2)){
                     //finish times
                     ttf2[i] = b/drift2[i]+tau;
                }
                //rt is the fastest accumulator finish time
                //if one is negative get the positive drift
           
           resp2 = sort_indices_asc(ttf2);
           ttf2 = sort_asc(ttf2);
           
           // this has yet to be translated into the original index of responses
           
           resp3 = resp[resp2];
           
           // note also that if time pred[3] is more than 1, then the original choice is maintained
           
           
           pred[1] = ttf[1];
           pred[2] = resp[1];
		       if (ttf2[1]+ttf[1]>1) {
		         pred[3] = 1;
             pred[4] = resp[1];
           } 
           else if (resp[1]==resp3[1]) {
		         pred[3] = 1;
             pred[4] = resp[1];
           } 
           else {
           
		         pred[3] = ttf2[1]+ttf[1];
             pred[4] = resp3[1];
           }
       

           return pred;
      }




}


data{
     int LENGTH;
     matrix[LENGTH,15] RT;
     int NUM_CHOICES;
     int NUM_INDIV;
}


transformed data {
  real x_r[0];
  int x_i[0];
}


parameters {
//     real<lower=0> k;
//     real<lower=0> tau;
     real<lower=0> mu_I;
     real<lower=0> mu_m;
     real<lower=0> mu_lam;
     real<lower=0> mu_gamma;
     real<lower=0> mu_beta;
     real<lower=0> tau_I;
     real<lower=0> tau_m;
     real<lower=0> tau_lam;
     real<lower=0> tau_gamma;
     real<lower=0> tau_beta;
    
     real<lower=0> mu_stay;
     real<lower=0> tau_stay;
     
     real<lower=0> alpha;
     //real<lower=0> tau_alpha;
    
     row_vector<lower=0>[NUM_INDIV] I;
     row_vector<lower=0>[NUM_INDIV] m;
     row_vector<lower=0>[NUM_INDIV] lam;
     row_vector<lower=0>[NUM_INDIV] gamma;
     row_vector<lower=0>[NUM_INDIV] beta;
     row_vector<lower=0>[NUM_INDIV] stay;
     //row_vector<lower=0>[NUM_INDIV] alpha;
 }

transformed parameters {
    real k;
    real tau;
    //row_vector[NUM_INDIV] alpha;
    k=1;
    tau=0;
    // for (j in 1:NUM_INDIV){
    //  alpha[j]=1.5;
    //    }
 }

 model {
//      k ~ normal(1,1)T[0,];
//      tau ~ normal(0,0.01)T[0,];

      mu_I ~ normal(1,1)T[0,];
      mu_m ~ normal(1,1)T[0,];
      mu_lam ~ normal(0,1)T[0,];
      mu_gamma ~ normal(2,1)T[0,];
      mu_beta ~ normal(1,1)T[0,];
      
      tau_I ~ gamma(1,1);
      tau_m ~ gamma(1,1);
      tau_lam ~ gamma(1,1);
      tau_gamma ~ gamma(1,1);
      tau_beta ~ gamma(1,1);
      
      mu_stay ~ normal(1,0.1)T[0,]; // we let stay be assumed to be close to 1 to help convergence
      tau_stay ~ gamma(0.1,1); 
	    
	    alpha ~ normal(1,1)T[0,];
	    //tau_alpha ~ gamma(1,1); 
      
  for (j in 1:NUM_INDIV){
    I[j]~ normal(mu_I, tau_I)T[0,];
    m[j]~ normal(mu_m, tau_m)T[0,];
    lam[j]~ normal(mu_lam, tau_lam)T[0,];
    gamma[j]~ normal(mu_gamma, tau_gamma)T[0,];
    beta[j]~ normal(mu_beta, tau_beta)T[0,];
    stay[j]~ normal(mu_stay, tau_stay)T[0,];
    //alpha[j]~ normal(mu_alpha, tau_alpha)T[0,];
    }
  
  RT ~ lba(k, I, m, lam, gamma, beta, stay, tau, alpha, NUM_INDIV, x_r);
    
  }
        
// warning, here, generate prediction based on first menu. Look into how to generate more general predictions?

 generated quantities {
 
     vector[4] pred_att1;
     vector[4] pred_att2;
     vector[4] pred_sim1;
     vector[4] pred_sim2;
     vector[4] pred_com1;
     vector[4] pred_com2;
     pred_att1 = lba_rng([1.5, 1, 1, 1.5, 1.5, 0.85],k,mu_I,mu_m,mu_lam,mu_gamma,mu_beta,mu_stay,tau, alpha);
     pred_att2 = lba_rng([1, 1.5, 1.5, 1, 0.85, 1.5],k,mu_I,mu_m,mu_lam,mu_gamma,mu_beta,mu_stay,tau, alpha);
     pred_sim1 = lba_rng([1.5, 1, 1, 1.5, 0.95, 1.55],k,mu_I,mu_m,mu_lam,mu_gamma,mu_beta,mu_stay,tau, alpha);
     pred_sim2 = lba_rng([1, 1.5, 1.5, 1, 1.55, 0.95],k,mu_I,mu_m,mu_lam,mu_gamma,mu_beta,mu_stay,tau, alpha);
     pred_com1 = lba_rng([1.5, 1, 1, 1.5, 2, 0.5],k,mu_I,mu_m,mu_lam,mu_gamma,mu_beta,mu_stay,tau, alpha);
     pred_com2 = lba_rng([1, 1.5, 1.5, 1, 0.5, 2],k,mu_I,mu_m,mu_lam,mu_gamma,mu_beta,mu_stay,tau, alpha);
     
}