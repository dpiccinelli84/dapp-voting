// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Membership.sol";

/**
 * @title Voting
 * @dev Contratto per la gestione di votazioni.
 * Il voto è ristretto ai soli possessori di un NFT dal contratto Membership.
 */
contract Voting {
    // L'indirizzo del contratto NFT che gestisce i membri
    Membership public membershipContract;

    // L'indirizzo del proprietario del contratto, che è l'unico che può iniziare una votazione.
    address public owner;

    // Struttura per rappresentare un candidato
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    // Struttura per rappresentare una votazione
    struct Poll {
        uint id; // ID univoco per ogni sondaggio
        string name;
        mapping(uint => Candidate) candidates;
        uint candidatesCount;
    }

    // ID del sondaggio corrente, parte da 1
    uint public currentPollId;

    // Mappa un sondaggio al suo ID
    mapping(uint => Poll) private polls;

    // Mappa un indirizzo all'ID dell'ultimo sondaggio in cui ha votato
    mapping(address => uint) public lastVotedPollId;

    // Evento emesso quando un voto viene registrato
    event Voted(address voter, uint pollId);
    // Evento emesso quando un nuovo sondaggio viene avviato
    event PollStarted(uint pollId, string name, uint candidatesCount);

    /**
     * @dev Il costruttore imposta l'indirizzo del contratto NFT e il proprietario.
     * @param _membershipContractAddress L'indirizzo del contratto Membership.
     */
    constructor(address _membershipContractAddress) {
        owner = msg.sender;
        membershipContract = Membership(_membershipContractAddress);
    }

    /**
     * @dev Inizia una nuova votazione. Solo il proprietario può chiamarla.
     * @param _pollName Il nome della votazione.
     * @param _candidateNames I nomi dei candidati.
     */
    function startPoll(string memory _pollName, string[] memory _candidateNames) public {
        require(msg.sender == owner, "Only owner can start a poll.");
        
        currentPollId++;
        Poll storage newPoll = polls[currentPollId];
        newPoll.id = currentPollId;
        newPoll.name = _pollName;
        
        // Resetta il conteggio dei candidati per il nuovo sondaggio
        newPoll.candidatesCount = 0; 
        for (uint i = 0; i < _candidateNames.length; i++) {
            newPoll.candidatesCount++;
            newPoll.candidates[newPoll.candidatesCount] = Candidate(newPoll.candidatesCount, _candidateNames[i], 0);
        }

        // Emette l'evento per notificare il frontend
        emit PollStarted(currentPollId, _pollName, _candidateNames.length);
    }

    /**
     * @dev Vota un candidato.
     * Richiede che il votante possieda un NFT di Membership.
     * @param _candidateId L'ID del candidato da votare.
     */
    function vote(uint _candidateId) public {
        // Controlla che il votante sia un membro (possegga un NFT)
        require(membershipContract.balanceOf(msg.sender) > 0, "Only NFT members can vote.");
        // Controlla che l'utente non abbia già votato in QUESTO sondaggio
        require(lastVotedPollId[msg.sender] < currentPollId, "You have already voted in this poll.");
        
        Poll storage currentPoll = polls[currentPollId];
        // Controlla che il candidato esista
        require(_candidateId > 0 && _candidateId <= currentPoll.candidatesCount, "Invalid candidate.");

        // Registra il voto
        currentPoll.candidates[_candidateId].voteCount++;
        lastVotedPollId[msg.sender] = currentPollId;

        // Emette l'evento
        emit Voted(msg.sender, currentPollId);
    }

    // Funzione per ottenere i dettagli di un candidato
    function getCandidate(uint _candidateId) public view returns (uint, string memory, uint) {
        Poll storage currentPoll = polls[currentPollId];
        require(_candidateId > 0 && _candidateId <= currentPoll.candidatesCount, "Invalid candidate.");
        Candidate storage candidate = currentPoll.candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }

    // Funzione per ottenere il numero totale di candidati
    function getCandidatesCount() public view returns (uint) {
        return polls[currentPollId].candidatesCount;
    }

    // Funzione per ottenere i dettagli del sondaggio corrente
    function getPollDetails() public view returns (uint, string memory) {
        Poll storage currentPoll = polls[currentPollId];
        return (currentPoll.id, currentPoll.name);
    }
}
