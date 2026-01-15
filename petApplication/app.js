const express = require('express');
const {Web3} = require('web3');
const fs = require("fs");
const PetContract = require('./build/PetContract.json');
//const filePath = './public/petInfo.json';
const multer = require('multer');

// Set up multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
      cb(null, 'public/images'); // Directory to save uploaded files
  },
  filename: (req, file, cb) => {
      cb(null, file.originalname); 
  }
});

const upload = multer({ storage: storage });

const app = express();
//Set up view engine
app.set('view engine', 'ejs');
//This line of code tells Express to serve static files (such as images, CSS, JavaScript files, or PDFs)
//from the public directory
app.use(express.static('public'))
//enable form processing
app.use(express.urlencoded({
    extended: false
}));

var GanacheWeb3;
var account = '';
var noOfPets=0;
var loading= true;  
var listOfPets = [];   
var listOfPetsSC = [];   
var contractInfo;  


async function componentWillMount() {
    try {
        await loadWeb3();
        await loadBlockchainData();
    } catch (error) {
        console.error('Error in componentWillMount:', error);
    } 
}

async function loadWeb3() {
    //loads the connection to the blockchain (ganache )
    GanacheWeb3 = new Web3("http://127.0.0.1:7545");
}

async function loadBlockchainData() {
  try {
    loading = true;
    const web3 = GanacheWeb3;
    // Load account from the network /blockchain/ganache//loads 10 accounts from ganache 
    const accounts = await web3.eth.getAccounts()
    //console.log(accounts[0]);
    // set the state of the variable account declared in constructor.
    account= accounts[0];
    //console.log(account);
    // gets the network id from the web3 connection to ganache //ganache 5777
    const networkId = await web3.eth.net.getId()
    //console.log(networkId)
    //reads the network data migrated into the gananche
    const networkData = PetContract.networks[networkId]

    if (!networkData) {
      throw new Error('Pet contract not deployed to detected network');
    }
    //Initialize the contract
    contractInfo = new web3.eth.Contract(PetContract.abi, networkData.address)
    //console.log(contractInfo)
      // calls the function getNoOfPets from the pet contract deployed
    const cnt = await contractInfo.methods.getNoOfPets().call();
    console.log(`Pet count from blockchain: ${cnt.toString()}`);
     
    // Load pets from JSON file
    /*const loadJsonPets = () => {
      return new Promise((resolve, reject) => {
        fs.readFile(filePath, "utf8", (err, data) => {
          if (err) {
            reject(new Error(`Error reading JSON file: ${err.message}`));
            return;
          }
          
          try {
            const pets = JSON.parse(data);
            resolve(pets);
          } catch (parseError) {
            reject(new Error(`Error parsing JSON data: ${parseError.message}`));
          }
        });
      });
    };*/

      // Load pets from smart contract
    const loadSmartContractPets = async () => {
      const pets = [];
      //const ownershipInfo = []
      for (let i = 1; i <= cnt; i++) {
        const [
          petInfo,
          ownershipInfo,
          vaccinationInfo,
          adoptionInfo,
          insuranceInfo,
          trainingInfo,
          //shelterInfo,
        ] = await Promise.all([
          contractInfo.methods.getPetInfo(i).call(),
          contractInfo.methods.getOwnershipRecords(i).call(),
          contractInfo.methods.getVaccinationRecords(i).call(),
          contractInfo.methods.getAdoptionAgreement(i).call(),
          contractInfo.methods.getInsuranceData(i).call(),
          contractInfo.methods.getTrainingRecords(i).call(),
          contractInfo.methods.getBreederShelterInfo(i).call(),         
        ]);

        // Create a comprehensive pet object with all related information
        const petData = {
          id: i,
          petInfo : formatPetInfo(petInfo),
          ownership: formatOwnershipInfo(ownershipInfo),
          vaccinations: formatVaccinationInfo(vaccinationInfo),
          adoption: formatAdoptionInfo(adoptionInfo),
          insurance: formatInsuranceInfo(insuranceInfo),
          training: formatTrainingInfo(trainingInfo),
          //shelterInfo: formatInsuranceInfo(shelterInfo),
        };
        pets.push(petData);
      }
      //console.log(pets);
       return pets;
    };
    
    // Execute both loading operations concurrently
    //const [jsonPets, smartContractPets] = await Promise.all([
    const [smartContractPets] = await Promise.all([
      //loadJsonPets(),
      loadSmartContractPets()
    ]);
    
    // Update state
    //listOfPets = [...jsonPets];
    listOfPetsSC = smartContractPets;
    noOfPets = listOfPetsSC.length;
    //console.log(listOfPetsSC);
    console.log(`Total pets loaded from JSON: ${listOfPets.length}`);
    console.log(`Total pets loaded from blockchain: ${listOfPetsSC.length}`);
    return {
      account,
      contractInfo,
      listOfPets,
      listOfPetsSC,
      noOfPets
    };     
  }catch (error) {
    console.error('Error loading blockchain data:', error);
    throw error;
  } finally {
    loading = false;
  }
}


// Helper functions to format different types of data
function formatPetInfo(petInfo) {
  return {
    id: petInfo.id,
    name: petInfo.name,
    dateOfBirth: petInfo.dateOfBirth,
    gender: petInfo.gender,
    // Add any other pet-specific fields
  };
}

function formatOwnershipInfo(ownershipInfo) {
  return ownershipInfo.map(record => ({
    ownerId: record.ownerId,
    ownerName: record.ownerName,
    transferDate: record.transferDate,
    phone: record.phone,
    email: record.email,
    // Add any other ownership-specific fields
  }));
}

function formatVaccinationInfo(vaccinationInfo) {
  return vaccinationInfo.map(record => ({
    vaccineName: record.vaccineName,
    dateAdministered: record.dateAdministered,
    doctorname: record.doctorname,
    clinic: record.clinic,
    phone: record.phone,
    email: record.email,
    // Add any other vaccination-specific fields
  }));
}

function formatTrainingInfo(trainingInfo) {
  return trainingInfo.map(record => ({
    trainingType: record.trainingType,
    traninerName: record.traninerName,
    organization: record.organization,
    phone: record.phone,
    trainingDate: record.trainingDate,
    progress: record.progress,
    // Add any other training-specific fields
  }));
}

function formatInsuranceInfo(insuranceInfo) {
  return  {
    policyNumber: insuranceInfo.policyNumber,
    provider: insuranceInfo.provider,
    coverageType: insuranceInfo.coverageType,
    maxClaimAmount: insuranceInfo.maxClaimAmount,
    premium: insuranceInfo.premium,
    claimId: insuranceInfo.claimId,
    amountClaimed: insuranceInfo.amountClaimed,
    claimDate: insuranceInfo.claimDate,
    status: insuranceInfo.status,
    // Add any other insurance-specific fields
  }
}

function formatAdoptionInfo(adoptionInfo) {
  return {
    agreementId: adoptionInfo.agreementId,
    adopterName: adoptionInfo.adopterName,
    dateSigned: adoptionInfo.dateSigned,
    returnPolicy: adoptionInfo.returnPolicy,
    adoptionFee: adoptionInfo.adoptionFee,
    // Add any other adoption-specific fields
  };

}
 
function formatShelterInfo(shelterInfo) {
    return {
      name: shelterInfo.name,
      companyAddress: shelterInfo.companyAddress,
      licenseNumber: shelterInfo.licenseNumber,
      phone: shelterInfo.phone,
      email: shelterInfo.email,
      // Add any other adoption-specific fields
    };
  }
 
// Define routes - home page
app.get('/', async(req, res) => {   
    console.log("home page");
    componentWillMount();
    console.log(loading);
    res.render('index', { acct: account, cnt: noOfPets, pets: listOfPetsSC, status: loading});
  });

//In your Express app, add this new endpoint:
app.get('/loading-status', (req, res) => {
  res.json({ loading: loading });
});

app.get('/pet/:id', (req, res) => {
  componentWillMount();
  try {
      const petId = req.params.id;
      console.log("petId ");
      console.log(petId);
  
      // Find the index of the pet based on petId
      const index = listOfPetsSC.findIndex(listOfPetsSC => 
                                  listOfPetsSC.id.toString() === petId.toString()
                                );
      console.log("get pet information")
      console.log(index)
      if (index === -1) {
        console.log("pet not found");
        return res.status(404).send("Pet not found");
      }
      res.render('pet', {acct: account, petData: listOfPetsSC[index], loading:false });
  }
  catch (error) {
      console.error('Error in pet registration:', error); 
      res.status(500).send('Error finding Pet');
  }
});

app.get('/addPet', (req, res) => {
  res.render('addPet', { acct: account} ); 
});

app.post('/addPet', upload.single('image'), async (req, res) => {
  try {
      // Extract data from request body
      const { petId, name, dob, gender } = req.body;
      
      // Handle image upload
      const image = req.file ? req.file.filename : null;
      
      // Validate required fields
      if (!petId || !name || !dob || !gender) {
          return res.status(400).json({ 
              error: 'Missing required fields' 
          });
      }

      // Ensure account is available
      if (!account) {
          return res.status(400).json({ 
              error: 'No blockchain account available' 
          });
      }

      // First estimate gas for the registration
      const registerGasEstimate = await contractInfo.methods
                                          .registerPet()
                                          .estimateGas({ from: account });

      console.log('Estimated gas for registration:', registerGasEstimate);

      // Register pet on blockchain
      const regData = await contractInfo.methods.registerPet().send({ 
                                from: account,
                                gas: String(Math.ceil(Number(registerGasEstimate) * 1.2))
                            });
      console.log(regData);
      if (!regData) {
          return res.status(500).json({ 
              error: 'Failed to register pet on blockchain' 
          });
      }

      //Get current pet count
      const petCount = await contractInfo.methods.getNoOfPets().call();
      
      // Estimate gas for transaction
      const gasEstimate = await contractInfo.methods
                                .addPetInfo(petCount, petId, name, gender, dob)
                                .estimateGas({ from: account });

      // Add pet info to blockchain
      const addPetTransaction = await contractInfo.methods
                                        .addPetInfo(petCount, petId, name, gender, dob)
                                        .send({ 
                                            from: account, 
                                            gas: String(Math.ceil(Number(gasEstimate) * 1.2)) 
                                            // Add 20% buffer to gas estimate
                                        });

      // Log successful transaction
      console.log('Pet added successfully:', {
          transactionHash: addPetTransaction.transactionHash,
          petId,
          name,
          petCount: petCount.toString()
      });
      res.redirect('/');     
  } catch (error) {
      console.error('Error in pet registration:', error);
      res.status(500).send('Error adding Pet');
  }
});

app.get('/addOwner/:id', (req, res) => {
  const petId = req.params.id;
  res.render('addOwner', { acct: account, petId : petId} ); 
});

app.post('/addOwner', async (req, res) => {
  try {
      // Extract data from request body
      const { ownerId, name, transferDate, contact, emailId, petId } = req.body;
      console.log([ownerId, name, transferDate, contact, emailId, petId]);
      
      // Validate required fields
      if (!petId || !name || !ownerId || !transferDate || !contact || !emailId ) {
          return res.status(400).json({ 
              error: 'Missing required fields' 
          });
      }

      // Ensure account is available
      if (!account) {
          return res.status(400).json({ 
              error: 'No blockchain account available' 
          });
      }
  
      // First estimate gas for the registration
      const registerGasEstimate = await contractInfo.methods
                                          .addOwnerShipRecord(Number(petId), ownerId, name, transferDate, contact, emailId)
                                          .estimateGas({ from: account });
   
      console.log('Estimated gas for registration:', registerGasEstimate);

      // Add owner info or the  pet on blockchain

      const ownerDataTransactionHash = await contractInfo.methods.addOwnerShipRecord(Number(petId), ownerId, name, transferDate, contact, emailId)
                              .send ({
                                from: account,
                                gas: String(Math.ceil(Number(registerGasEstimate) * 1.2))
                            });
          // Log successful transaction
      console.log('Pet Owner added successfully:', {
            transactionHash: ownerDataTransactionHash.transactionHash,
            ownerId, name, transferDate, contact, emailId, petId
      });
      res.redirect('/');     
  } catch (error) {
      console.error('Error in pet owner information:', error);
      res.status(500).send('Error adding Pet owner');
  }
});

app.get('/addVaccination/:id', (req, res) => {
  const petId = req.params.id;
  res.render('addVaccination', { acct: account, petId : petId} ); 
});

app.post('/addVaccination', async (req, res) => {
  try {
      // Extract data from request body
      const { vaccine, dateOfVaccine, doctor, clinic, contact, emailId, petId } = req.body;
      console.log([vaccine, dateOfVaccine, doctor, clinic, contact, emailId, petId]);
      
      // Validate required fields
      if (!petId || !vaccine || !dateOfVaccine || !doctor || !clinic || !contact || !emailId ) {
          return res.status(400).json({ 
              error: 'Missing required fields' 
          });
      }

      // Ensure account is available
      if (!account) {
          return res.status(400).json({ 
              error: 'No blockchain account available' 
          });
      }

      //pet.addVaccinationRecord(1, "Rabies", "2022-02-10","Dr. Sarah Lee", "Healthy Paws Veterinary Clinic",  "+65 1111 2222", "drlee@healthypaws.com")
  
      // First estimate gas for the registration
      const registerGasEstimate = await contractInfo.methods
                                          .addVaccinationRecord(Number(petId), vaccine, dateOfVaccine, doctor, clinic, contact, emailId)
                                          .estimateGas({ from: account });
      

      console.log('Estimated gas for registration:', registerGasEstimate);

      // Add owner info or the  pet on blockchain
      const vaccineDataTransactionHash = await contractInfo.methods.addVaccinationRecord(Number(petId), vaccine, dateOfVaccine, doctor, 
                                                      clinic, contact, emailId)
                                                      .send ({
                                                      from: account,
                                                      gas: String(Math.ceil(Number(registerGasEstimate) * 1.2))
                                                    });

       // Log successful transaction
      console.log('Pet Vaccination added successfully:', {
        transactionHash: vaccineDataTransactionHash.transactionHash,
        vaccine, dateOfVaccine, doctor, clinic, contact, emailId, petId
      });
    res.redirect('/');   
  } catch (error) {
      console.error('Error in pet owner information:', error);
      res.status(500).send('Error adding Pet owner');
  }
});

app.get('/addTraining/:id', (req, res) => {
  const petId = req.params.id;
  res.render('addTraining', { acct: account, petId : petId} ); 
});

app.post('/addTraining', async (req, res) => {
  try {
      // Extract data from request body
      const { trainingType, name, org, trainingDate, contact, progress, petId } = req.body;
      console.log([trainingType, name, org, trainingDate, contact, progress, petId]);
      
      // Validate required fields
      if (!petId || !name || !org || !trainingDate || !contact || !progress || !trainingType ) {
          return res.status(400).json({ 
              error: 'Missing required fields' 
          });
      }

      // Ensure account is available
      if (!account) {
          return res.status(400).json({ 
              error: 'No blockchain account available' 
          });
      }
  
      // First estimate gas for the registration
       const registerGasEstimate = await contractInfo.methods
                                          .addTrainingRecord(Number(petId), trainingType, name, org, contact, trainingDate, progress)
                                          .estimateGas({ from: account });
  
      console.log('Estimated gas for registration:', registerGasEstimate);

      // Add owner info or the  pet on blockchain
      const trainingDataTransactionHash = await contractInfo.methods.addTrainingRecord(Number(petId), trainingType, name, 
                                                      org, contact, trainingDate, progress)
                                                      .send({
                                                      from: account,
                                                      gas: String(Math.ceil(Number(registerGasEstimate) * 1.2))
                                                    });

     
      // Log successful transaction
      console.log('Pet Training added successfully:', {
          transactionHash: trainingDataTransactionHash.transactionHash,
          trainingType, name, org, trainingDate, contact, progress, petId
      });
      res.redirect('/');     
  } catch (error) {
      console.error('Error in pet training information:', error);
      res.status(500).send('Error adding Pet owner');
  }
});


const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));