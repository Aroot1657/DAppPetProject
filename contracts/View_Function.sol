// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PetContract {
    enum PetStatus {Sold, Available}
    
    string public companyName;
    uint petCount;

    // Constructor code is only run when the contract is created
    constructor() {
        petCount=0;
        companyName = "Pete's Pet Shop";
    }

    function getCompanyName() public view returns(string memory){
        return companyName;
    }

   struct OwnershipRecord {
        string ownerId;
        string ownerName;
        string transferDate;
        string phone;
        string email;  
    }

    struct VaccinationRecord {
        string vaccineName;
        string dateAdministered;
        string doctorname;
        string clinic;
        string phone;
        string email;
    }

    struct AdoptionAgreement {
        string agreementId;
        string adopterName;
        string dateSigned;
        string returnPolicy;
        uint256 adoptionFee;
    }
  
    struct PetInsuranceData {
        string policyNumber;
        string provider;
        string coverageType;
        uint256 maxClaimAmount;
        uint256 premium;
        string claimId;
        uint256 amountClaimed;
        string claimDate;
        string status;
    }

    struct TrainingRecord {
        string trainingType;
        string traninerName;
        string organization;
        string phone;
        string trainingDate;
        string progress;
    }

    struct BreederAndShelterRecords {
        string name;
        string companyAddress;
        string licenseNumber;
        string phone;
        string email;       
    }

    struct PetInformation {
        string id;
        string name;
        string gender;
        string dateOfBirth;
    }

    struct Pet {
        PetInformation petInfo;
        BreederAndShelterRecords breederAndShelterRecords;
        AdoptionAgreement adoptionAgreements;
        PetInsuranceData petInsuranceData;
        OwnershipRecord[] ownershipRecords;
        VaccinationRecord[] vaccinationHistory;
        TrainingRecord[] trainingHistory;
    }
    mapping(uint256 => Pet) public pets;
 
    function registerPet() public returns (uint256) {
        petCount++;
    
        return petCount;
    }
    
    // Function to add pet  information
    function addPetInfo(
        uint256 petId,
        string memory _id,
        string memory _name,
        string memory _gender,
        string memory _dateOfBirth
    ) public {
        pets[petId].petInfo = PetInformation(_id, _name, _gender, _dateOfBirth);
    }

    // Function to add breeder and shelter company information
    function addBreederShelterInfo(uint256 petId, 
        string memory _name,
        string memory _companyAddress,
        string memory _licenseNumber,
        string memory _phone,
        string memory _email ) public {
            pets[petId].breederAndShelterRecords = BreederAndShelterRecords(_name, _companyAddress, _licenseNumber,
            _phone, _email);

    }
   
    // Function to add adoption agreement 
    function addAdoptionAgreement (uint256 petId, 
        string memory _agreementId,
        string memory _adopterName,
        string memory _dateSigned,
        string memory _returnPolicy,
        uint256 _adoptionFee) public {
            pets[petId].adoptionAgreements = AdoptionAgreement(_agreementId, _adopterName, _dateSigned,
            _returnPolicy, _adoptionFee);

    }

    // Function to add insurace data 
    function addPetInsuranceData (uint256 petId, 
       string memory _policyNumber,
        string memory _provider,
        string memory _coverageType,
        uint256 _maxClaimAmount,
        uint256 _premium,
        string memory _claimId,
        uint256 _amountClaimed,
        string memory _claimDate,
        string memory _status) public {
            pets[petId].petInsuranceData = PetInsuranceData(_policyNumber, _provider, _coverageType,
             _maxClaimAmount, _premium, _claimId, _amountClaimed, _claimDate, _status);

    }
      
    // Function to add a new ownership record
    function addOwnerShipRecord (uint256 petId, 
        string memory _ownerId,
        string memory _ownerName,
        string memory _transferDate,
        string memory _phone,
        string memory _email ) public {
            pets[petId].ownershipRecords.push(OwnershipRecord(_ownerId, _ownerName, _transferDate, _phone, _email));
    }

    function addVaccinationRecord (uint256 petId, 
        string memory _vaccineName,
        string memory _dateAdministered,
        string memory _doctorname,
        string memory _clinic,
        string memory _phone,
        string memory _email) public {
            pets[petId].vaccinationHistory.push(VaccinationRecord(_vaccineName, _dateAdministered, _doctorname, _clinic, _phone, _email));
    }

    function addTrainingRecord (uint256 petId, 
         string memory _trainingType,
        string memory _trainerName,
        string memory _organization,
        string memory _phone,
        string memory _trainingDate,
        string memory _progress) public {
            pets[petId].trainingHistory.push(TrainingRecord(_trainingType, _trainerName, _organization, _phone,
        _trainingDate, _progress));

    }

    //Write a function getNoOfPets to obtain the petCount
    function getNoOfPets() public view returns (uint) {
        return petCount;
    }

     // Function to retrieve pet  information
    function getPetInfo(uint256 petId) public view returns (PetInformation memory) {
        return pets[petId].petInfo;
    }

     // Function to retrieve breeder shelter  information
    function getBreederShelterInfo(uint256 petId) public view returns (BreederAndShelterRecords memory) {
        return pets[petId].breederAndShelterRecords;
    }

    // Function to retrieve ownership records
    function getOwnershipRecords(uint256 petId) public view returns (OwnershipRecord[] memory) {
        return pets[petId].ownershipRecords;
    }

    // Function to retrieve vaccination records
    function getVaccinationRecords(uint256 petId) public view returns (VaccinationRecord[] memory) {
        return pets[petId].vaccinationHistory;
    }

    // Function to retrieve training records
    function getTrainingRecords(uint256 petId) public view returns (TrainingRecord[] memory) {
        return pets[petId].trainingHistory;
    }

    // Function to retrieve insurance data
    function getInsuranceData(uint256 petId) public view returns (PetInsuranceData memory) {
        return pets[petId].petInsuranceData;
    }

    // Function to retrieve adoption agreement details
    function getAdoptionAgreement(uint256 petId) public view returns (AdoptionAgreement memory) {
        return pets[petId].adoptionAgreements;
    }

}
