import {
  Box,
  Button,
  FormControl,
  FormLabel,
  Heading,
  IconButton,
  Input,
  Modal,
  ModalBody,
  ModalContent,
  ModalOverlay,
  Text,
  useDisclosure,
} from "@chakra-ui/react";
import { SubmitHandler, useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { CiSearch } from "react-icons/ci";

import { IoIosCloseCircleOutline } from "react-icons/io";

type SearchInputs = {
  name: string;
  professor: string;
};

interface Props {
  onSubmitForm: (values: SearchInputs) => void;
}

const AllCoursesHeader = (props: Props) => {
  const { t } = useTranslation();
  const { isOpen, onOpen, onClose } = useDisclosure();
  const {
    handleSubmit,
    register,
    formState: { errors },
  } = useForm<SearchInputs>();

  const submitHandler: SubmitHandler<SearchInputs> = (values) => {
    props.onSubmitForm(values);
    onClose();
  };

  return (
    <>
      <Box display="flex" justifyContent="space-between" alignItems="center">
        <Heading as="h3" size="md">
          {t("definedCourses")}
        </Heading>
        <Button
          variant="outlined"
          color="blue"
          onClick={onOpen}
          leftIcon={<CiSearch size={20} />}
        >
          {t("doSearch")}...
        </Button>
      </Box>
      {isOpen && (
        <Modal isCentered isOpen={isOpen} onClose={onClose}>
          <ModalOverlay />
          <ModalContent padding="20px">
            <Box
              display="flex"
              justifyContent="space-between"
              alignItems="center"
            >
              <Text fontWeight="500" fontSize="xl">
                {t("searchCourse")}
              </Text>
              <IconButton
                bg="transparent"
                aria-label="close icon"
                icon={<IoIosCloseCircleOutline size={30} />}
              />
            </Box>
            <ModalBody>
              <form noValidate onSubmit={handleSubmit(submitHandler)}>
                <FormControl>
                  <FormLabel>{t("courseName")}</FormLabel>
                  <Input {...register("name")} bg="#F3F4FF" />
                </FormControl>
                <FormControl mt="20px">
                  <FormLabel>{t("professor")}</FormLabel>
                  <Input {...register("professor")} bg="#F3F4FF" />
                </FormControl>
                <Box
                  mt="20px"
                  display="flex"
                  justifyContent="center"
                  alignItems="center"
                >
                  <Button
                    width="100px"
                    bg="primary.400"
                    color="#fff"
                    type="submit"
                  >
                    {t("accept")}
                  </Button>
                </Box>
              </form>
            </ModalBody>
          </ModalContent>
        </Modal>
      )}
    </>
  );
};

export default AllCoursesHeader;
