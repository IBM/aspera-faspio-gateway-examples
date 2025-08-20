# IBM Aspera faspio Gateway Examples

This repository contains practical examples and demos showcasing how to deploy and use the **IBM Aspera faspio Gateway** for various networking scenarios. Each example includes complete Docker-based setups with configuration files, test scripts, and comprehensive documentation.

## About IBM Aspera faspio Gateway

The IBM Aspera faspio Gateway is a high-performance networking solution that enables organizations to tunnel various protocols over the FASP (Fast, Adaptive, and Secure Protocol) transport. This allows for accelerated, reliable data transfer over long distances and challenging network conditions.

### Official Resources

- **[IBM Aspera Official Page](https://www.ibm.com/products/aspera)** - Learn more about IBM Aspera solutions
- **[faspio Gateway Documentation](https://www.ibm.com/docs/en/faspio-gateway/1.3.0)** - Official documentation and deployment guides
- **[FASP Protocol Overview](https://www.ibm.com/products/aspera/fasp)** - Technical details about the underlying FASP protocol

## Examples and Use Cases

### 🚀 [FTP Tunneling over FASP](./ftp-tunneling/)

**Use Case:** Accelerate FTP file transfers over long distances and unreliable networks

**What it demonstrates:**
- Complete FTP-over-FASP tunnel setup using Docker
- Client-side and server-side gateway configuration
- Automated testing with file integrity verification
- Performance comparison between direct FTP and tunneled FTP

**Key benefits:**
- Improved transfer speeds over high-latency networks
- Better reliability on lossy connections
- Maintains standard FTP client compatibility
- Easy integration with existing FTP workflows

## Coming Soon

- **iperf3 Demo** - How to test & troubleshoot a faspio Gateway setup with iperf3

## Support and Contribution

This repository provides practical examples for learning and development. For production deployments and enterprise support:

- **Technical Support:** Contact IBM Aspera support through your enterprise agreement
- **Example Issues:** Open an issue in this repository for problems with the demo setups

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

---

💡 **Tip:** Each example is self-contained and can be run independently. Start with the FTP tunneling example to understand the basic concepts before exploring more advanced use cases.
