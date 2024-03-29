import sys
import time
import logging
import csv
import sage.matrix.matrix_integer_dense_hnf as matrix_integer_dense_hnf

# Set up log configuration
logging.basicConfig(filename='identifying_ideal_lattice.log', level=logging.WARN, format='%(asctime)s - %(levelname)s - %(message)s')

class LatticeGenerator:
    def __init__(self, dim, bound=3, seed=None, max_attempts=10):
        self.dim = dim
        self.bound = 2^bound
        self.seed = seed
        self.max_attempts = max_attempts

    def generate_lattice(self):
        attempts = 0

        while attempts < self.max_attempts:
            # If the seed parameter is not provided, use the current time's microsecond as the seed.
            if self.seed is None:
                self.seed = int(time.time() * 1e6)

            # Set the random seed
            set_random_seed(self.seed)

            # Generate a dim-dimensional integer lattice
            lattice_basis_list = [[ZZ(randint(-1 * self.bound, self.bound)) for _ in range(self.dim)] for _ in range(self.dim)]
            lattice_matrix = matrix(lattice_basis_list)

            # Check if the determinant of the matrix is zero
            if lattice_matrix.det() != 0:
                logging.info(f"######### Generated lattice with seed: {self.seed} #########")
                logging.info(f"Generated lattice matrix")
                logging.debug(f"Generated lattice matrix:\n{lattice_matrix}")
                return lattice_matrix, self.seed

            # If the determinant is zero, increase the number of attempts and regenerate the seed.
            attempts += 1
            self.seed = int(time.time() * 1e6)
            logging.info(f"Regenerated seed: {self.seed}")

        # If the maximum number of attempts is reached and a non-zero determinant matrix cannot be generated, return None.
        logging.warning("Unable to generate a non-zero determinant matrix after multiple attempts.")
        return None

    def generate_ideal_lattice(self):
        '''
        Randomly generate a dim-dimensional ideal lattice.
        '''
        attempts = 0

        while attempts < self.max_attempts:
            # If the seed parameter is not provided, use the current time's microsecond as the seed.
            if self.seed is None:
                self.seed = int(time.time() * 1e6)

            # Set the random seed
            set_random_seed(self.seed)

            # Generate f and g
            f = [ZZ(randint(-1 * self.bound, self.bound)) for _ in range(self.dim)]
            f.append(1)
            g = [ZZ(randint(-1 * self.bound, self.bound)) for _ in range(self.dim)]

            # Generate ZZ[x]/(f)
            R = PolynomialRing(ZZ, 'xx')
            f_polynomial = R(f)
            Q.<x> = QuotientRing(R, R.ideal(f_polynomial))

            # Generate a dim-dimensional integer ideal lattice
            lattice_basis_list = [list(Q(g) * x^ii) for ii in range(self.dim)]
            lattice_matrix = matrix(lattice_basis_list)

            # Check if the determinant of the matrix is zero
            if lattice_matrix.det() != 0:
                logging.info(f"######### Generated ideal lattice with seed: {self.seed} #########")
                logging.info(f"Generated f")
                logging.debug(f"Generated f: {f}")
                logging.info(f"Generated g")
                logging.debug(f"Generated g: {g}")
                logging.info(f"Generated ideal lattice matrix")
                logging.debug(f"Generated ideal lattice matrix:\n{lattice_matrix}")
                return lattice_matrix, self.seed

            # If the determinant is zero, increase the number of attempts and regenerate the seed.
            attempts += 1
            self.seed = int(time.time() * 1e6)
            logging.info(f"Regenerated seed: {self.seed}")

        # If the maximum number of attempts is reached and a non-zero determinant matrix cannot be generated, return None.
        logging.warning("Unable to generate a non-zero determinant matrix after multiple attempts.")
        return None

class IdentifyingLattice(LatticeGenerator):
    def divide_lattice(self, input_matrix, d):
        for ii in range(self.dim):
            for jj in range(self.dim):
                if input_matrix[ii, jj] % d != 0:
                    # If any element is not divisible by d, return False
                    return False
        # If all elements are divisible by d, return True
        return True

    def decide_integer_lattice(self, input_matrix):
        num_rows = input_matrix.nrows()
        num_cols = input_matrix.ncols()
        for i in range(num_rows):
            for j in range(num_cols):
                if not input_matrix[i, j].is_integral():
                    return False
        return True

    def incomplete_hnf(self, input_matrix):
        logging.info("Starting incomplete HNF algorithm.")
        
        temp = copy(input_matrix)

        iter_num = 0

        # Step 1: Iterate from 1 to n-1
        while iter_num < self.dim - 1:
            bi = temp[iter_num, self.dim - 1]
            bi1 = temp[iter_num + 1, self.dim - 1]
            if bi == 0 and bi1 == 0:
                logging.debug(f"Skipping update due to zero determinant condition.")
                iter_num += 2
            elif bi == 0:
                logging.debug(f"Skipping update due to zero determinant condition.")
                iter_num += 1
            elif bi1 == 0:
                temp[iter_num:iter_num + 2] = matrix([[0, 1], [1, 0]]) * temp[iter_num:iter_num + 2]
                logging.debug(f"Updated matrix: Swap rows {iter_num} and {iter_num+1}") 
                logging.debug(f"Updated matrix:\n{temp}")
                iter_num += 1
            else:
                # Step 2: Use Extended Euclidean Algorithm
                d, x, y = xgcd(bi, bi1)
                
                # Log information
                logging.debug(f"Updated matrix: Extended Euclidean Algorithm: x={x}, y={y}, d={d}") 

                # Step 3: Update matrix
                update_matrix = matrix([[-bi1/d, bi/d], [x, y]])
                temp[iter_num:iter_num + 2] = update_matrix * temp[iter_num:iter_num + 2]
                logging.debug(f"Updated matrix:\n{temp}")
                iter_num += 1
        output_matrix = temp
        logging.info("Incomplete HNF algorithm completed.")
        logging.debug(f"Output matrix:\n{output_matrix}")
        
        return output_matrix

    def identifying_ideal_cfp_ihnf(self, input_matrix):
        logging.info("****** Starting identifying_ideal_cfp_ihnf. ******")
        ihnf_matrix = self.incomplete_hnf(input_matrix)
        d = ihnf_matrix[self.dim-1, self.dim-1]
        temp = matrix(self.dim-1, 1, [0]*(self.dim-1)).augment(ihnf_matrix[0:self.dim-1, 0:self.dim-1]) * input_matrix.inverse()
        logging.info(f"Complete (0|D)* B^{-1}")
        logging.debug(f"(0|D)* B^{-1}:\n{temp}")
        if self.divide_lattice(input_matrix, d) is False:
            logging.info("identifying_ideal_cfp completed.")
            return False, None
        elif self.decide_integer_lattice(temp) is False:
            logging.info("identifying_ideal_cfp completed.")
            return False, None
        else:
            logging.info("identifying_ideal_cfp completed.")
            # Build the resulting tuple
            R = PolynomialRing(ZZ, 'x')
            temp_list=((matrix(1,1,[0]).augment(ihnf_matrix[self.dim-1,0:self.dim-1]))/d).list()
            temp_list=temp_list+[1]
            polynomial = R(temp_list)
            result_tuple = (
                polynomial,
                [list(row) for row in (input_matrix/d).rows()]
            )
            return True, result_tuple

    def reverse_matrix_row(self, input_matrix):
        reverse_matrix_row_result = matrix(1, self.dim, [0]*self.dim)
        for jj in range(self.dim):
            reverse_matrix_row_result[0,jj]=input_matrix[0,self.dim-1-jj]
        return reverse_matrix_row_result

    def reverse_matrix_rows(self, input_matrix):
        reverse_result_rows = identity_matrix(self.dim)
        for ii in range(self.dim):
            for jj in range(self.dim):
                reverse_result_rows[ii, jj]=input_matrix[ii, self.dim - 1 - jj]
        return reverse_result_rows

    def reverse_matrix_cols(self, input_matrix):
        reverse_result_cols = identity_matrix(self.dim)
        for ii in range(self.dim):
            for jj in range(self.dim):
                reverse_result_cols[ii, jj]=input_matrix[self.dim - 1 - ii, jj]
        return reverse_result_cols

    def identifying_ideal_cfp_oihnf(self, input_matrix):
        logging.info("****** Starting identifying_ideal_cfp_oihnf. ******")
        B_prime = matrix_integer_dense_hnf.hnf(input_matrix)[0]
        logging.info(f"Complete Matrix B_prime, which is the HNF of B")
        logging.debug(f"Matrix B_prime:\n{B_prime}")
        D=B_prime[1:self.dim, 1:self.dim]
        for ii in range(self.dim-1):
            for jj in range(ii, self.dim):
                if B_prime[ii, jj] % B_prime[ii, ii] == 0 and B_prime[ii + 1, ii + 1] % B_prime[ii, ii] == 0:
                    temp = D.augment(matrix(self.dim-1, 1, [0]*(self.dim-1))) * input_matrix.inverse()
                    logging.info(f"Complete (D|0)* B^{-1}")
                    logging.debug(f"(D|0)* B^{-1}:\n{temp}")
                    if self.decide_integer_lattice(temp) is True:
                        logging.info("identifying_ideal_cfp completed.")
                        # Build the resulting tuple
                        R = PolynomialRing(ZZ, 'x')
                        temp_list=self.reverse_matrix_row((B_prime[0,1:self.dim].augment(matrix(1,1,[0])))/B_prime[0,0]).list()
                        temp_list=temp_list+[1]
                        polynomial = R(temp_list)
                        result_tuple = (
                            polynomial,
                            [list(row) for row in (input_matrix/B_prime[0,0]).rows()]
                        )
                        return True, result_tuple
                    else:
                        logging.info("identifying_ideal_cfp completed.")
                        return False, None
                else:
                    logging.info("identifying_ideal_cfp completed.")
                    return False, None
        return False, None



    def identifying_ideal_cfp(self, input_matrix, method='ihnf'):
        if method=='ihnf':
            return self.identifying_ideal_cfp_ihnf(input_matrix)
        elif method=='oihnf':
            return self.identifying_ideal_cfp_oihnf(input_matrix)
        else:
            logging.warning("Invalid method.")
            return False, None    

    def adjugate_of_upper_triangular_dl(self,input_matrix,det):
        """
        Calculate the adjugate matrix of an upper triangular matrix B in SageMath.
        
        Parameters:
        - input_matrix: Upper triangular matrix
        - det: determinate of input_matrix
        
        Returns:
        - Adjugate matrix of input_matrix
        """
        # Define the polynomial ring over ZZ
        R = PolynomialRing(ZZ, 'x')
        x = R.gen()

        # Define the polynomial p(X) = \prod_{i=1}^{n} (X - B(i,i))
        p = prod(input_matrix[i, i]-x for i in range(self.dim))
        logging.info(f"Complete polynomial p(X)")
        logging.debug(f"Polynomial p(X):\n{p}")
        # Define another polynomial q(X) = (det(B)−p(X))/X 
        q = (det - p) / x
        logging.info(f"Complete polynomial q(X)")
        logging.debug(f"Polynomial q(X):\n{q}")
        # the adjugate of input_matrix is given by this polynomial q evaluated at input_matrix
        adj_matrix = q(input_matrix)
        logging.info(f"Complete adjugate matrix")
        logging.debug(f"Adjugate matrix:\n{adj_matrix}")
        return adj_matrix
    
    def adjugate_of_upper_triangular_sage(self,input_matrix):
        """
        Calculate the adjugate matrix of an upper triangular matrix B in SageMath.
        
        Parameters:
        - input_matrix: Upper triangular matrix
        - det: determinate of input_matrix
        
        Returns:
        - Adjugate matrix of input_matrix
        """
        
        adj_matrix = input_matrix.adjugate()
        logging.info(f"Complete adjugate matrix")
        logging.debug(f"Adjugate matrix:\n{adj_matrix}")
        return adj_matrix

    def adjugate_of_upper_triangular_inverse(self,input_matrix, det):
        """
        Calculate the adjugate matrix of an upper triangular matrix B in SageMath.
        
        Parameters:
        - input_matrix: Upper triangular matrix
        - det: determinate of input_matrix
        
        Returns:
        - Adjugate matrix of input_matrix
        """
        
        adj_matrix = det * input_matrix.inverse()
        logging.info(f"Complete adjugate matrix")
        logging.debug(f"Adjugate matrix:\n{adj_matrix}")
        return adj_matrix

    def create_matrix_M(self):
        """
        Create the matrix M as specified:
        M = [0, 0, ..., 0]
            [1, 0, ..., 0]
            [0, 1, ..., 0]
            [..., ..., ..., ...]
            [0, ..., 1, 0]
        
        Parameters:
        - self.dim: Size of the matrix
        
        Returns:
        - Matrix M
        """

        M=identity_matrix(self.dim)[:,1:].augment(matrix(self.dim, 1, [0]*(self.dim)))
        return M

    def identifying_ideal_dl_pre(self, input_matrix):
        temp=self.reverse_matrix_cols(input_matrix)
        logging.debug(f"Matrix after col-reverse:\n{temp}")
        temp=self.reverse_matrix_rows(temp)
        logging.debug(f"Matrix after row-reverse:\n{temp}")
        temp=temp.transpose()
        logging.debug(f"Matrix after transpose:\n{temp}")
        return temp
    
    def identifying_ideal_dl1(self, input_matrix):
        """
        Identify ideal lattice - Part 1.

        Parameters:
        - input_matrix: The input matrix representing an upper triangular matrix.

        Returns:
        - Matrix: The result after applying Hermite Normal Form (HNF) to the input matrix.
        """
        logging.info("****** Starting identifying_ideal_dl. ******")        
        temp = matrix_integer_dense_hnf.hnf(input_matrix)[0]
        logging.info(f"Complete Matrix B, which is the HNF of input_matrix")
        logging.debug(f"Matrix B:\n{temp}")
        return temp


    def identifying_ideal_dl2(self, input_matrix, method='inverse'):
        """
        Identify ideal lattice using algorithm in [DL07].

        Parameters:
        - input_matrix: The input matrix representing an upper triangular matrix.
        - method (optional): The method for calculating the adjugate matrix. 
        Options are 'inverse', 'sage', and 'dl'. Default is 'inverse'.

        Returns:
        - Boolean: True if the lattice is identified as an ideal lattice; False otherwise.
        """
        B=input_matrix
        logging.info(f"Complete Matrix B in Step 1 in Algorithm 1")
        logging.debug(f"Matrix B:\n{B}")
        det = prod(B[i, i] for i in range(self.dim))
        logging.info(f"Complete determinate of B in Step 2 in Algorithm 1")
        logging.debug(f"Determinate of B: {det}")
        if method=='inverse':
            A = self.adjugate_of_upper_triangular_inverse(B, det)
        elif method=='sage':
            A = self.adjugate_of_upper_triangular_sage(B)
        elif method=='dl':
            A = self.adjugate_of_upper_triangular_dl(B, det)
        else:
            logging.warning("Invalid method.")
            return False, None
        logging.info(f"Complete Matrix A in Step 2 in Algorithm 1")
        logging.debug(f"Matrix A:\n{A}")
        z = B[self.dim-1, self.dim-1]
        logging.info(f"Complete z in Step 2 in Algorithm 1")
        logging.debug(f"z: {z}")
        M = self.create_matrix_M()
        logging.info(f"Complete Matrix M")
        logging.debug(f"Matrix M:\n{M}")
        P = A * M * B % det
        logging.info(f"Complete Matrix P in Step 3 in Algorithm 1")
        logging.debug(f"Matrix P:\n{P}")

        if P[:, self.dim-1] != 0 and P[:, :self.dim-1] == 0:
            c = P[:, self.dim-1]
            logging.info(f"Complete c in Step 5 in Algorithm 1")
            logging.debug(f"c: {c}")
        else:
            logging.info("Invalid conditions for c calculation.")
            return False, None

        # Check if z divides each coefficient ci
        if all(c[i] % z == 0 for i in range(self.dim)):
            q_star_list = []
            for i in range(self.dim):
                temp=crt(ZZ(c[i,0] / z), ZZ(0), ZZ(det / z), ZZ(z))
                logging.debug(f"temp in computing crt: {temp}")
                q_star_list.append(temp)
            q_star=matrix(self.dim, 1, q_star_list)
            logging.info(f"Complete q_star in Step 8 in Algorithm 1")
            logging.debug(f"q_star: {q_star}")
        else:
            logging.info("z does not divide all coefficients.")
            return False, None

        if B * matrix(q_star) % (det / z) == 0:
            result_list=((B*q_star/det).transpose()).list()+[1]
            R = PolynomialRing(ZZ, 'x')
            polynomial = R(result_list)
            return True, polynomial
        else:
            logging.info("B * matrix(q_star) % (det / z) is not zero.")
            return False, None

def main(dim, bound, experiment_num, generate_method='lattice', cfp_method='ihnf', dl_method='inverse'):
    seed = None
    print(f"Parameters: dim, bound, experiment_num={dim}, {bound}, {experiment_num}")
    cfp_result = []
    dl_result = []
    cfp_time = []
    dl_time = []
    seed_list = []
    csv_file_path = f'{generate_method}/output_dim_{dim}_bound_{bound}_num_{experiment_num}.csv'

    for i in range(experiment_num):
        # Generate a lattice
        identifying_lattice = IdentifyingLattice(dim, bound, seed)
        if generate_method == 'lattice':
            result = identifying_lattice.generate_lattice()
        elif generate_method == 'ideal_lattice':
            result = identifying_lattice.generate_ideal_lattice()
        else:
            print("Invalid generate_method.")
            sys.exit(1)
        # Determine whether it is an ideal lattice
        if result is not None:
            lattice_matrix, used_seed = result
            seed_list.append(used_seed)
            # Measure the time taken by identifying_ideal_cfp
            start_time_cfp = time.time()
            result_cfp = identifying_lattice.identifying_ideal_cfp(lattice_matrix, method=cfp_method)
            end_time_cfp = time.time()
            cfp_result.append(result_cfp)
            cfp_time.append(end_time_cfp - start_time_cfp)
            # Measure the time taken by identifying_ideal_dl
            reverse_matrix4dl = identifying_lattice.reverse_matrix_rows(lattice_matrix)
            start_time_dl1 = time.time()
            matrix4dl = identifying_lattice.identifying_ideal_dl1(reverse_matrix4dl)
            end_time_dl1 = time.time()
            matrix4dl_pre = identifying_lattice.identifying_ideal_dl_pre(matrix4dl)
            start_time_dl2 = time.time()
            result_dl = identifying_lattice.identifying_ideal_dl2(matrix4dl_pre, method=dl_method)
            end_time_dl2 = time.time()
            dl_result.append(result_dl)
            dl_time.append(end_time_dl2 - start_time_dl2 + end_time_dl1 - start_time_dl1)
            '''
            dl_time.append(0)
            dl_result.append('None')
            '''
        else:
            print("Unable to generate a non-zero determinant matrix after multiple attempts.")
            seed_list.append('None')
            cfp_time.append(0)
            cfp_result.append('None')
            dl_time.append(0)
            dl_result.append('None')

    
    # Combine the four lists into a list where each element is a sublist containing four values
    data = list(zip(seed_list, cfp_result, dl_result, cfp_time, dl_time))

    # Use the csv module to write data to the CSV file
    directory = os.path.dirname(csv_file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

    with open(csv_file_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        
        # Write the header row (optional)
        writer.writerow(['seed', 'cfp_result', 'dl_result', 'cfp_time', 'dl_time'])        
        # Write the data
        writer.writerows(data)
    print(f"CSV file '{csv_file_path}' has been created.")
    print(f"Already completed {experiment_num} experiments.")
    print(f"The average time taken by identifying_ideal_cfp is {sum(cfp_time)/experiment_num} seconds.")
    print(f"The average time taken by identifying_ideal_dl is {sum(dl_time)/experiment_num} seconds.")

if __name__ == "__main__":
    # Check if command-line arguments are provided
    if len(sys.argv) != 4:
        print("Usage: sage identifying_ideal_lattice.sage <dim> <bound> <experiment_num>")
        sys.exit(1)

    # Parse command-line arguments
    dim, bound, experiment_num = map(int, sys.argv[1:])

    # Set other parameters as needed (e.g., dl_method)
    # 'lattice' or 'ideal_lattice'
    generate_method = 'lattice'
    # 'ihnf' or 'oihnf'
    cfp_method = 'ihnf'
    # 'inverse', 'sage', or 'dl'
    dl_method = 'inverse'

    # Run the main function with the provided arguments
    main(dim, bound, experiment_num, generate_method=generate_method, cfp_method=cfp_method, dl_method=dl_method)


